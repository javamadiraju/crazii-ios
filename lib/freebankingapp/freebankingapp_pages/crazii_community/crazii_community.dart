import 'package:flutter/material.dart';
import 'community_list_component.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

class CraziiCommunity extends StatefulWidget {
  @override
  _CraziiCommunityState createState() => _CraziiCommunityState();
}

class _CraziiCommunityState extends State<CraziiCommunity> {

  // 🔹 Drawer data (wire API later if needed)
  final String cashCredit = "0";
  final String bonusCredit = "0";
  final String fullName = "User";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('>>> onWillPop triggered');
        return true;
      },
      child: Scaffold(

        // ==================================================
        // ✅ DRAWER ADDED — THIS ENABLES ☰ MENU
        // ==================================================
        drawer: const CraziiDrawer(),


        body: Column(
          children: [
            const SizedBox(
              height: 80,
              child: CraziiHeader(productName: ''),
            ),
              Expanded(
              child: CommunityListComponent(),
            ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: CraziiFooter(selectedIndex: 0),
        ),
      ),
    );
  }
}
