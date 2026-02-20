import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/crazii_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HeaderComponent extends StatelessWidget {
  const HeaderComponent({Key? key}) : super(key: key);

  // Fetch notification count
  Future<int> fetchNotificationCount() async {
    final ApiService apiService = ApiService();
    try {
      List<AppNotification>? notifications = await apiService.checkNotifications();
      return notifications?.length ?? 0;
    } catch (e) {
      print("Error fetching notifications2: $e");
      return 0;
    }
  }

  // Fetch notifications list
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
    height: 80,
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFB0380F),
          Color(0xFFB0380F).withOpacity(0.8),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: Stack(
      children: [
        // Empty space (row) above the logo
        Positioned(
          top: 0, // Position at the top
          left: 0,
          right: 0,
          child: SizedBox(
            height: 10, // Adjust the height for the empty space
          ),
        ),

        // Logo aligned to the left (will be below the empty space)
        Positioned(
          bottom: 0, // Position at the bottom within the container
          left: 0,
          child: Image.asset(
            FreeBankingAppPngimage.crazii,
            width: 98,
            height: 22,
          ),
        ),

        // Notification icon with dynamic count aligned to the right
        Positioned(
          bottom: 0, // Position at the bottom within the container
          right: 0,
          child: FutureBuilder<int>(
            future: fetchNotificationCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              } else if (snapshot.hasError) {
                return const Icon(Icons.notifications, color: Colors.white, size: 22);
              } else {
                final notificationCount = snapshot.data ?? 0;
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
                    } else {
                      print("Error: Notifications list is null");
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        FreeBankingAppPngimage.notification, // Local asset notification icon
                        width: 22,
                        height: 22,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB38F3F),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  fontFamily: 'Exo',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
          Positioned(
          top: 0, // Position at the top
          left: 0,
          right: 0,
          child: SizedBox(
            height: 10, // Adjust the height for the empty space
          ),
        ),

      ],
    ),
  );
}


}
