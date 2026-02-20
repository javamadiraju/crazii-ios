import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';

class AppNotification {
  final String idNotification;
  final String userSender;
  final String userRecipient;
  final String country;
  final String title;
  final String body;
  final String image;
  final bool isRead;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiry;

  AppNotification({
    required this.idNotification,
    required this.userSender,
    required this.userRecipient,
    required this.country,
    required this.title,
    required this.body,
    required this.image,
    required this.isRead,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    this.expiry,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      idNotification: json['id_notification']?.toString() ?? '',
      userSender: json['user_sender']?.toString() ?? '',
      userRecipient: json['user_recipient']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: decodeHtml(json['body']?.toString() ?? ''),
      image: json['image']?.toString() ?? '',
      isRead: json['is_read']?.toString() == '1',
      token: json['token']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      expiry: json['expiry'] != null ? DateTime.tryParse(json['expiry'].toString()) : null,
    );
  }
}

String decodeHtml(String input) {
  return HtmlUnescape().convert(input); // You may need `html_unescape` package
}
