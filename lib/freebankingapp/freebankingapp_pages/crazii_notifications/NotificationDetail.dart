import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class NotificationDetail extends StatefulWidget {
  final String id;
  final String title;
  final String date;
  final String description;

  const NotificationDetail({
    Key? key,
    required this.id,
    required this.title,
    required this.date,
    required this.description,
  }) : super(key: key);

  @override
  _NotificationDetailState createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  AppNotification? notification;
  final unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    loadNotificationDetail();
  }

  void loadNotificationDetail() async {
    final detail = await fetchNotificationDetail(widget.id);
    if (detail != null) {
      setState(() {
        notification = detail;
      });
    }
  }

  Future<AppNotification?> fetchNotificationDetail(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    final String langCode = LanguageUtils.getLanguageCode();

    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    final url = Uri.parse('https://cgmember.com/api/notifications/$token?lang=$langCode');
    final request = http.Request('GET', url)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      if (jsonData['notification'] != null) {
        jsonData['notification']['body'] =
            unescape.convert(jsonData['notification']['body'] ?? '');
        return AppNotification.fromJson(jsonData['notification']);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive values
    final horizontalPadding = screenWidth * 0.05;
    final headerFontSize = screenWidth * 0.055;
    final dateFontSize = screenWidth * 0.025;
    final titleFontSize = screenWidth * 0.04;
    final bodyFontSize = screenWidth * 0.03;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CraziiHeader(productName: ''),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: headerFontSize,
                      fontFamily: 'Exo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.date,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: dateFontSize,
                      fontFamily: 'Exo',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth,
                    height: 2,
                    color: const Color(0xFFD9D9D9),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    'Subject: '+widget.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: titleFontSize,
                      fontFamily: 'Exo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  notification != null
                      ? Html(
                          data: notification!.body ?? '',
                          style: {
                            "body": Style(
                              color: Colors.black87,
                              fontSize: FontSize(bodyFontSize),
                              fontFamily: 'Exo',
                            ),
                          },
                        )
                      : const Text(
                          '',
                          style: TextStyle(color: Colors.black),
                        ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: CraziiFooter(selectedIndex: 1),
    );
  }
}
