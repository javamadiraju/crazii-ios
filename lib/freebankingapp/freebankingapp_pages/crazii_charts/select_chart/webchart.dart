import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class WebChart extends StatefulWidget {
  final String symbol;

  const WebChart({Key? key, required this.symbol}) : super(key: key);

  @override
  _WebChartState createState() => _WebChartState();
}

class _WebChartState extends State<WebChart> {
  late WebViewController controller;
  String jsonData = '';

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/webassets/index.html')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (jsonData.isNotEmpty) {
              _injectDataIntoWebView();
            }
          },
        ),
      );

    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final langCode = Get.locale?.languageCode ?? 'en';
      final response = await http.get(Uri.parse('https://cgmember.com/api/json-data/${widget.symbol}?lang=$langCode'));
      print('*** Response from chart data: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          jsonData = response.body;
        });

        _injectDataIntoWebView();
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

 void _injectDataIntoWebView() {
  if (jsonData.isNotEmpty) {
    try {
      // Ensure the JSON is valid before injecting
      final parsedJson = jsonDecode(jsonData);
      final jsonString = jsonEncode(parsedJson).replaceAll('"', '\\"'); // Escape quotes

      controller.runJavaScript('window.initChartWithData("$jsonString");'); // Pass JSON as string
    } catch (e) {
      print("Error injecting JSON: $e");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('charts'.tr)),
      body: WebViewWidget(controller: controller),
    );
  }
}
