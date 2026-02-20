import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class CraziiDrawer extends StatefulWidget {
  const CraziiDrawer({Key? key}) : super(key: key);

  @override
  State<CraziiDrawer> createState() => _CraziiDrawerState();
}

class _CraziiDrawerState extends State<CraziiDrawer> {
  final ApiService apiService = ApiService();
  late Future<User> _userFuture;

  static const Color brandOrange = Color(0xFFBF7000);
  static const Color sectionBg = Color(0xFFF5F5F5);
  static const String baseUrl = "https://cgmember.com";

  @override
  void initState() {
    super.initState();
    _userFuture = apiService.getUserData();
  }


// ====================================================
// 🔴 LOGOUT CONFIRMATION
// ====================================================
Future<void> _confirmAndLogout(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('confirm_logout'.tr),
      content: Text('confirm_logout_msg'.tr),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('logout'.tr),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await _performLogout(context);
  }
}

// ====================================================
// 🔴 LOGOUT API + CLEAR STORAGE
// ====================================================
Future<void> _performLogout(BuildContext context) async {
   try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user');

      if (userJson == null) {
        print("❗ User data not found in SharedPreferences.");
        return;
      }

      final User user = User.fromJson(jsonDecode(userJson));
      // ✅ FIX: Use the correct property 'idUser' from the UserData model
      final String userId = user.data.idUser;

      if (userId.isEmpty) {
        print("⚠️ user_id not found in user.data.idUser");
        print("📋 User data: ${user.data}");
        return;
      }

      // Logout request
      final String langCode = LanguageUtils.getLanguageCode();
      print('user_id for logout: $userId');

      var response = await http.post(
        Uri.parse('https://cgmember.com/api/user-activity/logout?lang=$langCode'), 
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        print("✅ Logout response: ${response.body}");
      } else {
        print("❌ Logout failed");
  print("❌ Status code: ${response.statusCode}");
  print("❌ Response body: ${response.body}");
      }

      // Clear local storage
      await prefs.clear();
      
      // ✅ Clear persistent login flag
      await prefs.setBool('isLoggedIn', false);

      // Navigate to sign-in
      Get.offAll(() => const CraziiAppSignIn());
    } catch (e) {
      print("❗ Logout exception: $e");
    }
}


  @override
  Widget build(BuildContext context) {
    final drawerHeight = MediaQuery.of(context).size.height;

    return Drawer(
      child: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load user data',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!.data;

          final fullName =
              '${data.firstName ?? ''} ${data.lastName ?? ''}'.trim();

          final cashCredit = data.credit ?? "0";
          final bonusCredit = data.bonusCredit ?? "0";

          // ✅ Build full profile image URL safely
          final String? picturePath = data.picture;
          final String? profileImageUrl = (picturePath != null &&
                  picturePath.isNotEmpty &&
                  !picturePath.contains("default-user.png"))
              ? (picturePath.startsWith("http")
                  ? picturePath
                  : "$baseUrl$picturePath")
              : null;

          return Column(
            children: [
              // ====================================================
              // 🔹 TOP PROFILE SECTION
              // ====================================================
              SizedBox(
                height: drawerHeight * 0.10,
                child: Container(
                  color: sectionBg,
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: brandOrange,
                        backgroundImage:
                            profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null,
                        child: profileImageUrl == null
                            ? const Icon(Icons.person,
                                size: 18, color: Colors.white)
                            : null,
                        onBackgroundImageError: (_, __) {
                          debugPrint("❌ Profile image failed to load");
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fullName.isNotEmpty ? fullName : 'Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Exo",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ====================================================
              // 🔹 CREDIT SECTION
              // ====================================================
              Container(
                width: double.infinity,
                color: brandOrange,
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cash_credit'.tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cashCredit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'bonus_credit'.tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bonusCredit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // 🔹 MENU
              // ====================================================
              Expanded(
                child: Container(
                  color: sectionBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'menu'.tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
