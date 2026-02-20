import 'package:flutter/material.dart';

import 'HeaderComponent.dart';
import 'CreditInfoComponent.dart';
import 'UserStatusComponent.dart';
import 'TabNavigationComponent.dart';
import 'CreditHistoryTableComponent.dart';
import 'FooterNavigationComponent.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';

class CreditHistoryScreen extends StatelessWidget {
  CreditHistoryScreen({Key? key}) : super(key: key);

  // 🔹 Replace with real values from API/state if needed
  final String cashCredit = "120";
  final String bonusCredit = "30";
  final String fullName = "Eric Rao";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // ✅ DRAWER ATTACHED HERE (THIS ENABLES MENU ICON)
      // ==================================================
      drawer: const CraziiDrawer(),


      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              FreeBankingAppPngimage.credithistorybg,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // =========================
            // HEADER (MENU OPENS DRAWER)
            // =========================
            HeaderComponent(),

            CreditInfoComponent(),
            UserStatusComponent(),
            CreditTabNavigationComponent(),

            Expanded(
              child: CreditHistoryTableComponent(),
            ),
          ],
        ),
      ),

      // =========================
      // FOOTER
      // =========================
      bottomNavigationBar: FooterNavigationComponent(),
    );
  }
}
