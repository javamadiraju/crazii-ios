import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/crazii_notifications.dart'; // Import Notifications Page
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
class HeaderSub extends StatefulWidget {
  const HeaderSub({Key? key}) : super(key: key);

  @override
  _HeaderSubState createState() => _HeaderSubState();
}

class _HeaderSubState extends State<HeaderSub> {
  final ApiService apiService = ApiService();
  int notifcount = 0;

  @override
  void initState() {
    super.initState();
    fetchNotificationCount();
  }

  Future<void> fetchNotificationCount() async {
    try {
      List<AppNotification>? notifications = await apiService.checkNotifications();
      setState(() {
        notifcount = notifications?.where((n) => !n.isRead).length ?? 0;
      });

    } catch (e) {
      print("Error fetching notifications7: $e");
      setState(() {
        notifcount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFBE5E00), Color(0xFFBE5E00).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Top row with logo, notification, and credit
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                FreeBankingAppPngimage.crazii,
                width: 120,
                height: 30,
                fit: BoxFit.contain,
              ),
              GestureDetector(
                onTap: () async {
                  try {

                    List<AppNotification>? notifications = await apiService.checkNotifications();
                    setState(() {
                      notifcount = notifications?.where((n) => !n.isRead).length ?? 0;
                    });                 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Notifications(notifications: notifications),
                      ),
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "No notifications available",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications, color: Colors.white, size: 28),
                    if (notifcount > -1)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB38F3F),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$notifcount',
                              style: const TextStyle(
                                fontFamily: 'Exo',
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
