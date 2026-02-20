import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';


class HeaderPaymentCard extends StatelessWidget {
  const HeaderPaymentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.black,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              FreeBankingAppPngimage.crazii,
              width: 98,
              height: 21.66,
              fit: BoxFit.contain,
            ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 22,
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB38F3F),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontFamily: 'Exo',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16.0),
                const Text(
                  'Top-up Credits',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Exo',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

