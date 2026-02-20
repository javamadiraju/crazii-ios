import 'package:flutter/material.dart';

import 'ProfileInfoComponent.dart';
import 'AccountDetailsComponent.dart';
import 'NotificationToggleComponent.dart';
import 'LogoutComponent.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_profile/profileapi.dart';

class CraziiProfile extends StatefulWidget {
  const CraziiProfile({Key? key}) : super(key: key);

  @override
  State<CraziiProfile> createState() => _CraziiProfileState();
}

class _CraziiProfileState extends State<CraziiProfile> {
  String username = "Default Username";

  final ApiService apiService = ApiService();
  final ProfileApiService papiService = ProfileApiService();

  // 🔹 These can later be sourced from API/state
  String cashCredit = "120";
  String bonusCredit = "30";

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = await apiService.getUserData();
      setState(() {
        username = '${user.data.firstName} ${user.data.lastName}';
      });
    } catch (e) {
      debugPrint("Error fetching username: $e");
      setState(() {
        username = "Unknown User";
      });
    }
  }

  void updateUsername(String newUsername) {
    setState(() {
      username = newUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // ✅ DRAWER ATTACHED HERE
      // ==================================================
      drawer: const CraziiDrawer(),


      backgroundColor: Colors.white,

      body: Column(
        children: [
          // ==========================
          // HEADER (MENU ICON OPENS DRAWER)
          // ==========================
          CraziiHeader(productName: ''),

          // ==========================
          // PAGE CONTENT
          // ==========================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInfoComponent(username: username),
                  const SizedBox(height: 20),
                  AccountDetailsComponent(
                    onUsernameChanged: updateUsername,
                  ),
                  const SizedBox(height: 20),
                  NotificationToggleComponent(),
                  const SizedBox(height: 20),
                  LogoutComponent(),
                ],
              ),
            ),
          ),
        ],
      ),

      // ==========================
      // FOOTER
      // ==========================
      bottomNavigationBar: SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 4),
      ),
    );
  }
}
