import 'package:flutter/material.dart';
import '../historyapi.dart';
import 'OrderHistoryTableComponent.dart';
import '../credithistory/CreditHistoryTableComponent.dart';
import 'package:get/get.dart';

class OrderHistoryTabNavigationComponent extends StatelessWidget {
  OrderHistoryTabNavigationComponent({
    Key? key,
    this.isOrderHistorySelected = true,
  }) : super(key: key);

  final bool isOrderHistorySelected;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: isOrderHistorySelected ? 0 : 1,
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildCustomTabBar(),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                OrderHistoryTableComponent(),
                CreditHistoryTableComponent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TabBar(
        indicatorColor: Colors.blue,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs:   [
          Tab(text: "history".tr),
          Tab(text: "sales".tr),
        ],
      ),
    );
  }
}
