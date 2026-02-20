import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

import 'products_page.dart';

class CraziiProducts extends StatefulWidget {
  const CraziiProducts({Key? key}) : super(key: key);

  @override
  State<CraziiProducts> createState() => _CraziiProductsState();
}

class _CraziiProductsState extends State<CraziiProducts> {
  // 🔹 Replace these with real values from API/state if needed
  final String cashCredit = "120";
  final String bonusCredit = "30";
  final String fullName = "Eric Rao";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================
      // ✅ DRAWER ATTACHED HERE
      // ==========================
      drawer: const CraziiDrawer(),


      body: Column(
        children: [
          // ==========================
          // HEADER (MENU ICON OPENS DRAWER)
          // ==========================
          CraziiHeader(productName: 'products'),

          // ==========================
          // PAGE CONTENT
          // ==========================
          Expanded(
            child: ProductsPage(),
          ),
        ],
      ),

      // ==========================
      // FOOTER
      // ==========================
      bottomNavigationBar: SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 1),
      ),
    );
  }
}
