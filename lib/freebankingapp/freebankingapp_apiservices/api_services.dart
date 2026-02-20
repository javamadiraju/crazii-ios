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
import 'package:get/get.dart';

// ✅ CUSTOM EXCEPTION FOR API ERRORS
class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? responseData;

  ApiException(this.message, {this.responseData});

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl = "https://cgmember.com";


  
Future<bool?> refreshToken() async {
   SharedPreferences prefs = await SharedPreferences.getInstance(); 
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
 

    if (email == null || email.isEmpty || password == null || password.isEmpty) {
    return false; // Return false if either is null or empty
  }

    try {
      ApiService apiService = ApiService();
      await apiService.signIn(email, password);
    } catch (e) {
      print('Failed to refresh token: $e');
      // Handle error if needed
      return false;
    }
  return true;

}


Future<User> getRemainingCredits() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');

    if (userJson == null) {
      throw Exception("User data not found in SharedPreferences.");
    }

    Map<String, dynamic> userMap = jsonDecode(userJson);
    final User user = User.fromJson(userMap);
    final String userId = user.data.idUser;
    final String langCode = Get.locale?.languageCode ?? 'en';

    final Uri url = Uri.parse('https://cgmember.com/api/user/id/$userId?lang=$langCode');

    String? accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
    };

    final http.Response response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      await refreshAccessToken(); 
      return await getRemainingCredits(); // retry with refreshed token
    }
  print('getallcredits access token response${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      userMap['data']['remaining_credits'] = jsonResponse['cash_credit'];
      userMap['data']['cash_credit'] = jsonResponse['cash_credit'];
       userMap['data']['credit'] = jsonResponse['cash_credit'];
      userMap['data']['bonusCredit'] = jsonResponse['bonus_credit'];
      userMap['data']['bonus_credit'] = jsonResponse['bonus_credit'];
      userMap['data']['picture'] = jsonResponse['picture'];
      await prefs.setString('user', jsonEncode(userMap));

      final updatedUser = User.fromJson(userMap);
      return updatedUser;
    } else {
      throw Exception("Failed to fetch user details. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error occurred: $e");
    rethrow;
  }
}



  // Function to refresh access token
  static Future<String?> refreshAccessToken() async {
    try {
     final String? refreshToken = await SharedPreferencesHelper.getRefreshToken();
     

      if (refreshToken == null) {
        print('No refresh token found');
        return null;
      }

      final String langCode = Get.locale?.languageCode ?? 'en';
      var request = http.MultipartRequest('POST', Uri.parse("https://cgmember.com/api/generateAccessToken?lang=$langCode"))
        ..fields['refresh_token'] = refreshToken;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);

        if (jsonData.containsKey('access_token')) {
          String newAccessToken = jsonData['access_token'];

          // Save new access token
          await SharedPreferencesHelper.saveAccessToken(newAccessToken); 
          return newAccessToken;
        } else {
          print('Failed to retrieve access token');
          return null;
        }
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
  

  Future<User?> signIn(String email, String password) async {
  final url =
      Uri.parse("$baseUrl/api/signin?email=$email&password=$password");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('signinresponse=${response.body}');

    // ✅ PARSE JSON RESPONSE FIRST
    final jsonResponse = jsonDecode(response.body);
    print('jsonResponseinsignin $jsonResponse');

    // ✅ CHECK IF API RETURNED STATUS: FALSE (regardless of HTTP status code)
    if (jsonResponse['status'] == false) {
      final String errorMessage = jsonResponse['error'] ?? 'Unknown error occurred';
      throw ApiException(errorMessage, responseData: jsonResponse);
    }

    if (response.statusCode == 200) {
      // 🔑 TOKENS
      final String accessToken = jsonResponse['access_token'];
      final String refreshToken = jsonResponse['refresh_token'];

      await SharedPreferencesHelper.saveAccessToken(accessToken);
      await SharedPreferencesHelper.saveRefreshToken(refreshToken);

      // 🔑 USER MODEL
      final User user = User.fromJson(jsonResponse);

      final prefs = await SharedPreferences.getInstance();

      // ✅ SAVE FULL USER JSON
      await prefs.setString('user', jsonEncode(user.toJson()));

      // ===================================================
      // ✅ SAVE PROFILE + CREDIT INFO (USED BY HEADER/DRAWER)
      // ===================================================
      final data = jsonResponse['data'] ?? {};

      await prefs.setString('user_id', data['id_user']?.toString() ?? '');
      await prefs.setString('first_name', data['first_name'] ?? '');
      await prefs.setString('last_name', data['last_name'] ?? '');

      await prefs.setString(
        'profile_picture_url',
        data['picture'] ?? '',
      );

      await prefs.setString(
        'cash_credit',
        data['cash_credit']?.toString() ?? '0',
      );

      await prefs.setString(
        'bonus_credit',
        data['bonus_credit']?.toString() ?? '0',
      );

      print("✅ SIGN-IN DATA SAVED SUCCESSFULLY");
      print("🖼️ PROFILE PIC: ${data['picture']}");

      return user;
    } else {
      throw ApiException(
          "Sign-in failed: ${response.statusCode}",
          responseData: jsonResponse);
    }
  } catch (e) {
    print("❌ Error in signIn: $e");
    rethrow;
  }
}



  
Future<Map<String, dynamic>> updatePassword(String newPassword) async {
  //await refreshAccessToken();
  try {
    const String baseUrl = 'https://cgmember.com/api/user/change-password';

    // Retrieve stored access token
    final prefs = await SharedPreferences.getInstance(); 
    final String? accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    // Retrieve user email
    final String? userJson = prefs.getString('user');
    if (userJson == null) {
      throw Exception("User data not found in SharedPreferences.");
    }
    final User user = User.fromJson(jsonDecode(userJson));
    final String email = user.data.email;
 

    // Prepare request
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['email'] = email
      ..fields['new_password'] = newPassword;

    // Send request
    var response = await request.send();

     if (response.statusCode == 401) {
        await refreshAccessToken(); 
        await updatePassword(newPassword);
      }

    var responseBody = await response.stream.bytesToString();
    
    debugPrint('🛠️ Status Code: ${response.statusCode}');
    debugPrint('🔍 Response Body: $responseBody');
    
    // Parse response body
    String message;
    try {
      final decodedBody = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        message = decodedBody['message'] ?? "Password updated successfully.";
      } else {
        message = decodedBody['new_password'] ?? "Unknown error";
      }
    } catch (e) {
      message = "Invalid response format";
    }
    
    return {
      'statusCode': response.statusCode,
      'message': message,
    };
  } catch (e) {
    debugPrint('🚨 Error: $e');
    return {
      'statusCode': 500,
      'message': e.toString(),
    };
  }
}


