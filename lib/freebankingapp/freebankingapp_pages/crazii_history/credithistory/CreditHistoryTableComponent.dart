import 'package:flutter/material.dart';
import '../historyapi.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/credit_history.dart';
import 'package:get/get.dart';

class CreditHistoryTableComponent extends StatefulWidget {
  const CreditHistoryTableComponent({Key? key}) : super(key: key);

  @override
  _CreditHistoryTableComponentState createState() =>
      _CreditHistoryTableComponentState();
}

class _CreditHistoryTableComponentState
    extends State<CreditHistoryTableComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<CreditHistory> cashCredits = [];
  List<CreditHistory> bonusCredits = [];

  bool isLoading = true;
  String? errorMessage;

  final HistoryApi historyApi = HistoryApi();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }


String trimToFirstWords(String text, int wordLimit) {
  if (text.isEmpty) return text;

  final words = text.split(RegExp(r'\s+'));
  if (words.length <= wordLimit) return text;

  return words.take(wordLimit).join(' ');
}




  Future<void> _fetchData() async {
    try {
      final data = await historyApi.fetchCreditHistory();

      setState(() {
        cashCredits = data.where((e) => e.creditType == "CASH").toList();
        bonusCredits = data.where((e) => e.creditType == "BONUS").toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load credit history";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // 🔥 MAIN UI (FIXED WITH SizedBox.expand)
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildScrollableBox("cash_credit".tr, cashCredits),
                          _buildScrollableBox("bonus_credit".tr, bonusCredits),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 TAB BAR
  // -------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFBF7000),
        labelColor: const Color(0xFFBF7000),
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs:   [
          Tab(text: "cash_credit".tr),
          Tab(text: "bonus_credit".tr),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 FULL HORIZONTAL SCROLL BOX
  // -------------------------------------------------------------
  Widget _buildScrollableBox(String title, List<CreditHistory> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000,
        child: _buildCreditBox(title, items),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 CREDIT BOX
  // -------------------------------------------------------------
  Widget _buildCreditBox(String title, List<CreditHistory> items) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(title),
            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(),
                  ...items.map(_buildRow).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 SECTION TITLE
  // -------------------------------------------------------------
  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr,
          style: const TextStyle(
            color: Color(0xFFBF7000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Exo",
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: double.infinity,
          color: const Color(0xFFBF7000),
        )
      ],
    );
  }

  // -------------------------------------------------------------
  // 🔥 TABLE HEADER
  // -------------------------------------------------------------
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _headerCell('transaction_id'.tr, 130),
          _headerCell('type'.tr, 80),
          _headerCell('credit'.tr, 70),
          _headerCell('debit'.tr, 70),
          _headerCell('balance'.tr, 130),
          _headerCell('remark'.tr, 300),
          _headerCell('time'.tr, 140),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: "Exo",
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 ROWS
  // -------------------------------------------------------------
  Widget _buildRow(CreditHistory item) {
  final isCredit = item.transactionType.toUpperCase() == "ADD";

  final String creditValue = isCredit ? item.amount : '0';
  final String debitValue  = isCredit ? '0' : item.amount;

  return InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('remark'.tr),
          content: Text(
            item.remark.isNotEmpty ? item.remark : 'no_remark_provided'.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ok'.tr),
            )
          ],
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _rowCell(item.transactionId, 130),
          _rowCell(item.transactionType, 80),

          // ✅ CREDIT
          _rowCell(
            creditValue,
            70,
            color: isCredit ? Colors.green : Colors.grey,
          ),

          // ✅ DEBIT
          _rowCell(
            debitValue,
            70,
            color: !isCredit ? Colors.red : Colors.grey,
          ),

          _rowCell(item.balance, 70),
          _rowCell(
  item.creditType == "CASH"
      ? trimToFirstWords(item.remark, 4)
      : item.remark,
  300,
),

          _rowCell(item.createdAt, 140),
        ],
      ),
    ),
  );
}


  Widget _rowCell(String text, double width, {Color? color}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          color: color ?? Colors.black87,
          fontFamily: "Exo",
        ),
      ),
    );
  }
}
