import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/crazii_notifications.dart';

class CraziiHeader extends StatefulWidget {
  final String productName;

  const CraziiHeader({
    Key? key,
    required this.productName,
  }) : super(key: key);

  @override
  State<CraziiHeader> createState() => _CraziiHeaderState();
}

class _CraziiHeaderState extends State<CraziiHeader> {
  final ApiService apiService = ApiService();

  // =====================================================
  // 🔑 EXPOSED DATA FOR DRAWER (CRITICAL)
  // =====================================================
  String cashCredit = "0";
  String bonusCredit = "0";
  String firstName = "";
  String lastName = "";

  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
    refreshData1(); // 🔑 initial load
  }

  // =====================================================
  // 🔄 CALLED FROM HOME VIA GlobalKey
  // =====================================================
 Future<void> refreshData1() async {
  try {
    final user = await apiService.getUserData();

    setState(() {
      firstName = user.data.firstName;
      lastName  = user.data.lastName;

      // ✅ FIXED FIELD NAMES
      cashCredit  = user.data.credit;        // cash_credit
      bonusCredit = user.data.bonusCredit;   // bonus_credit
    });
  } catch (e) {
    debugPrint("Header refresh error: $e");
  }
}

  // =====================================================
  // 🌍 LANGUAGE
  // =====================================================
  Future<void> _fetchLanguages() async {
    try {
      final langCode = Get.locale?.languageCode ?? 'en';
      final response =
          await http.get(Uri.parse('https://cgmember.com/api/get-lang?lang=$langCode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == 200 && data['data'] is List) {
          setState(() {
            _languages = List<String>.from(data['data']);
          });
        }
      }
    } catch (_) {}
  }

  void _changeLanguage(String langCode) {
    Locale newLocale;
    switch (langCode) {
      case 'zh':
        newLocale = const Locale('zh', 'CN');
        break;
      case 'vi':
        newLocale = const Locale('vi', 'VN');
        break;
      default:
        newLocale = const Locale('en', 'US');
    }
    Get.updateLocale(newLocale);
       
  }

  // =====================================================
  // 🔔 NOTIFICATIONS
  // =====================================================
  Future<int> fetchNotificationCount() async {
    try {
      final notifications = await apiService.checkNotifications();
      return notifications?.where((n) => !n.isRead).length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<AppNotification>?> fetchNotifications() async {
    try {
      return await apiService.checkNotifications();
    } catch (_) {
      Fluttertoast.showToast(msg: "no_notifications".tr);
      return null;
    }
  }

  // =====================================================
  // 🧱 UI (UNCHANGED)
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFBF7000),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// ☰ MENU
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    debugPrint("MENU CLICKED");
                    Scaffold.of(ctx).openDrawer();
                  },
                  child: const Icon(Icons.menu,
                      color: Colors.white, size: 26),
                ),
              ),

              /// TITLE
              const Text(
                "CRAZII",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: "Exo",
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              /// RIGHT ICONS
              Row(
                children: [
                  if (_languages.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.language,
                          color: Colors.white, size: 26),
                      color: Colors.black87,
                      onSelected: _changeLanguage,
                      itemBuilder: (_) => _languages.map((lang) {
                        String displayName = lang.toUpperCase();
                        switch (lang) {
                          case 'en':
                            displayName = '🇺🇸 English';
                            break;
                          case 'vi':
                            displayName = '🇻🇳 Vietnamese';
                            break;
                          case 'zh':
                            displayName = '🇨🇳 中文';
                            break;
                        }
                        return PopupMenuItem(
                          value: lang,
                          child: Text(
                            displayName,
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(width: 14),

                  FutureBuilder<int>(
                    future: fetchNotificationCount(),
                    builder: (_, snapshot) {
                      final count = snapshot.data ?? 0;

                      return GestureDetector(
                        onTap: () async {
                          final notifications =
                              await fetchNotifications();
                          if (notifications != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Notifications(
                                    notifications: notifications),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications,
                                color: Colors.white, size: 26),
                            Positioned(
                              right: -2,
                              top: -4,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF006E),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
