import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class LogoutComponent extends StatelessWidget {
  const LogoutComponent({Key? key}) : super(key: key);

  // ───────────────────────────────────────────────────────────────
  // CONFIRMATION POPUP (AlertDialog)
  // ───────────────────────────────────────────────────────────────
  Future<void> _confirmAndLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'confirm_logout'.tr,
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'confirm_logout_msg'.tr,
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'cancel'.tr,
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                "logout".tr,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _performLogout(context);
    }
  }

  // ───────────────────────────────────────────────────────────────
  // LOGOUT API + CLEAR STORAGE
  // ───────────────────────────────────────────────────────────────
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

  // ───────────────────────────────────────────────────────────────
  // UI WIDGET
  // ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}