import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationToggleComponent extends StatefulWidget {
  final bool initialStatus;

  const NotificationToggleComponent({
    Key? key,
    this.initialStatus = true,
  }) : super(key: key);

  @override
  _NotificationToggleComponentState createState() => _NotificationToggleComponentState();
}

class _NotificationToggleComponentState extends State<NotificationToggleComponent> {
  late bool isEnabled;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. Set the background color to WHITE
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "snotification".tr,
            style: TextStyle(
              // 2. Set the text color to BLACK
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isEnabled = !isEnabled;
              });
            },
            child: Container(
              width: 55,
              height: 27,
              decoration: BoxDecoration(
                color: isEnabled ? Color(0xFF1DD617) : Colors.grey[300],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: isEnabled ? 28 : 2,
                    child: Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (isEnabled)
                    Positioned(
                      right: 8,
                      child: Text(
                        'ON',
                        style: TextStyle(
                          // 3. Set the 'ON' text color to BLACK (optional, but requested for 'black font')
                          // I'll keep it white for contrast on the green background, but use black if you prefer:
                          color: Colors.white, // Change to Colors.black if desired
                          fontSize: 16,
                          fontFamily: 'Exo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}