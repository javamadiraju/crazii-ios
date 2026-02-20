import 'package:flutter/material.dart';
import '../credithistory/CreditHistoryTableComponent.dart';
import '../orderhistory/OrderHistoryTableComponent.dart';

class CreditTabNavigationComponent extends StatefulWidget {
  const CreditTabNavigationComponent({Key? key}) : super(key: key);

  @override
  State<CreditTabNavigationComponent> createState() =>
      _CreditTabNavigationComponentState();
}

class _CreditTabNavigationComponentState
    extends State<CreditTabNavigationComponent> 

    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isOrderHistorySelected ? 0 : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          /// ---- TABS ----
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(100),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              labelColor: const Color(0xFFB38F3F),
              unselectedLabelColor: const Color(0xFFA8A7A5),
              tabs:   [
               Tab(text: "History".tr),
              Tab(text: "Sales".tr),
              ],
            ),
          ),

          /// ---- TAB CONTENT ----
          Expanded(
            child: TabBarView(
              controller: _tabController,
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
}
