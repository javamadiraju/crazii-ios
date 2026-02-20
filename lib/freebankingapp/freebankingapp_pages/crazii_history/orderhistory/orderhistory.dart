import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

import 'TabNavigationComponent.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  // 🔹 Replace with real values from API/state later
  final String cashCredit = "120";
  final String bonusCredit = "30";
  final String fullName = "Eric Rao";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // ✅ DRAWER ATTACHED HERE
      // ==================================================
      drawer: const CraziiDrawer(),


      body: Column(
        children: [
          // ==========================
          // HEADER (MENU ICON WORKS)
          // ==========================
          const CraziiHeader(productName: 'history'),

          // ==========================
          // PAGE CONTENT
          // ==========================
          Expanded(
            child: OrderHistoryTabNavigationComponent(
              isOrderHistorySelected: false,
            ),
          ),
        ],
      ),

      // ==========================
      // FOOTER
      // ==========================
      bottomNavigationBar: SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 3),
      ),
    );
  }
}
