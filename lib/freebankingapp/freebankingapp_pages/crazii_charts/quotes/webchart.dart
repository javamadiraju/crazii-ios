import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/shared_preference.dart';
import 'package:get/get.dart';

class WebChart extends StatefulWidget {
  final String symbol; // This is the Market ID
  final String timeframe;
  final String strategy; // This is the Strategy ID
  final String? symbolName; // This is the Market Symbol Name (e.g. XAUUSD.ca) for UI

  const WebChart({
    Key? key, 
    required this.symbol, 
    required this.strategy, 
    required this.timeframe,
    this.symbolName,
  }) : super(key: key);

  @override
  _WebChartState createState() => _WebChartState();
}

class _WebChartState extends State<WebChart> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            debugPrint("✅ WebView Page Finished: $url");
          },
          onWebResourceError: (error) {
            debugPrint("❌ WebView Error: ${error.description}");
          },
        ),
      );

    _loadWebView();
  }

  Future<void> _loadWebView() async {
    String? accessToken = await SharedPreferencesHelper.getAccessToken();

    if (accessToken == null) {
      debugPrint("❌ Error: Access token not found.");
      return;
    }

    // Capture the numeric ID for the 'pair' parameter
    String encodedId = Uri.encodeComponent(widget.symbol);
    
    // Standardize timeframe values
    String timeFrameValue = widget.timeframe;
    if (widget.timeframe == '5M' || widget.timeframe == '5 Minutes') {
      timeFrameValue = '5';
    } else if (widget.timeframe == 'D1' || widget.timeframe == '1 Day') {
      timeFrameValue = '1440';
    }

    final String lang = Get.locale?.languageCode ?? 'en';

    // Construct the URL using IDs for both pair and strategy
    String url = 'https://cgmember.com/api/charts/chart_view?pair=$encodedId&strategy=${widget.strategy}&timeframe=$timeFrameValue&lang=$lang';

    debugPrint('--- 📊 WebView Loading Info ---');
    debugPrint('Market ID (pair): ${widget.symbol}');
    debugPrint('Strategy ID: ${widget.strategy}');
    debugPrint('Timeframe: $timeFrameValue');
    debugPrint('Lang: $lang');
    debugPrint('Final URL: $url');
    debugPrint('------------------------------');

    try {
      controller.loadRequest(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );
    } catch (e) {
      debugPrint("❌ Exception during loadRequest: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Display market name in title, fallback to ID
        title: Text(widget.symbolName ?? widget.symbol),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/appicons/aims.jpg',
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
