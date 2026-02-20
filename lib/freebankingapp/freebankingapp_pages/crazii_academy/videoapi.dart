import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/marketdata.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/market.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/select_chart/purchasedsymbols.dart';

class VideoApi {

 

Future<Map<String, dynamic>> deductVideoCredit({
  required String videoId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');
  final String? accessToken = prefs.getString('access_token');

  if (userJson == null) {
    return {
      'status': 400,
      'message': 'User data not found in SharedPreferences.'
    };
  }

  if (accessToken == null || accessToken.isEmpty) {
    return {
      'status': 401,
      'message': 'Access token is not available'
    };
  }

  final user = jsonDecode(userJson);
  final String? userId = user['data']['id_user'];

  if (userId == null) {
    return {
      'status': 422,
      'message': 'User ID is null'
    };
  }

  final langCode = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse('https://cgmember.com/api/videos/deduct-credit?lang=$langCode');

  final request = http.MultipartRequest('POST', url);
  request.fields.addAll({
    'video_id': videoId,
    'user_id': userId,
  });

  request.headers.addAll({
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'multipart/form-data',
  });

  try {
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print('deductVideoCredit Response body: $responseBody');

    final int statusCode = streamedResponse.statusCode;
    String message;

    try {
      final decoded = jsonDecode(responseBody);
      message = decoded['message'] ?? decoded['error'] ?? 'Unknown response';
    } catch (e) {
      message = 'Failed to decode response body';
    }

    return {
      'status': statusCode,
      'message': message,
    };
  } catch (e) {
    print("Error during deductVideoCredit API call: $e");
    return {
      'status': 500,
      'message': 'Exception occurred: $e',
    };
  }
}

}