// payment_button_component.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/chartapi.dart';
import '../quotes/webchart.dart';

class PaymentButtonComponent extends StatefulWidget {
  final List<String> selectedMarkets;
  final List<String> selectedStrategies;
  final Function(String marketError, String strategyError) onValidationFailed;
  final VoidCallback? onPayment;
  final String symbol;
  final Function(String symbol) onPurchaseSuccess;
  final bool isAlreadyPurchased;
  final VoidCallback onRefresh;
  final String selectedTimeFrame;

  const PaymentButtonComponent({
    Key? key,
    required this.selectedMarkets,
    required this.selectedStrategies,
    required this.onValidationFailed,
    required this.onPayment,
    required this.symbol,
    required this.onPurchaseSuccess,
    required this.isAlreadyPurchased,
    required this.onRefresh,
    required this.selectedTimeFrame,
  }) : super(key: key);

  @override
  State<PaymentButtonComponent> createState() => _PaymentButtonComponentState();
}

class _MarketStrategyPurchaseDialog extends StatelessWidget {
  final int status;
  final String message;

  const _MarketStrategyPurchaseDialog({
    Key? key,
    required this.status,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSuccess = status == 200;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.only(top: 16, left: 16),
      title: Align(
        alignment: Alignment.topLeft,
        child: Text(
          isSuccess ? "success_title".tr : "error".tr,
          style: TextStyle(
            color: isSuccess ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        isSuccess ? "success".tr : message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "ok".tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _PaymentButtonComponentState extends State<PaymentButtonComponent> {
  bool _isLoading = false;

  void _validateAndProceed(BuildContext context) async {
    String? marketError;
    String? strategyError;

    if (widget.selectedMarkets.isEmpty || widget.selectedMarkets.length > 1) {
      marketError = "Please select only one Market.";
    }

    if (widget.selectedStrategies.isEmpty) {
      strategyError = "Please select a Strategy.";
    }

    if (marketError != null || strategyError != null) {
      widget.onValidationFailed(marketError ?? "", strategyError ?? "");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_purchase'.tr),
        content: Text('confirm_purchase1'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB38F3F)),
            child: Text('continue'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final timeFrameMap = {'5M': '5', 'D1': '1440'};
    final mappedTimeFrame = timeFrameMap[widget.selectedTimeFrame] ?? '5';

    final capiService = ChartApi();
    final result = await capiService.purchaseMarketStrategy(
      widget.selectedMarkets,
      widget.selectedStrategies,
      mappedTimeFrame,
    );

    final int status = (result['status'] is int) ? result['status'] : int.tryParse(result['status'].toString()) ?? 0;
    final String message = result['message']?.toString() ?? 'No message';

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _MarketStrategyPurchaseDialog(
          status: status,
          message: message,
        );
      },
    );

    if (status != 200) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebChart(
          symbol: widget.selectedMarkets[0], 
          strategy: widget.selectedStrategies[0],
          timeframe: mappedTimeFrame,
          symbolName: widget.symbol,
        ),
      ),
    );

    widget.onPayment?.call();
    widget.onPurchaseSuccess(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isAlreadyPurchased ? Colors.grey : const Color(0xFFB38F3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: widget.isAlreadyPurchased || _isLoading ? null : () => _validateAndProceed(context),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                  SizedBox(width: 12),
                  Text("Processing...", style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              )
            : Text(
                widget.isAlreadyPurchased ? 'already_purchased'.tr : 'pay_with_credits'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }
}