Future<Map<String, dynamic>> forgotPassword({
  required String email,
  required String oldPassword,
  required String newPassword,
}) async {
  const String baseUrl = 'https://cgmember.com/api/user/change-password';

  try {
    // Retrieve stored access token
    final String? accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    // Prepare request
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['email'] = email
      ..fields['old_password'] = oldPassword
      ..fields['new_password'] = newPassword;

    // Send request
    var response = await request.send();

    // Refresh token and retry if unauthorized
    if (response.statusCode == 401) {
      await refreshAccessToken();
      return await forgotPassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    }

    var responseBody = await response.stream.bytesToString();
    debugPrint('🛠️ Status Code: ${response.statusCode}');
    debugPrint('🔍 Response Body: $responseBody');

    String message;
    try {
      final decodedBody = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        message = decodedBody['message'] ?? "Password updated successfully.";
      } else {
        message = decodedBody['message'] ?? "An error occurred.";
      }
    } catch (e) {
      message = "Invalid response format";
    }

    return {
      'statusCode': response.statusCode,
      'message': message,
    };
  } catch (e) {
    debugPrint('🚨 Error: $e');
    return {
      'statusCode': 500,
      'message': e.toString(),
    };
  }
}

 


Future<bool> saveProfile(  String firstName, String lastName) async {
   // await refreshAccessToken();
  try {
    // Fetch SharedPreferences
    print('firstname $firstName $lastName');
    final prefs = await SharedPreferences.getInstance();
      final String? accessToken = await SharedPreferencesHelper.getAccessToken(); // Assuming access token is stored

    if (accessToken == null) {
      throw Exception("Access token not found in SharedPreferences.");
    }

    final String? userJson = prefs.getString('user');
    if (userJson == null) {
      throw Exception("User data not found in SharedPreferences.");
    }
    print('**save1');
    // Parse user data
    final User user = User.fromJson(jsonDecode(userJson));
    print(' user is ${user.data.token}');
    String token1 = user.data.token;
    String id1 = user.data.idUser;
  
    final String langCode = Get.locale?.languageCode ?? 'en';
    final Uri url = Uri.parse("https://cgmember.com/api/user/edit/$token1?lang=$langCode"); 
  
    print('** URL sent is $url');

    // Create request using http.Request
    var request = http.Request('PUT', url);
   request.headers.addAll({
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json"
    });
    request.body = jsonEncode({
      "first_name": firstName.isNotEmpty ? firstName : user.data.firstName,
      "last_name": lastName.isNotEmpty ? lastName : user.data.lastName
    });
 // Send a space as the body
    print('** 2URL sent is $url');
    // Send the request
    http.StreamedResponse streamedResponse = await request.send();
   print('**1 URL sent is $url');
    // Process the response
    if (streamedResponse.statusCode == 200) {
      // Convert streamed response to string
      String responseBody = await streamedResponse.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      print('**3 URL sent is $url');
      // Extract data (if needed)
      
      print("Update profile success. Response: ${jsonResponse['data']}");
        // Update profile fields in the user object
      user.data.firstName = firstName.isNotEmpty ? firstName : user.data.firstName;
      user.data.lastName = lastName.isNotEmpty ? lastName : user.data.lastName; 

      // Save updated user object back to SharedPreferences
      await prefs.setString('user', jsonEncode(user.toJson()));

      return true;
    } else {
      print("Failed to update profile. Status code: ${streamedResponse.statusCode}");
      print("Reason: ${streamedResponse.reasonPhrase}");
      return false;
    }
  } catch (e) {
    // Handle exceptions and log them (optional)
    print("Error in saveProfile: $e");
    return false;
  }
}




 

