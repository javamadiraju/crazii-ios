import 'package:get/get.dart';

class AuthController extends GetxController {
  String accessToken = "";

  void setAccessToken(String token) {
    accessToken = token;
  }

  String getAccessToken() {
    return accessToken;
  }
}
