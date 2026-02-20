import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Videos.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

import 'VideoCardComponent.dart';

class OnlineAcademy extends StatefulWidget {
  const OnlineAcademy({Key? key}) : super(key: key);

  @override
  State<OnlineAcademy> createState() => _OnlineAcademyState();
}

class _OnlineAcademyState extends State<OnlineAcademy> {
  List<Videos> allVideos = [];
  List<Videos> filteredVideos = [];

  late String selectedCategory;

  // 🔹 Temporary values (can be wired to API later)
  String cashCredit = "120";
  String bonusCredit = "30";
  String fullName = "User";

  @override
  void initState() {
    super.initState();
    selectedCategory = 'select_category';
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await ApiService.getVideos(context);
      if (videos != null) {
        setState(() {
          allVideos = videos;
          filteredVideos = [];
        });
      }
    } catch (e) {
      debugPrint("Error loading videos: $e");
    }
  }

  void _filterVideos(String category) {
    setState(() {
      selectedCategory = category;

      if (category == 'select_category') {
        filteredVideos = [];
      } else if (category == 'training') {
        filteredVideos =
            allVideos.where((v) => v.category == "T").toList();
      } else if (category == 'premium') {
        filteredVideos =
            allVideos.where((v) => v.category != "T").toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // ✅ DRAWER ATTACHED HERE
      // ==================================================
      drawer: const CraziiDrawer(),


      backgroundColor: const Color(0xFFEDEDF5),

      body: Column(
        children: [
          // HEADER
          const SizedBox(
            height: 80,
            child: CraziiHeader(productName: ""),
          ),

          // -------------------------------------
          // WEB STYLE CARD – EVERYTHING INSIDE
          // -------------------------------------
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Online Academy",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27173E),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Container(height: 1, color: Color(0xFFD9D9D9)),
                  const SizedBox(height: 18),

                  Text(
                    'select_video_type'.tr,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color(0xFFBF7000), width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'select_category',
                          child: Text('select_category'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'training',
                          child: Text('training'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'premium',
                          child: Text('premium'.tr),
                        ),
                      ],
                      onChanged: (value) {
                        _filterVideos(value!);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(flex: 3, child: Text('name'.tr)),
                      Expanded(flex: 2, child: Text('credits_to_view'.tr)),
                      Expanded(flex: 1, child: Text('action'.tr)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: filteredVideos.isEmpty
                        ? Center(child: Text('no_videos'.tr))
                        : ListView.builder(
                            itemCount: filteredVideos.length,
                            itemBuilder: (context, index) {
                              final video = filteredVideos[index];
                              final isGrey = index % 2 == 0;

                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                color: isGrey
                                    ? const Color(0xFFF3F3F7)
                                    : Colors.white,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(video.videoName),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          video.level == "T" ? "0" : "1"),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VideoApp(
                                                videoUrl: video.videoFile,
                                                videoId: video.idVideo,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFC107),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                        ),
                                        child: Text(
                                          'view'.tr,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
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