Future<bool> checkIfAlreadyDeducted(String optionSelected) async {

  final prefs = await SharedPreferences.getInstance();
  
  // Retrieve the last API call timestamp
  final String? lastCallTimestampStr = prefs.getString('lastApiCallTimestamp');

  if (lastCallTimestampStr != null) {
    final DateTime lastCallTimestamp = DateTime.parse(lastCallTimestampStr);
    final DateTime now = DateTime.now();

    // Check if the difference is less than 24 hours
    if (now.difference(lastCallTimestamp).inHours < 24) {
      print("API already called within the last 24 hours. Skipping API invocation.");
      return true; // Indicates already deducted
    }
  }

  print("No API call in the last 24 hours. Proceeding with deduction.");
  return false; // Indicates API call is needed
}


Future<bool> deductWithApiCall(String optionSelected) async {
 //   await refreshAccessToken();
  final prefs = await SharedPreferences.getInstance();
  final String langCode = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse("http://cgmember.com/api/credits?lang=$langCode");

  // Retrieve user and access token
  final String? userJson = prefs.getString('user');
  final String? accessToken = await SharedPreferencesHelper.getAccessToken();

  if (userJson == null) {
    throw Exception("User data not found in SharedPreferences.");
  }

  if (accessToken == null || accessToken.isEmpty) {
    print("Error: Access token is not available");
    return false;
  }

  final User user = User.fromJson(jsonDecode(userJson));
  print('deductWithApiCall User ID is: ${user.data.idUser}');
  print('deductWithApiCall access token received = $accessToken');

  // Check the last API call timestamp
  final String? lastCallTimestampStr = prefs.getString('lastApiCallTimestamp');
  final DateTime now = DateTime.now();
  print('lastCallTimestampStr $lastCallTimestampStr 1');
  if (lastCallTimestampStr != null) {
    final DateTime lastCallTimestamp = DateTime.parse(lastCallTimestampStr);
    final Duration difference = now.difference(lastCallTimestamp);

    if (difference.inHours < 24) {
      print("API already called within the last 24 hours. Skipping API invocation.");
      return true; // Already deducted within 24 hours
    }
  }

  // API request headers and body
  final headers = {
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/x-www-form-urlencoded",
  };

  final body = {
    'id_user': user.data.idUser,
    "credit_type": "BONUS",
    "action": "deduct",
    "amount": "1",
  };

  try {
    // Sending POST request
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("deductWithApiCall Request successful: ${response.body}");
      // Save the current timestamp
      await prefs.setString('lastApiCallTimestamp', now.toIso8601String());
      String? storedTimestamp = await prefs.getString('lastApiCallTimestamp');
      print('storedTimestamp: $storedTimestamp');
      return true; // Successful deduction
    } else {
      print("deductWithApiCall Failed with status code: ${response.statusCode}");
      print("Response: ${response.body}");
      return false; // Deduction failed
    }
  } catch (e) {
    print("Error occurred during API call: $e");
    return false; // Deduction failed
  }
}


