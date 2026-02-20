import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityListComponent extends StatefulWidget {
  @override
  _CommunityListComponentState createState() => _CommunityListComponentState();
}

class _CommunityListComponentState extends State<CommunityListComponent> {
  @override
  Widget build(BuildContext context) {
    return MarketStrategyScreen();
  }
}

class MarketStrategyScreen extends StatefulWidget {
  @override
  _MarketStrategyScreenState createState() => _MarketStrategyScreenState();
}

class _MarketStrategyScreenState extends State<MarketStrategyScreen> with WidgetsBindingObserver {
  // Store static/localized data from API (Symbol, Market Name)
  Map<String, Map<String, dynamic>> apiDataMap = {};
  // Store real-time data from Socket (Pax Online, Diamond counts)
  Map<String, Map<String, dynamic>> socketDataMap = {};
  
  List<String> marketIds = [];
  bool _isLoading = true;
  String? _lastLang;

  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDataAndSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("🔄 App resumed - refreshing community data and socket");
      _initDataAndSocket();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final currentLang = locale.languageCode;
    
    if (_lastLang != currentLang) {
      _lastLang = currentLang;
      _initDataAndSocket();
    }
  }

  void _initDataAndSocket() {
    final currentLang = Get.locale?.languageCode ?? 'en';
    setState(() => _isLoading = true);
    fetchMarketData(currentLang);
    connectSocket();
  }

  Future<void> fetchMarketData(String lang) async {
    final url = Uri.parse('https://cgmember.com/api/market-strategy-summary?lang=$lang');
    debugPrint("📡 Fetching localized community data: $url");
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('summary')) {
          final list = data['summary'] as List;
          Map<String, Map<String, dynamic>> newApiMap = {};
          List<String> newIds = [];
          
          for (var item in list) {
            final id = item['id_market']?.toString() ?? "";
            if (id.isNotEmpty) {
              newApiMap[id] = Map<String, dynamic>.from(item);
              newIds.add(id);
            }
          }
          
          if (mounted) {
            setState(() {
              apiDataMap = newApiMap;
              marketIds = newIds;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("❌ API Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void connectSocket() {
    // Clean up existing socket if any
    socket?.dispose();

    socket = IO.io(
      'https://cgmembers.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(5)
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint("✅ Socket connected!");
      socket!.emit("ping_test", "flutter connected!");
    });

    socket!.on('market_strategy_summary', (data) {
      if (data is Map && data.containsKey('summary')) {
        final list = data['summary'] as List;
        Map<String, Map<String, dynamic>> newSocketMap = {};
        
        for (var item in list) {
          final id = item['id_market']?.toString() ?? "";
          if (id.isNotEmpty) {
            newSocketMap[id] = Map<String, dynamic>.from(item);
          }
        }

        if (mounted) {
          setState(() {
            socketDataMap = newSocketMap;
          });
        }
      }
    });

    socket!.onError((error) => debugPrint("❌ Socket error: $error"));
    socket!.onDisconnect((_) => debugPrint("🔴 Socket DISCONNECTED"));
    
    socket!.connect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    socket?.dispose();
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'community'.tr,
                    style: const TextStyle(
                      color: Color(0xFF27173E),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildTable()),
                ],
              ),
            ),
    );
  }

  Widget _buildTable() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E2E6), width: 1),
      ),
      child: Scrollbar(
        controller: _horizontalScroll,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalScroll,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: _verticalScroll,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalScroll,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  _buildHeaderRow(),
                  const Divider(height: 0, color: Color(0xFFE2E2E6)),
                  ...marketIds.asMap().entries.map((entry) {
                    final index = entry.key;
                    final id = entry.value;
                    
                    final apiItem = apiDataMap[id] ?? {};
                    final socketItem = socketDataMap[id] ?? {};
                    
                    // Prioritize API data for Symbol and Market Name (Localized)
                    // Use Socket data for online users and signals (Real-time)
                    final mergedItem = {
                      ...socketItem, 
                      "symbol": apiItem["symbol"] ?? socketItem["symbol"] ?? "-",
                      "market_name": apiItem["market_name"] ?? socketItem["market_name"] ?? "-",
                    };
                    
                    return _buildDataRow(mergedItem, index % 2 == 0);
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _headerCell('symbol'.tr, 140),
          _headerCell('name'.tr, 170),
          _headerCell('online_users'.tr, 150),
          _headerCell('four_diamonds'.tr, 150),
          _headerCell('stacked_diamonds'.tr, 160),
          _headerCell('blue_diamonds'.tr, 150),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> item, bool grey) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: grey ? const Color(0xFFF3F3F7) : Colors.white,
      child: Row(
        children: [
          _dataCellLeft(item["symbol"]?.toString() ?? "-", 140),
          _dataCellLeft(item["market_name"]?.toString() ?? "-", 170),
          _dataCellCenter(item["pax_online"]?.toString() ?? "-", 150),
          _dataCellCenter(item["Four_Diamonds"]?.toString() ?? "-", 150),
          _dataCellCenter(item["Stacked_Diamonds"]?.toString() ?? "-", 160),
          _dataCellCenter(item["Blue_Diamond"]?.toString() ?? "-", 150),
        ],
      ),
    );
  }

  Widget _dataCellLeft(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _dataCellCenter(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
