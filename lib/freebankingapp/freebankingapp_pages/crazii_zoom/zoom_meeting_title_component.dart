import 'package:flutter/material.dart';

class ZoomMeetingTitleComponent extends StatelessWidget {
  final String title;

  const ZoomMeetingTitleComponent({
    Key? key,
    this.title = 'ZOOM MEETING',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Exo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFD9D9D9),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

