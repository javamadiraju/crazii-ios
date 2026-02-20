import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_fontstyle.dart';
 
class CraziiViewChart extends StatefulWidget {
  const CraziiViewChart({Key? key}) : super(key: key);

  @override
  State<CraziiViewChart> createState() => _CraziiViewChartState();
}

class _CraziiViewChartState extends State<CraziiViewChart> {
  String? selectedMarket = 'DOW';
  String? selectedOption = '1'; 
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  //final themedata = Get.put(FreeBankingAppThemecontroler());
  bool isApiCallSuccessful = false;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: height / 36, horizontal: width / 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Charting",
                style: montserratsemibold.copyWith(
                  fontSize: 24,
                 // color: themedata.isdark
                  //    ? FreeBankingAppColor.white
                    //  : FreeBankingAppColor.textblack,
                ),
              ),
              SizedBox(height: height / 36),
              Text(
                "Choose the Market and strategy for monitoring",
                textAlign: TextAlign.center,
                style: montserratmedium.copyWith(
                  fontSize: 16,
                //  color: themedata.isdark
                 //     ? FreeBankingAppColor.white
                 //     : FreeBankingAppColor.textblack,
                ),
              ),
              SizedBox(height: height / 36),
              DropdownButtonFormField<String>(
                value: selectedMarket,
                decoration: InputDecoration(
                  labelText: "Choose Market",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                items: ['DOW', 'DAX', 'NIKKEI', 'XAUUSD', 'USDJPY']
                    .map((market) => DropdownMenuItem(
                          value: market,
                          child: Text(market),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMarket = value;
                  });
                },
              ),
              SizedBox(height: height / 36),
              Column(
                children: [
                  ListTile(
                    title: Text("Crazii Classic"),
                    leading: Radio<String>(
                      value: '1',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Crazii KCX Reversal"),
                    leading: Radio<String>(
                      value: '2',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Crazii Turbo"),
                    leading: Radio<String>(
                      value: '3',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height / 36),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> jsonData = {
                    "data": [
                      {
                        "timestamp": "2025-02-23 12:30",
                        "twb_open": 1.1050,
                        "twb_high": 1.1100,
                        "twb_low": 1.1025,
                        "twb_close": 1.1080,
                        "ksi_red": 95,
                        "ksi_green": 0,
                        "kcx": -200,
                        "kcx_buy_strategy_2": 1,
                        "kcx_add_strategy_3": 0,
                        "kcx_blink_bar_candles_back": 5,
                        "ksi_text": "KSI: Strong Buy",
                        "kcx_text": "KCX: Bullish",
                        "op_line": 1.1065,
                        "mlp_line": 1.1075,
                        "ktr_plus_1": 1.1120,
                        "ktr_minus_1": 1.1030
                      }
                    ]
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(jsonData: jsonEncode(jsonData)),
                    ),
                  ); 
                },
                child: Text("View"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String jsonData;
  const WebViewScreen({Key? key, required this.jsonData}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/webassets/index.html')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _injectDataIntoWebView();
          },
        ),
      );
  }

  void _injectDataIntoWebView() {
    String jsonString = widget.jsonData.replaceAll('"', '\\"'); // Escape quotes
    controller.runJavaScript('window.initChartWithData("$jsonString");');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebView Chart")),
      body: WebViewWidget(controller: controller),
    );
  }
}