Future<List<AppNotification>?> checkNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');
  String userId = '1'; // fallback

  if (userJson != null) {
    try {
      final User user = User.fromJson(jsonDecode(userJson));
      userId = user.data.idUser;
    } catch (e) {
      print('Error decoding user data: $e');
    }
  } else {
    print('No user data found in SharedPreferences.');
  }

  final String langCode = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse("http://cgmember.com/api/all-user-notifications/$userId?lang=$langCode");

  String? accessToken = await SharedPreferencesHelper.getAccessToken();
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available");
  }

  final headers = {
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/json",
  };

  final response = await http.get(url, headers: headers);
  print('******** fetching user notifications ${response.body}');

  if (response.statusCode == 401) {
    await refreshAccessToken(); 
    return await checkNotifications();
  }

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    if (jsonData['notifications'] != null && jsonData['notifications'] is List) {
      final rawList = jsonData['notifications'] as List;
      List<AppNotification> notifications = [];

      for (var item in rawList) {
        try {
          if (item is Map<String, dynamic>) {
            // ✅ Check if is_market == 1
            if (item['is_market']?.toString() == '0') {
              if (item.containsKey('body')) {
                item['body'] = decodeHtml(item['body']?.toString() ?? '');
              }
              notifications.add(AppNotification.fromJson(item));
            }
          } else {
            print('Skipped invalid notification item: $item');
          }
        } catch (e, st) {
          print('Error parsing notification item: $e\nItem: $item\n$st');
        }
      }

      return notifications;
    }

    return []; // Empty list if no notifications
  } else {
    throw Exception("Failed to fetch notifications: ${response.statusCode}");
  }
}







Future<List<AppNotification>?> checkMarketNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');
  String userId = '1'; // fallback

  if (userJson != null) {
    try {
      final User user = User.fromJson(jsonDecode(userJson));
      userId = user.data.idUser;
    } catch (e) {
      print('Error decoding user data: $e');
    }
  } else {
    print('No user data found in SharedPreferences.');
  }

  final String langCode = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse("http://cgmember.com/api/all-user-notifications/$userId?lang=$langCode");

  String? accessToken = await SharedPreferencesHelper.getAccessToken();
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available");
  }

  final headers = {
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/json",
  };

  final response = await http.get(url, headers: headers);
  print('******** fetching user notifications ${response.body}');

  if (response.statusCode == 401) {
    await refreshAccessToken(); 
    return await checkNotifications();
  }

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    if (jsonData['notifications'] != null && jsonData['notifications'] is List) {
      final rawList = jsonData['notifications'] as List;
      List<AppNotification> notifications = [];

      for (var item in rawList) {
        try {
          if (item is Map<String, dynamic>) {
            // ✅ Check if is_market == 1
            if (item['is_market']?.toString() == '1') {
              if (item.containsKey('body')) {
                item['body'] = decodeHtml(item['body']?.toString() ?? '');
              }
              notifications.add(AppNotification.fromJson(item));
            }
          } else {
            print('Skipped invalid notification item: $item');
          }
        } catch (e, st) {
          print('Error parsing notification item: $e\nItem: $item\n$st');
        }
      }

      return notifications;
    }

    return []; // Empty list if no notifications
  } else {
    throw Exception("Failed to fetch notifications: ${response.statusCode}");
  }
}

 


