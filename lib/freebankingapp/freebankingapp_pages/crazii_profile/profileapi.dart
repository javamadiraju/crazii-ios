import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/shared_preference.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';
class ProfileApiService {
  // Base URL for the API endpoint
  final String baseUrl = 'https://cgmember.com/api/stripe/create-payment-intent';
 

  Future<bool> uploadProfilePicture(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user');

      if (userJson == null) {
        print("Error: User data not found in SharedPreferences.");
        return false;
      }

      final User user = User.fromJson(jsonDecode(userJson));
      final String userId = user.data.token;
      final String langCode = LanguageUtils.getLanguageCode();

      // Construct the dynamic URL with the user ID
      final Uri url = Uri.parse("https://cgmember.com/api/user/uploadProfilePicture/$userId?lang=$langCode");

      // Fetch the access token from shared preferences
 
      final String? accessToken = await SharedPreferencesHelper.getAccessToken();
      print('Toenreceived $accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        print("Error: Access token is not available.");
        return false;
      }

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Attach Image File
      request.files.add(await http.MultipartFile.fromPath('profile_picture', imageFile.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Profile upload response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        return true; // Upload successful
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return false;
      }
    } on SocketException {
      print("Network error: No internet connection.");
      return false;
    } on HttpException {
      print("HTTP error: Failed to upload profile picture.");
      return false;
    } on FormatException {
      print("Data format error: Invalid response format.");
      return false;
    } on Exception catch (e) {
      print("Unexpected error: $e");
      return false;
    }
  }

 


 Future<String?> downloadProfilePicture() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');

    if (userJson == null) {
      print("Error: User data not found in SharedPreferences.");
      return null;
    }

    final User user = User.fromJson(jsonDecode(userJson));
    final String userId = user.data.token;
    final String picturePath = user.data.picture ?? '';

    // Extract file extension from picturePath (e.g., ".jpeg", ".png")
    final String extension = picturePath.split('.').last;
    final String fileExtension = extension.isNotEmpty ? '.$extension' : '.jpg'; // fallback to .jpg
    String lang = Get.locale?.languageCode ?? 'en';
    final Uri url = Uri.parse("https://cgmember.com/api/user/downloadProfilePicture/$userId?lang=$lang");

    final String? accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print("Error: Access token is not available.");
      return null;
    }

    final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});
 
    if (response.statusCode == 200) {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String filePath = '${dir.path}/profile_picture$fileExtension';
      final File file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      await prefs.setString('profile_picture_path_$userId', file.path);

      print("Profile picture downloaded successfully: ${file.path}");
      return file.path;
    } else {
      print("Download failed with status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Unexpected error: $e");
    return null;
  }
}


}