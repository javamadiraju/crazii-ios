import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Videos.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_academy/VideoCardComponent.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_academy/crazii_academy.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/select_chart/selectchart.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/quotes/stock_page.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_community/crazii_community.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';

class PendingCourses extends StatelessWidget {
  const PendingCourses({Key? key}) : super(key: key);

  Future<List<String>> _getSavedVideoIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('savedVideoIds') ?? [];
  }

  Future<List<Videos>> _getFilteredVideos(BuildContext context) async {
    List<Videos> allVideos = await ApiService.getVideos(context);
    List<String> savedVideoIds = await _getSavedVideoIds();
    return allVideos.where((v) => savedVideoIds.contains(v.idVideo.toString())).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Icon background colors
    const chartsBG = Color(0xFFFF4F7B);
    const scannerBG = Color(0xFFC76E00);
    const academyBG = Color(0xFF14D18F);
    const communityBG = Color(0xFFFFB200);

    // Quick feature items
    final quickItems = [
      {
        'label': 'charts'.tr,
        'icon': FreeBankingAppSvgicons.chart,
        'bg': chartsBG,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelectChart())),
      },
      {
        'label': 'scanner'.tr,
        'icon': FreeBankingAppSvgicons.scanner,
        'bg': scannerBG,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockPage())),
      },
      {
        'label': 'online_academy'.tr,
        'icon': FreeBankingAppSvgicons.academy,
        'bg': academyBG,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => OnlineAcademy())),
      },
      {
        'label': 'communityh'.tr,
        'icon': FreeBankingAppSvgicons.community,
        'bg': communityBG,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => CraziiCommunity())),
      },
    ];

    // Build 4 icons in one row
    Widget buildWebStyleIconRow() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: quickItems.map((item) {
            return GestureDetector(
              onTap: item['onTap'] as VoidCallback,
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item['bg'] as Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      item['icon'] as String,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Exo',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1436),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildWebStyleIconRow(),

          const Divider(color: Color(0xFFD9D9D9), thickness: 1),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'left_items'.tr,
              style: const TextStyle(
                fontFamily: 'Exo',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),

          // Pending videos list
          FutureBuilder<List<Videos>>(
            future: _getFilteredVideos(context),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(child: Text(""));
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snap.data!
                    .map((v) => VideoCardComponent(
                          id: v.idVideo,
                          title: v.videoName,
                          description: v.description,
                          level: v.level,
                          videoFile: v.videoFile,
                          category: 'F',
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
