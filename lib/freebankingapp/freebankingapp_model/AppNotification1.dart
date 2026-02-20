import 'dart:convert';

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
  final DateTime expiry;

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
    required this.expiry,
  });

  // Factory constructor to create an instance from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      idNotification: json['id_notification'] ?? 'Unknown ID',
      userSender: json['user_sender'] ?? 'Unknown Sender',
      userRecipient: json['user_recipient'] ?? 'Unknown Recipient',
      country: json['country'] ?? 'Unknown Country',
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      image: json['image'] ?? '', // Default to empty string if not provided
      isRead: json['is_read'] == "1", // Corrected boolean parsing

      token: json['token'] ?? '', // Defaulting token to an empty string

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      expiry: json['expiry'] != null
          ? DateTime.tryParse(json['expiry']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
