import 'package:flutter/material.dart';
import 'header_component.dart';
import 'zoom_meeting_title_component.dart';
import 'zoom_session_card_component.dart';
import 'teacher_list_component.dart';
import 'bottom_navigation_component.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';

class ZoomMeeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          HeaderComponent(),
          ZoomMeetingTitleComponent(),
          Expanded(
            child: ListView(
              children: [
                ZoomSessionCardComponent( onJoin: () {
                  // Define the onJoin action here
                  print("Joining the Zoom session...");
                },),
                TeacherListComponent(),
              ],
            ),
          ),
        ],
      ),
       bottomNavigationBar: CraziiFooter(selectedIndex: 0),
    );
  }
}

