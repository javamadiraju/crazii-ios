import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'NotificationItemComponent.dart';
import 'package:get/get.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_model/AppNotification.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';

 class Notifications extends StatelessWidget {
  final List<AppNotification>? notifications;

  const Notifications({Key? key, this.notifications}) : super(key: key);

  bool get _hasValidNotifications =>
      notifications != null && notifications!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: Column(
        children: [
          // ================= HEADER =================
          CraziiHeader(productName: 'notifications'.tr),

          // ================= BODY =================
          Expanded(
            child: _hasValidNotifications
                ? _buildNotificationList()
                : _buildEmptyState(context),
          ),
        ],
      ),

      // ================= FOOTER =================
      bottomNavigationBar: SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 0),
      ),
    );
  }

  // -------------------------------------------------
  // ✅ NOTIFICATION LIST
  // -------------------------------------------------
  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: notifications!.length,
      itemBuilder: (context, index) {
        final notification = notifications![index];

        String formattedDate = '—';
        if (notification.createdAt != null) {
          formattedDate = DateFormat('yyyy-MM-dd')
              .format(notification.createdAt.toLocal());
        }

        return NotificationItemComponent(
          id: notification.token ?? "0",
          title: notification.title ?? '—',
          date: formattedDate,
          description: notification.title ?? '',
          iconUrl: FreeBankingAppPngimage.notificationd,
          isRead: notification.isRead ? 1 : 0,
        );
      },
    );
  }

  // -------------------------------------------------
  // ✅ EMPTY STATE UI
  // -------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontFamily: "Exo",
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'no_records'.tr,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
              fontFamily: "Exo",
            ),
          ),
        ],
      ),
    );
  }
}