String decodeHtml(String htmlString) {
  // Decode HTML entities (e.g., &amp;lt; becomes <)
  var unescape = HtmlUnescape();
  String decodedHtml = unescape.convert(htmlString);

  // Parse the decoded HTML and remove <p> tags along with any other HTML tags
  var document = parse(decodedHtml);
  
  // Extract text from the document and remove <p> tags manually
  String text = document.body?.text ?? decodedHtml;

  // Remove any unwanted tags like <p>, <div>, etc. (if any remain)
  text = text.replaceAll(RegExp(r'<p>|</p>'), '').trim();

  print(text);  // For debugging purposes
  return text;
}


  Future<dynamic> fetchDataWithAuth(String endpoint, String authCode) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authCode',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Parse and return data
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchDataWithAuth: $e");
      return null;
    }
  }


Future<int> getCredit() async {
 //   await refreshAccessToken();
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');

  if (userJson != null) {
    final User user = User.fromJson(jsonDecode(userJson));
    return   int.tryParse(user.data.remainingCredits?.toString() ?? '0') ?? 0;
 
  }

  // Return a default value if no user data is found

  return 0;
}

Future<User> getUserData() async {
   // await refreshAccessToken();
   refreshToken();
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');

  if (userJson != null) {
    final User user = User.fromJson(jsonDecode(userJson));
    return user;
  }

  // Throw an exception if user data isn't found
  throw Exception("User data not found in SharedPreferences");
}


 static Future<List<Videos>> getVideos(BuildContext context) async { 
   // await refreshAccessToken();
   String lang = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse("https://cgmember.com/api/videos?lang=$lang");
  print('apivideos $url');
  // Fetch the access token from shared preferences
  String? accessToken = await SharedPreferencesHelper.getAccessToken();
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available");
  }

  // Set up headers with the authorization token
  final headers = {
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/json", // Adjust content type if required
  };

  // Send the GET request with headers
  final response = await http.get(url, headers: headers); 

  if (response.statusCode == 401) {
        await refreshAccessToken(); 
        await getVideos(  context);
      }
   if (response.statusCode == 200) {
    try { 
       Map<String, dynamic> responseData = json.decode(response.body);
       List<dynamic> videosJson = responseData['videos']; 
       print('****** video  response.body ${response.body}');
        return videosJson.map((item) => Videos.fromJson(item)).toList(); 
   } catch (e) {
      print("Error in videos : $e"); 
    }
    return [];
  } else {
    throw Exception('Failed to load products');
  }

  }



Future<UserGroup> getGroupDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');

  if (userJson != null) {
    final User user = User.fromJson(jsonDecode(userJson));
    final String userId = user.data.idUser;


    // Construct the dynamic URL with the user ID
    final url = Uri.parse("https://cgmember.com/api/groups?id=$userId");

    // Fetch the access token from shared preferences
    String? accessToken = await SharedPreferencesHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("Access token is not available");
    }

    // Set up headers with the authorization token
    final headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    // Send the GET request
    final response = await http.get(url, headers: headers);
  if (response.statusCode == 401) {
        await refreshAccessToken(); 
        await getGroupDetails();
      }
    if (response.statusCode == 200) {
      // Parse the response body
      Map<String, dynamic> responseData = json.decode(response.body);
      return UserGroup.fromJson(responseData);
    } else {
      throw Exception('Failed to load groups');
    }
  } else {
    throw Exception('User data not found in SharedPreferences');
  }
}
 

Future<List<Product>> fetchProducts() async { 
  refreshToken();
    // Get language dynamically from GetX locale
  String lang = Get.locale?.languageCode ?? 'en'; // fallback to 'en' if null

  final url = Uri.parse("http://cgmember.com/api/products?lang=$lang");
  print('langlanglang: $url');
 // final url = Uri.parse("http://cgmember.com/api/products?lang=zh");

  String? accessToken = await SharedPreferencesHelper.getAccessToken();
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available");
  }
  
  final headers = {
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/json",
  };

  final response = await http.get(url, headers: headers);  
  print('response in fetchProducts: ${response.body}');

  if (response.statusCode == 200) {
    try { 
      Map<String, dynamic> responseData = json.decode(response.body);

      // Filter only products where status is 'live'
      List<dynamic> productsJson = responseData['products']
          .where((item) => item['status']?.toString().toLowerCase() == 'live')
          .toList();

      List<Product> listProducts = productsJson.map((item) => Product.fromJson(item)).toList(); 

      print('Returning live products: $listProducts');
      return listProducts; 
    } catch (e) {
      print("Error parsing products: $e"); 
      return [];
    }
  } else {
    throw Exception('Failed to load products');
  }
}

  

