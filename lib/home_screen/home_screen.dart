import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalty_image/controller/unsplash_controller.dart';

class HomeScreen extends GetView<UnsplashController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => UnsplashController());
    controller.getImages();
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Image App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
        () {
          return controller.isLoading.value == true
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.red,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 45,
                        width: Get.size.width * 0.95,
                        child: CupertinoSearchTextField(
                          prefixInsets:
                              const EdgeInsetsDirectional.fromSTEB(10, 4, 5, 3),
                          backgroundColor: Colors.white,
                          controller: controller.searchController,
                          onChanged: (value) {
                            controller.search(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: controller.filteredImageList.length,
                          itemBuilder: (context, index) {
                            var image = controller.filteredImageList[index].user
                                    ?.profileImage?.large ??
                                '';
                            // var image = controller
                            //         .filteredImageList[index].urls?.small ??
                            //     '';
                            var name = controller
                                    .filteredImageList[index].user?.name ??
                                '';
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image(
                                            image: NetworkImage(image),
                                            fit: BoxFit.fill,
                                            height: Get.size.height * 0.17,
                                            width: Get.size.width,
                                          ),
                                        ),
                                        Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: IconButton(
                                    icon: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.downloading_sharp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      var image = controller
                                              .filteredImageList[index]
                                              .user
                                              ?.profileImage
                                              ?.large ??
                                          '';
                                      // var image = controller
                                      //         .filteredImageList[index]
                                      //         .urls
                                      //         ?.small ??
                                      //     '';
                                      controller.saveImageToStorage(
                                          image, context);
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.crop,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      var image = controller
                                              .filteredImageList[index]
                                              .user
                                              ?.profileImage
                                              ?.large ??
                                          '';
                                      // var image = controller
                                      //         .filteredImageList[index]
                                      //         .urls
                                      //         ?.small ??
                                      //     '';
                                      controller.cropImage(image, context);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
