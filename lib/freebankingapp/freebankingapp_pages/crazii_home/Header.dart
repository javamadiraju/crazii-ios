import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserGroup.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/crazii_notifications.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_profile/profileapi.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> with WidgetsBindingObserver {
  final ApiService apiService = ApiService();
  final ProfileApiService papiService = ProfileApiService();

  late Future<UserGroup> userGroup;
  String usertitle = "";
  int notifcount = 0;

  String? _profilePicturePath;
  String bonusCredit = "";
  String cashCredit = "";
  String firstName = "";
  String lastName = "";

  // 🌐 Language state
  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshData();
    _fetchLanguages();
    _loadSavedLanguage();
  }

  /// 🔹 Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language');
    if (savedLang != null) {
      _changeLanguage(savedLang);
    }
  }

  /// 🔹 Fetch languages from API
  Future<void> _fetchLanguages() async {
    try {
      final langCode = Get.locale?.languageCode ?? 'en';
      final response = await http.get(Uri.parse('https://cgmember.com/api/get-lang?lang=$langCode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == 200 && data['data'] is List) {
          setState(() {
            _languages = List<String>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print("⚠️ Failed to fetch languages: $e");
    }
  }

  /// 🔹 Change app language dynamically
  Future<void> _changeLanguage(String langCode) async {
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

     
  }

  void refreshData1() async {
    User user1 = await apiService.getRemainingCredits();
    setState(() {
      bonusCredit = user1.data.bonusCredit ?? "0.0";
      cashCredit = user1.data.credit ?? "0.0";
    });
    fetchData();
    fetchNotificationCount();
    loadProfilePicture();
  }

  void refreshData() {
    setState(() {
      userGroup = apiService.getGroupDetails();
    });
    fetchData();
    fetchNotificationCount();
    loadProfilePicture();
  }

  Future<void> fetchData() async {
    try {
      User fetchedUser = await apiService.getUserData();
      UserGroup fetchedUserGroup = await userGroup;

      setState(() {
        usertitle = fetchedUserGroup.groups[0].title;
        bonusCredit = fetchedUser.data.bonusCredit ?? "0.0";
        cashCredit = fetchedUser.data.credit ?? "0.0";
        firstName = fetchedUser.data.firstName;
        lastName = fetchedUser.data.lastName;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchNotificationCount() async {
    try {
      List<AppNotification>? notifications = await apiService.checkNotifications();
      setState(() {
        notifcount = notifications?.where((n) => !n.isRead).length ?? 0;
      });
    } catch (e) {
      print('Error while checking notifications: $e');
      setState(() {
        notifcount = 0;
      });
    }
  }

  Future<void> loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      User user = await apiService.getRemainingCredits();
      final userId = user.data.idUser;
      final userPicture = user.data.picture;

      if (userPicture != null && !userPicture.contains("default-user.png")) {
        String? savedPath = prefs.getString('profile_picture_path_$userId');

        if (savedPath != null && File(savedPath).existsSync()) {
          setState(() {
            _profilePicturePath = savedPath;
          });
        } else {
          String? downloadedPath = await papiService.downloadProfilePicture();
          if (downloadedPath != null && File(downloadedPath).existsSync()) {
            await prefs.setString('profile_picture_path_$userId', downloadedPath);
            setState(() {
              _profilePicturePath = downloadedPath;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading profile picture: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHeader();
  }

   Widget _buildHeader() {
  return Column(
    children: [
      // ============================================================
      // 🔥 TOP ORANGE WEB HEADER (CRAZII + menu + language + bell)
      // ============================================================
      Container(
        width: double.infinity,
        color: const Color(0xFFBF7000),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: SizedBox(
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT MENU
                GestureDetector(
                  onTap: () {
                    
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),

                // TITLE
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

                // RIGHT ICONS
                Row(
                  children: [
                    // Language icon
                    if (_languages.isNotEmpty)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.language,
                            color: Colors.white, size: 26),
                        color: Colors.black87,
                        onSelected: (lang) => _changeLanguage(lang),
                        itemBuilder: (context) {
                          return _languages.map((String lang) {
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
                            return PopupMenuItem<String>(
                              value: lang,
                              child: Text(displayName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            );
                          }).toList();
                        },
                      ),

                    const SizedBox(width: 18),

                    // Notification bell
                    GestureDetector(
                      onTap: () async {
                        try {
                          List<AppNotification>? notifications =
                              await apiService.checkNotifications();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  Notifications(notifications: notifications),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "no_notifications".tr,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications,
                              color: Colors.white, size: 26),

                          if (notifcount > -1)
                            Positioned(
                              right: -2,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF006E), // pink like web
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$notifcount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ============================================================
      // PROFILE ROW (your existing code)
      // ============================================================
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        color: Colors.white,
        
      ),

      // ============================================================
      // CREDIT CARDS ROW (your existing cards)
      // ============================================================
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            // CASH CREDIT CARD
            Expanded(
              child: Card(
                color: const Color(0xFFC76E00),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        'cash_credit'.tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cashCredit',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // BONUS CREDIT CARD
            Expanded(
              child: Card(
                color: Colors.black,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        'bonus_credit'.tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$bonusCredit',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


}
