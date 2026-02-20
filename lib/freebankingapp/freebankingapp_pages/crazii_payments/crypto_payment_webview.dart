import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class CryptoPaymentWebView extends StatefulWidget {
  final String url;
  final String invoiceId;

  CryptoPaymentWebView({
    required this.url,
    required this.invoiceId,
  });

  @override
  State<CryptoPaymentWebView> createState() => _CryptoPaymentWebViewState();
}

class _CryptoPaymentWebViewState extends State<CryptoPaymentWebView> {
  Timer? _timer;
  String paymentStatus = "pending";

  @override
  void initState() {
    super.initState();

    // Check status every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final String langCode = LanguageUtils.getLanguageCode();
      final response = await http.post(
        Uri.parse("https://cgmember.com/api/nowpayments/verify?lang=$langCode"),
        body: {"invoice_id": widget.invoiceId},
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      paymentStatus = data["status"] ?? "pending";

      if (data["success"] == true &&
          (paymentStatus == "finished" || paymentStatus == "confirmed")) {

        _timer?.cancel();

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Crypto payment completed successfully!")),
        );
      }
    } catch (e) {
      print("Status check error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),

            // 🔥 Close Icon Floating on Top Right
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _timer?.cancel();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
