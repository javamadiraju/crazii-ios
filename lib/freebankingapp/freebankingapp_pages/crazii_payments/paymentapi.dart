import 'dart:convert';
import 'package:http/http.dart' as http;
  
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/shared_preference.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Course.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserGroup.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Videos.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Product.dart';   
import 'package:flutter/material.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';


 

class PaymentApiService {
  // Base URL for the API endpoint
  final String baseUrl = 'https://cgmember.com/api/stripe/create-payment-intent';
Future<Map<String, dynamic>> createPaymentIntent({required int amount, required String currency}) async {
  try {
    // Constructing the URL
    final String langCode = LanguageUtils.getLanguageCode();
    final Uri url = Uri.parse('$baseUrl?lang=$langCode');

    // Headers
    Map<String, String> headers = {
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InB5Z29xaXdlckBtYWlsaW5hdG9yLmNvbSIsImlhdCI6MTczOTM0Mzk5NSwiZXhwIjoxNzM5MzQ1Nzk1fQ.LetNlpURibG2oW2VxqRpVSN2XEshLILT9fx1jJ3N5Z8',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    // Body data
    Map<String, String> body = {
      'amount': amount.toString(),
      'currency': currency,
    };

    // Sending POST request
    var response = await http.post(url, headers: headers, body: body);

    // Handling the response
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print('Payment Intent Created: $jsonResponse');
      return {
        'success': true,
        'data': jsonResponse
      };
    } else {
      var jsonResponse = jsonDecode(response.body);
      String errorMessage = 'Failed to create payment intent.';

      // Extract error message if available
      if (jsonResponse is Map && jsonResponse.containsKey('messages') && jsonResponse['messages'].containsKey('error')) {
        errorMessage = jsonResponse['messages']['error'];
      }

      print('Failed to create payment intent. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return {
        'success': false,
        'message': errorMessage
      };
    }
  } catch (e) {
    print('Error occurred: $e');
    return {
      'success': false,
      'message': 'An error occurred: $e'
    };
  }
}


Future<int> completeOrder({
  required String paymentIntentId, 
  required int amount,
  required String productType,  
  required String productId,
}) async {
  const String url = 'https://cgmember.com/api/stripe/complete-order';

  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');
  if (userJson == null) {
    throw Exception("User data not found in SharedPreferences.");
  }

  final User user = User.fromJson(jsonDecode(userJson));
  String userId = user.data.idUser;
  String email = user.data.email;
   
  await ApiService.refreshAccessToken();
 String? authToken = await SharedPreferencesHelper.getAccessToken();
  print('***** user id passed is $userId $productType $email $amount');

  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll({
      
      'user_id': userId,
      'product_id': productId,
    });

    // Match the working header exactly
    request.headers.addAll({
      'Authorization': 'Bearer https://cgmember.com/api/stripe/complete-order',
    });

    var response = await request.send();

    print('Response Status Code: ${response.statusCode}');
    String responseBody = await response.stream.bytesToString();
    print('Response Body: $responseBody');

    return response.statusCode;
  } catch (e) {
    print('Error completing order: $e');
    return 500;
  }
}





}
