import 'package:flutter/material.dart';
import '../historyapi.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/order_history.dart';
import 'package:get/get.dart';

class OrderHistoryTableComponent extends StatefulWidget {
  const OrderHistoryTableComponent({Key? key}) : super(key: key);

  @override
  _OrderHistoryTableComponentState createState() =>
      _OrderHistoryTableComponentState();
}

class _OrderHistoryTableComponentState
    extends State<OrderHistoryTableComponent> {
  List<Invoice> orderItems = [];
  bool isLoading = true;
  String? errorMessage;

  final HistoryApi historyApi = HistoryApi();

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    try {
      final data = await historyApi.fetchOrderHistory();
      setState(() {
        orderItems = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = "Failed to load order history";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 400,
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      margin: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 650,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // ⭐ Important fix
                      children: [
                        _buildTableHeader(),
                        const SizedBox(height: 10),
                        _buildScrollableRows(), // ⭐ No Expanded anymore
                      ],
                    ),
                  ),
                ),
    );
  }

  // -------------------------------------------------
  // ⭐ FIXED SCROLLABLE ROWS (NO EXPANDED)
  // -------------------------------------------------
  Widget _buildScrollableRows() {
    return SizedBox(
      height: 300, // ⭐ Give bounded height (required)
      child: SingleChildScrollView(
        child: Column(
          children: orderItems.map(_buildTableRow).toList(),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // TABLE HEADER
  // -------------------------------------------------
  Widget _buildTableHeader() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120),
        1: FixedColumnWidth(200),
        2: FixedColumnWidth(100),
        3: FixedColumnWidth(180),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
          ),
          children: [
            _tableCell('invoice'.tr, isHeader: true),
            _tableCell('product_name'.tr, isHeader: true),
            _tableCell('amount'.tr, isHeader: true),
            _tableCell('date'.tr, isHeader: true),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------
  // TABLE ROW
  // -------------------------------------------------
  Widget _buildTableRow(Invoice item) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120),
        1: FixedColumnWidth(200),
        2: FixedColumnWidth(100),
        3: FixedColumnWidth(180),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          children: [
            _tableCell(item.invoiceNumber ?? "-"),
            _tableCell(item.name ?? "-"),
            _tableCell("${item.salesAmount ?? 0.0}", color: Colors.red),
            _tableCell(item.invoiceDate ?? "-"),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------
  // TABLE CELL
  // -------------------------------------------------
  Widget _tableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text.tr,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: "Exo",
          fontSize: 15,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
          color: isHeader ? Colors.black : (color ?? const Color(0xFFB38F3F)),
        ),
      ),
    );
  }
}
