import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
  
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


//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';

import 'package:email_validator/email_validator.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart'; 
import 'package:adoptive_calendar/adoptive_calendar.dart';
 

class AuthService {
  
Future<Map<String, dynamic>> checkEmail(String email) async {
  try {
    // Construct the URL with query parameters
    final langCode = Get.locale?.languageCode ?? 'en';
    final Uri url = Uri.parse('https://cgmember.com/api/check-email?email=$email&lang=$langCode');

    // Send a POST request
    final response = await http.post(
      url 
    );

    // Handle the response
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("✅ Email exists: ${jsonResponse['message']}");
      return {
        'success': true,
        'message': jsonResponse['message'],
      };
    } else if (response.statusCode == 404) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("⚠️ Email not found: ${jsonResponse['message']}");
      return {
        'success': false,
        'message': jsonResponse['message'],
      };
    } else {
      print("❌ Error: ${response.body}");
      return {
        'success': false,
        'message': 'Unexpected error: ${response.statusCode}',
      };
    }
  } catch (e) {
    print("❗Exception: $e");
    return {
      'success': false,
      'message': 'Exception occurred: $e',
    };
  }
}



 
Future<Map<String, dynamic>> requestOtp(String email) async {
  final langCode = Get.locale?.languageCode ?? 'en';
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://cgmember.com/api/request_otp?lang=$langCode'),
  );

  request.fields.addAll({
    'email': email,
  });

  print('** sending request....');

  try {
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('📨 Raw Response Body: $responseBody');

    final decoded = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      if (decoded['success'] == true) {
        return {
          'statusCode': 200,
          'message': decoded['message'] ?? 'OTP sent successfully',
        };
      } else {
        return {
          'statusCode': 400, // treat as failure
          'message': decoded['message'] ?? 'Failed to send OTP',
        };
      }
    } else {
      return {
        'statusCode': response.statusCode,
        'message': 'Failed: ${response.reasonPhrase}',
      };
    }
  } catch (e) {
    return {
      'statusCode': 500,
      'message': 'Error occurred: $e',
    };
  }
}

 

Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
  final langCode = Get.locale?.languageCode ?? 'en';
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://cgmember.com/api/verify_otp?lang=$langCode'),
  );

  request.fields.addAll({
    'email': email,
    'otp': otp,
  });

  try {
    http.StreamedResponse response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      if (data['success'] == true) {
        print('✅ OTP Verified: ${data['message']}');
      } else {
        print('❌ OTP Failed: ${data['message']}');
      }
    } else {
      print('❌ Request failed: ${response.statusCode} - ${response.reasonPhrase}');
    }

    return data;
  } catch (e) {
    print('⚠️ Exception during OTP verification: $e');
    return {'success': false, 'message': 'Exception: $e'};
  }
}



Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String newPassword,
}) async {
  var headers = {
    'Cookie': 'ci_session=k0vc6dgj6tnjk7e7mhk8q9vkv6dar7ob'
  };

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://cgmember.com/api/reset_password?lang=${Get.locale?.languageCode ?? 'en'}'),
  );

  request.fields.addAll({
    'email': email,
    'password': newPassword,
  });

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return {
        'statusCode': 200,
        'message': data['message'] ?? 'Password reset successful',
        'success': data['success'] ?? false,
      };
    } else {
      return {
        'statusCode': response.statusCode,
        'message': 'Server error: ${response.reasonPhrase}',
        'success': false,
      };
    }
  } catch (e) {
    return {
      'statusCode': 500,
      'message': 'Exception: $e',
      'success': false,
    };
  }
}


}
