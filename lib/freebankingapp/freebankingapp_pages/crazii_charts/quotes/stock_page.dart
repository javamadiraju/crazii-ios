import 'package:flutter/material.dart';

import 'StockTableComponent.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

class StockPage extends StatelessWidget {
  StockPage({Key? key}) : super(key: key);

  // 🔹 Drawer values (wire API later if needed)
  final String cashCredit = "0";
  final String bonusCredit = "0";
  final String fullName = "User";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDF5),

      // ==================================================
      // ✅ DRAWER ENABLED (required for ☰ menu)
      // ==================================================
      drawer: const CraziiDrawer(),


      body: Column(
        children: [
          const SizedBox(
            height: 80,
            child: CraziiHeader(productName: ""),
          ),

          // ⭐ Page Title
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: const Text(
              " ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27173E),
              ),
            ),
          ),

          // ⭐ Divider under title (matches web)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: const Color(0xFFD9D9D9),
          ),

          // ❌ const removed (child is not const)
          Expanded(
            child: StockTableComponent(),
          ),
        ],
      ),

      bottomNavigationBar: const SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 0),
      ),
    );
  }
}
