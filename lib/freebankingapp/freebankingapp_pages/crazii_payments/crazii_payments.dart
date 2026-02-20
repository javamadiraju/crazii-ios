import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_fontstyle.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:get/get.dart'; 
 import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/header_payments_card.dart';
 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/payments_page.dart';
 

class CraziiPayments extends StatefulWidget {
  const CraziiPayments({Key? key}) : super(key: key);

  @override
  State<CraziiPayments> createState() => _CraziiPaymentsState();
}

class _CraziiPaymentsState extends State<CraziiPayments> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ 
          Expanded(
            child: TopUpCredits(),
          ),
        ],
      ), 
    );
  }
}