Future<Map<String, dynamic>> confirmEnrollProduct(String productId) async {
  
  print('Invoking confirmation API');
 // String? accesstoken=await refreshAccessToken();
 // print('** refreshed token $accesstoken');
  // Fetch user details from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? userJson = prefs.getString('user');  
  if (userJson == null || userJson.isEmpty) {
    throw Exception("User data is not available");
  }

  final User user = User.fromJson(jsonDecode(userJson)); 
  final String userId = user.data.idUser;

  // Fetch the access token from SharedPreferences
  String? accessToken = await SharedPreferencesHelper.getAccessToken();
  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("Access token is not available");
  }

  // API URL
  final String langCode = Get.locale?.languageCode ?? 'en';
  final url = Uri.parse("http://cgmember.com/api/enroll-product?lang=$langCode");

  // Headers
  final headers = {
    "Authorization": "Bearer $accessToken",
  };

  try {
    print('URL used for enrollment: $url');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    // Add form fields (as in cURL)
    request.fields['productId'] = productId;
    request.fields['id_user'] = userId;

    // Send the request
    http.StreamedResponse response = await request.send();

    // Read response body
    final responseString = await response.stream.bytesToString();
    print('enroll resonse is $responseString');

    // Parse JSON response
    Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    // Extract message field
    String extractedMessage = jsonResponse.containsKey('message') ? jsonResponse['message'] : "Unknown response";

  if (response.statusCode == 401) {
      await refreshAccessToken(); 
      await confirmEnrollProduct(  productId);
  }
    // Ensure response is always JSON formatted
    if (response.statusCode == 200) {
      print('Enrollment successful: $responseString');
      return {
        'statusCode': response.statusCode,
        'message': extractedMessage, // API should return valid JSON
      };
    } else {
      print('Failed to enroll product: ${response.statusCode} $responseString');
      return {
        'statusCode': response.statusCode,
        'message': extractedMessage.isNotEmpty ? responseString : jsonEncode({'error': 'Unknown error occurred'}),
      };
    }
  } catch (e) {
    print('Error during API call: $e');
    return {
      'statusCode': 500,
      'message': jsonEncode({'error': 'Failed to enroll product: $e'}),
    };
  }
}



 
  // Method to call the registerUser API
  Future<Map<String, dynamic>> registerUser(UserSignupData userdata) async {
    try {  
      // API URL
      final String url = 'https://cgmember.com/api/signup';

      // Request body as a Map
      final Map<String, String> requestBody = {
        'email': userdata.email,
        'password': userdata.password,
        'date_birth': userdata.birthDate,
        'first_name': userdata.fullName.split(' ').first,
        'last_name': userdata.fullName.split(' ').last,
        'mobile': userdata.phoneNumber,
        'country': 'SG', // You can replace this dynamically if needed
        'address': userdata.location,
        'job': userdata.job,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', 
        },
        body: requestBody,
      );
        print('** response after singup ${response.body} ${userdata.email} ${userdata.password}');
      // Return response status and error message if the status is not 200
      if (response.statusCode == 200 || response.statusCode == 201) {
          print('register and signin success...');
           ApiService apiService = ApiService();
           User? user = await apiService.signIn(userdata.email, userdata.password); 
           print('userfetchafterregistereation $user');
        // Successfully registered
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': 'User registered successfully',
        };
      } else {
        // Handle API errors
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': response.body,
        };
      }
    } catch (e) {
      // Handle exceptions and log them (optional)
      return {
        'success': false,
        'statusCode': 500, // Internal Server Error
        'message': "Error in registerUser: $e",
      };
    }
  }



