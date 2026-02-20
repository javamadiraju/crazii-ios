import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_detail_screen.dart'; // this is actually NotificationDetail
import 'NotificationDetail.dart'; // this is actually NotificationDetail
import '../../../main.dart';

class NotificationChecker extends StatefulWidget {
  final Widget child;

  const NotificationChecker({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationChecker> createState() => _NotificationCheckerState();
}

class _NotificationCheckerState extends State<NotificationChecker> {
  static const platform = MethodChannel('notification_channel');
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();

    // Listen for native notification clicks
    platform.setMethodCallHandler((call) async {
      if (call.method == 'notificationClick') {
        final data = Map<String, dynamic>.from(call.arguments);
        _handleNotificationClick(data);
      }
    });
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationClick(jsonDecode(response.payload!));
        }
      },
    );

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

void _handleNotificationClick(Map<String, dynamic> data) {
  final id = data['token'] ?? ''; // API id / token
  final title = data['title'] ?? '';
  final date = data['created_at'] ?? '';
  final description = data['body'] ?? '';

  

  // Print notification details
  print('📩 Notification Clicked:');
  print('ID/Token: $id');
  print('Title: $title');
  print('Date: $date');
  print('Description: $description');

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => NotificationDetail(
        id: id,
        title: title,
        date: date,
        description: description,
      ),
    ),
  );
}


  /// Call this to show a local notification with token + created_at included
  Future<void> showNotification({
    required String title,
    required String body,
    required String token,
    required String createdAt,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final payload = jsonEncode({
      'title': title,
      'body': body,
      'token': token,
      'created_at': createdAt,
    });

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
