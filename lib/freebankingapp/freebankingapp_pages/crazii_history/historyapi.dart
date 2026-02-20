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
import 'package:freebankingapp/freebankingapp/freebankingapp_model/InvoiceDetail.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Videos.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Product.dart';   
import 'package:flutter/material.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/credit_history.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/order_history.dart';
import 'package:get/get.dart';

class HistoryApi {

  List<CreditHistory> historyList = [];


Future<List<InvoiceDetail>> fetchInvoiceDetails() async {
  List<InvoiceDetail> invoiceList = [];

  try {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    final String? userJson = prefs.getString('user');
    if (userJson == null) {
      throw Exception("User data not found in SharedPreferences.");
    }

    final User user = User.fromJson(jsonDecode(userJson));
    final String idUser = user.data.idUser;
    String lang = Get.locale?.languageCode ?? 'en';
    final String url = 'https://cgmember.com/api/invoice-details/$idUser?lang=$lang';
    print('URL for invoice details: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response body for invoice-details: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final List<dynamic> invoiceItems = jsonResponse['invoices'] ?? [];

      invoiceList =
          invoiceItems.map((item) => InvoiceDetail.fromJson(item)).toList();

      return invoiceList;
    } else {
      print('Failed to load invoices: ${response.reasonPhrase}');
      return [];
    }
  } catch (e) {
    print('Error fetching invoices: $e');
    return [];
  }
}
 
Future<List<CreditHistory>> fetchCreditHistory() async {  
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
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
    String id1 = user.data.idUser;
     String lang = Get.locale?.languageCode ?? 'en';

     String url = "https://cgmember.com/api/credits-purchased/$id1?lang=$lang";
    print('url for credits purchased : $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    print('response for credits1-purchased ${response.body}');
   if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Extract the list from "creditsPurchased"
      final List<dynamic> creditsList = jsonResponse['creditsPurchased'] ?? [];

      // Map each item in the list to a CreditHistory object
      historyList = creditsList.map((item) => CreditHistory.fromJson(item)).toList();

      return historyList;
    } else {
      print('Failed to load data: ${response.reasonPhrase}');
      return [];
    }

      } catch (e) {
        print('Error: $e');
        return [];
  }
}




Future<List<Invoice>> fetchOrderHistory() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    // Retrieve user information
    final String? userJson = prefs.getString('user');
    if (userJson == null) {
      throw Exception("User data not found in SharedPreferences.");
    }

    final User user = User.fromJson(jsonDecode(userJson));
    final String userId = user.data.idUser;
    String lang = Get.locale?.languageCode ?? 'en';
    final String url = "https://cgmember.com/api/order-history/$userId?lang=$lang";
    print('Fetching order history from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        // You can set cookie manually here if needed
        // 'Cookie': 'ci_session=YOUR_SESSION_VALUE',
      },
    );

    print('Response body for order-history: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> invoicesJson = jsonResponse['invoices'] ?? [];

      final List<Invoice> invoices =
          invoicesJson.map((item) => Invoice.fromJson(item)).toList();

      return invoices;
    } else {
      print('Failed to fetch order history: ${response.reasonPhrase}');
      return [];
    }
  } catch (e) {
    print('Error while fetching order history: $e');
    return [];
  }
}

 
}