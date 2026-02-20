import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Header.dart';
import 'pendingcourses.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

// ✅ RouteObserver (already defined in main.dart)
import 'package:freebankingapp/main.dart';

class CraziiHome extends StatefulWidget {
  const CraziiHome({Key? key}) : super(key: key);

  @override
  State<CraziiHome> createState() => _CraziiHomeState();
}

class _CraziiHomeState extends State<CraziiHome> with RouteAware {
  int _selectedIndex = 0;

  /// 🔑 Header = single source of truth
  final GlobalKey<HeaderState> _headerKey = GlobalKey<HeaderState>();

  // -------------------------------------------------------
  // 🔄 HEADER REFRESH (SAFE)
  // -------------------------------------------------------
  void _refreshHeader() {
    final header = _headerKey.currentState;
    if (header != null) {
      debugPrint("🔄 Refreshing header data");
      header.refreshData1();
    }
  }

  // -------------------------------------------------------
  // 🔄 ROUTE AWARE LIFECYCLE
  // -------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHeader();
    });
  }

  @override
  void didPopNext() {
    debugPrint('⬅️ Returned to CraziiHome');
    _refreshHeader();
  }

  // -------------------------------------------------------
  // 🏠 BUILD
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final header = _headerKey.currentState;

    return Scaffold(
      // 🔥 Refresh drawer values when opened
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          _refreshHeader();
        }
      },

      // ===================== DRAWER =====================
      drawer: const CraziiDrawer(),


      // ===================== BODY =====================
      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 HEADER
            Header(key: _headerKey),

            /// 🔥 MAIN CONTENT
            const Expanded(
              child: PendingCourses(),
            ),
          ],
        ),
      ),

      // ===================== FOOTER =====================
      bottomNavigationBar: SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: _selectedIndex),
      ),
    );
  }
}
