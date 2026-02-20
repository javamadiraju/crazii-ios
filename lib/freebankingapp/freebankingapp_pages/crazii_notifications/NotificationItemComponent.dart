import 'package:flutter/material.dart';
import 'NotificationDetail.dart'; // Import the detail page

class NotificationItemComponent extends StatelessWidget {
  final String id;
  final String title;
  final String date;
  final String description;
  final String? iconUrl;
  final int isRead; // 0 = unread, 1 = read
  final String? assetIconPath = "assets/appicons/notification_dollar.png";

  const NotificationItemComponent({
    Key? key,
    this.id = "0",
    this.title = "Your top-up is successful!!!",
    this.date = "09/01/2025",
    this.description = "You have updated your credits. Use them for the online academy",
    this.iconUrl,
    this.isRead = 1, // Default is read
  }) : super(key: key);

  void _navigateToDetailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetail(
          id: id,
          title: title,
          date: date,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotificationRead = isRead == 1;

    return GestureDetector(
      onTap: () => _navigateToDetailPage(context),
      child: Container(
        constraints: const BoxConstraints(minWidth: 365, minHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
        decoration: BoxDecoration(
          color: isNotificationRead ? Colors.transparent : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  child: Image.asset(
                    assetIconPath!,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color:  isNotificationRead ? Colors.white : Colors.blueGrey,
                                fontSize: 16,
                                fontFamily: 'Exo',
                                fontWeight: isNotificationRead ? FontWeight.w400 : FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'Exo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Exo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: const Color(0xFFD9D9D9),
            ),
          ],
        ),
      ),
    );
  }
}
