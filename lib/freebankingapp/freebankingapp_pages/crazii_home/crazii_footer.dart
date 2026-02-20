import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_products/crazii_products.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/crazii_payments.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_history/orderhistory/orderhistory.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_profile/profile_page.dart';

class FreeBankingAppSvgIcons {
  static String home = "assets/appicons/home.svg";
  static String products = "assets/appicons/products.svg";
  static String history = "assets/appicons/history.svg";
  static String profile = "assets/appicons/profile.svg";
}

class CraziiFooter extends StatelessWidget {
  final int selectedIndex;

  const CraziiFooter({Key? key, required this.selectedIndex}) : super(key: key);

  void _navigateToScreen(BuildContext context, int index) {
    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const CraziiHome();
        break;
      case 1:
        nextScreen = const CraziiProducts();
        break;
      case 2:
        nextScreen = const CraziiPayments();
        break;
      case 3:
        nextScreen = const OrderHistoryPage();
        break;
      case 4:
        nextScreen = const CraziiProfile();
        break;
      default:
        nextScreen = const CraziiHome();
    }

    // Prevent re-push of same screen
    if (index == selectedIndex) {
  // Force refresh if already selected
  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CraziiHome()),
    );
  }
  return;
}


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 'home'.tr, FreeBankingAppSvgIcons.home, 0),
          _navItem(context, 'products'.tr, FreeBankingAppSvgIcons.products, 1),
          _navItem(context, 'history'.tr, FreeBankingAppSvgIcons.history, 3),
          _navItem(context, 'profile'.tr, FreeBankingAppSvgIcons.profile, 4),
        ],
      ),
    );
  }

   Widget _navItem(BuildContext context, String label, String svgPath, int index) {
  bool isSelected = selectedIndex == index;

  return Expanded(   // makes underline full width like web
    child: GestureDetector(
      onTap: () => _navigateToScreen(context, index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Full-width underline like web
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: double.infinity,
            height: isSelected ? 3 : 0,
            color: isSelected ? Color(0xFFC76E00) : Colors.transparent,
          ),

          SizedBox(height: 6),

          SvgPicture.asset(
            svgPath,
            width: 22,
            height: 22,
            color: isSelected ? Color(0xFFC76E00) : Color(0xFF0D1436),
          ),

          SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFC76E00) : Color(0xFF0D1436),
              fontFamily: 'Exo',
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

}
