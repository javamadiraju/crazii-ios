import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainContentComponent extends StatelessWidget {
  const MainContentComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 360,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
             "tutorial_videos".tr,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Exo',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            height: 1,
            color: Color(0xFFD9D9D9),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}



