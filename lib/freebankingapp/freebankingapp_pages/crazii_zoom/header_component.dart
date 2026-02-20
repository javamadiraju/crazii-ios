import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget {
  final String logoUrl;
  final String profileImageUrl;
  final int notificationCount;

  const HeaderComponent({
    Key? key,
    this.logoUrl = 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/logo-cra.png',
    this.profileImageUrl = 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/image-66.png',
    this.notificationCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB0380F), Color(0xFFB0380F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Image.network(
            logoUrl,
            width: 98,
            height: 21.66,
            fit: BoxFit.contain,
          ),
          
          // Notification section
          Stack(
            children: [
              // Profile image
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(profileImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Notification badge
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB38F3F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$notificationCount',
                      style: TextStyle(
                        fontFamily: 'Exo',
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
