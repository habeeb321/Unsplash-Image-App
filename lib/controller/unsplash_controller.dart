import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/state_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:royalty_image/model/unsplash_model.dart';
import 'package:royalty_image/service/get_image.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UnsplashController extends GetxController {
  TextEditingController searchController = TextEditingController();
  final imageList = <UnsplashModel>[].obs;
  final filteredImageList = <UnsplashModel>[].obs;
  final isLoading = false.obs;
  getImages() async {
    isLoading.value = true;
    imageList.clear(); 
    try {
      var res = await UnsplashService().fetchImages();
      var data = jsonDecode(res);
      for (var i = 0; i < data.length; i++) {
        imageList.add(UnsplashModel.fromJson(data[i]));
        filteredImageList.value = imageList;
      }
    } catch (e) {
      print(e.toString());
    }
    isLoading.value = false;
  }

  void search(String keyboard) {
    final results = <UnsplashModel>[].obs;
    if (keyboard.isEmpty) {
      results.value = imageList;
    } else {
      results.value = imageList
          .where(
            (element) => element.user!.name.toLowerCase().contains(
                  keyboard.toLowerCase(),
                ),
          )
          .toList();
    }
    filteredImageList.value = results;
    update();
  }

  List<bool> selectedImages = [];

  void toggleImageSelection(int index) {
    if (index >= 0 && index < filteredImageList.length) {
      selectedImages[index] = !selectedImages[index];
      update();
    }
  }

  List<String> getSelectedImages() {
    List<String> selected = [];
    for (int i = 0; i < filteredImageList.length; i++) {
      if (selectedImages[i]) {
        selected.add(filteredImageList[i].urls?.small ?? '');
      }
    }
    return selected;
  }

  Future<void> saveImageToStorage(String imageUrl, context) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    await GallerySaver.saveImage(file.path);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48.0,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Image Downloaded',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'The image has been downloaded successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> cropImage(String imageUrl, BuildContext context) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download image')),
      );
      return;
    }

    final bytes = response.bodyBytes;
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp_image.jpg';

    await File(tempPath).writeAsBytes(bytes);

    var imageFile = File(tempPath);

    if (!await imageFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image file does not exist')),
      );
      return;
    }

    var imageCropper = ImageCropper();
    var croppedImage = await imageCropper.cropImage(
      sourcePath: tempPath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
    );

    if (croppedImage != null) {
      bool? isSaved = await GallerySaver.saveImage(croppedImage.path);
      if (isSaved!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }
}
