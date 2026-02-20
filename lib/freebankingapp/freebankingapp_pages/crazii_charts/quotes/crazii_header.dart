import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/crazii_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CraziiHeader extends StatelessWidget {
  final String productName;

  const CraziiHeader({Key? key, required this.productName}) : super(key: key);

  Future<int> fetchNotificationCount() async {
    final ApiService apiService = ApiService();
    try {
      List<AppNotification>? notifications = await apiService.checkNotifications();
      return notifications?.where((n) => !n.isRead).length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<AppNotification>?> fetchNotifications() async {
    final ApiService apiService = ApiService();
    try {
      return await apiService.checkNotifications();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "No notifications available",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // White background
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// LEFT — Logo & Title
            Row(
              children: [
                Image.asset(
                  FreeBankingAppPngimage.crazii,
                  width: 98,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'Exo',
                  ),
                ),
              ],
            ),

            /// RIGHT — Notification Icon
            FutureBuilder<int>(
              future: fetchNotificationCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  );
                }
                final count = snapshot.data ?? 0;

                return GestureDetector(
                  onTap: () async {
                    List<AppNotification>? notifications = await fetchNotifications();
                    if (notifications != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Notifications(notifications: notifications),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 30,
                        color: Colors.black,
                      ),
                      if (count > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 153, 51, 1), // orange
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