// Method to call the registerUser API
Future<Map<String, dynamic>> registerUserDetails(UserSignupData userdata) async {
  try { 
    // Initialize ApiService and get user object
    ApiService apiService = ApiService();
    User? user = await apiService.signIn(userdata.email, userdata.password); 
    String? token1 = user?.data.token; 

    // Construct the API URL
    final String langCode = Get.locale?.languageCode ?? 'en';
    final Uri url = Uri.parse("https://cgmember.com/api/user/edit/$token1?lang=$langCode"); 

    // Get the access token from SharedPreferences
    String? accessToken = await SharedPreferencesHelper.getAccessToken();
    print('user details : ${userdata.email}  ${userdata.password}   $token1  $accessToken');

    // Create request using http.Request
    var request = http.Request('PUT', url);
    request.headers.addAll({
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json"
    });

    // Construct the request body
    request.body = jsonEncode({
      'email': userdata.email,
      'password': userdata.password,
      'date_birth': userdata.birthDate,
      'first_name': userdata.fullName.split(' ').first,
      'last_name': userdata.fullName.split(' ').last,
      'mobile': userdata.phoneNumber,
      'country': 'SG', // Adjust as needed
      'address': userdata.location,
      'job': userdata.job
    });

    // Send the request and get the response
    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);

    // Process the response
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      print("User details updated successfully. Response: ${jsonResponse['data']}");

      // Update profile fields in the user object
      user?.data.firstName = userdata.fullName.split(' ').first;
      user?.data.lastName = userdata.fullName.split(' ').last;

      // Save updated user object back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user?.toJson()));

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'User details updated successfully',
      };
    } else {
      print("Failed to update user details. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': jsonDecode(response.body)['message'] ?? 'An error occurred',
      };
    }
  } catch (e) {
    // Handle exceptions and log them (optional)
    print("Error in registerUserDetails: $e");
    return {
      'success': false,
      'statusCode': 500, // Internal Server Error
      'message': "Error in registerUserDetails: $e",
    };
  }
}


  
  // Method to call the registerUser API
   Future<bool>  gregisterUser(String displayName,String email) async {
    try {  

   List<String> nameParts = displayName.split(' ');

String firstName = nameParts.length > 1 
    ? nameParts.sublist(0, nameParts.length - 1).join(' ')  // Everything except the last word
    : displayName; // If there's only one word, use it as first name

String lastName = nameParts.length > 1 
    ? nameParts.last  // The last word as last name
    : '';  // If there's only one word, last name is empty

      // API URL
      final String url = 'https://cgmember.com/api/signup';
      print('gregister first last name emailsplit $firstName $lastName  $email');
      // Request body as a Map
      final Map<String, String> requestBody = {
        'email': email,
        'password': 'crazii1234',
        'date_birth':'1900-12-12',
        'first_name': firstName,
        'last_name': lastName,
        'mobile': '1000010000',
        'country': 'SG', // You can replace this dynamically if needed
        'address': 'SG',
        'job': 'None',
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', 
        },
        body: requestBody,
      );

      print('*** response gregister1 ${response.statusCode} ${response.body}');

       if ( response.statusCode == 400) {
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          if (responseData.containsKey('email')) {
                  print('Email already registered: ${responseData['email']}');
                   ApiService apiService = ApiService();
                  User? user = await apiService.signIn(email, 'crazii1234');
                  return true; // Email is already registered
            }
          } catch (e) {
            print('Error parsing response: $e');
          }
        }
        
    
    } catch (e) {
       print('exception gsignin $e');
    }
    return false;
  }

  // ==========================
// CREATE CRYPTO ORDER (FINAL)
// ==========================
Future<Map<String, dynamic>> createCryptoOrder({
  required double amount,
  required String currency,
  required String description,
}) async {
  try {
    // API URL
    final Uri url = Uri.parse("$baseUrl/api/nowpayments/create");

    // Get access token if required
    String? accessToken = await SharedPreferencesHelper.getAccessToken();

    // Prepare body exactly as backend expects
    Map<String, dynamic> requestBody = {
      "amount": amount,
      "currency": currency,
      "description": description,
    };

    print("CRYPTO ORDER → URL: $url");
    print("CRYPTO ORDER → BODY: $requestBody");

    // Send request
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (accessToken != null) "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(requestBody),
    );

    print("CRYPTO ORDER RESPONSE: ${response.body}");

    // Parse response
    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": response.body,
      };
    }
  } catch (e) {
    print("CRYPTO ORDER ERROR: $e");
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}

}

 