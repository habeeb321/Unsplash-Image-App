import 'dart:developer';
import 'package:http/http.dart' as http;

class UnsplashService {
  final String apiKey =
      'https://api.unsplash.com/photos/?client_id=m4kw4D6JprJWPueJPBjMM3S5UXEf3gtaM5XFYtmvBso';
  final String clientId = 'm4kw4D6JprJWPueJPBjMM3S5UXEf3gtaM5XFYtmvBso';

  Future<dynamic> fetchImages() async {
    var request = http.Request('GET', Uri.parse(apiKey));

    request.headers.addAll({'Authorization': 'Client-ID $clientId'});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      return res;
    } else {
      log(response.reasonPhrase.toString());
    }
  }
}
