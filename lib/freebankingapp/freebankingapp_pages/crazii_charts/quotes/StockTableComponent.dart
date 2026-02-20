import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WebSocketService.dart';
import '../chartapi.dart';
import 'package:http/http.dart' as http;
import 'package:freebankingapp/freebankingapp/freebankingapp_model/market.dart';
import 'data.dart';
import 'dart:math';

class StockData {
  final String symbol, diamond, current, upside, downside, time;
  StockData(this.symbol, this.diamond, this.current, this.upside, this.downside, this.time);
}

class StockTableComponent extends StatefulWidget {
  @override
  _StockTableComponentState createState() => _StockTableComponentState();
}

class _StockTableComponentState extends State<StockTableComponent> {
  final Map<String, WebSocketService> _ws = {};
  final List<StreamSubscription> _subscriptions = [];
  final Map<String, StockData> _rows = {};
  final Map<String, Map<String, dynamic>> _defaultApiMap = {};

  List<Market> allMarkets = [];
  List<String> trackedSymbols = [];

  String selectedCategory = "select_category";

  bool _disposed = false;
  String? _lastLang;
  bool _isScannerLoading = false;

  final List<String> categories = [
    "select_category",
    "indices",
    "commodities",
    "forex",
    "us_stocks",
    "crypto"
  ];

  @override
  void initState() {
    super.initState();
    _fetchMarketSymbols();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = Get.locale?.languageCode ?? 'en';
    if (_lastLang != currentLang) {
      _lastLang = currentLang;
      _fetchDefaults(); 
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (var sub in _subscriptions) sub.cancel();
    _subscriptions.clear();
    for (var ws in _ws.values) ws.dispose();
    _ws.clear();
    super.dispose();
  }

  void safeSetState(Function fn) {
    if (!_disposed && mounted) setState(() => fn());
  }

  String mapCategory(String cat) {
    switch (cat) {
      case "indices": return "indices";
      case "commodities": return "commodities";
      case "forex": return "forex";
      case "us_stocks": return "us_stocks";
      case "crypto": return "crypto";
      default: return "";
    }
  }

  Future<void> _fetchDefaults() async {
    safeSetState(() => _isScannerLoading = true);
    try {
      final langCode = Get.locale?.languageCode ?? 'en';
      final req = http.Request('GET', Uri.parse('https://cgmember.com/api/get-scanner-data?lang=$langCode'));
      final resp = await req.send();
      final body = await resp.stream.bytesToString();
      final json = jsonDecode(body);

      if (json["data"] is Map) {
        if (mounted) {
          setState(() {
            _defaultApiMap.clear();
            json["data"].forEach((symbol, entry) {
              _defaultApiMap[symbol] = Map<String, dynamic>.from(entry);
            });
          });
          
          if (selectedCategory != "select_category") {
            _populateInitialRows();
            _startWebSockets();
          }
        }
      }
    } catch (e) {
      debugPrint("Scanner API fetch error: $e");
    } finally {
      safeSetState(() => _isScannerLoading = false);
    }
  }

  Future<void> _fetchMarketSymbols() async {
    try {
      final list = await ChartApi.fetchSymbols();
      safeSetState(() => allMarkets = list);
    } catch (_) {}
  }

  Map<String, dynamic>? _findEntryForSymbol(String sym) {
    if (_defaultApiMap.isEmpty) return null;
    String searchSym = sym.toLowerCase().trim();
    String baseSym = searchSym.contains('.') ? searchSym.split('.').first : searchSym;

    for (var key in _defaultApiMap.keys) {
      String keyLower = key.toLowerCase();
      String keyBase = keyLower.contains('.') ? keyLower.split('.').first : keyLower;
      if (keyLower == searchSym || keyLower == baseSym || keyBase == searchSym || keyBase == baseSym) {
        return _defaultApiMap[key];
      }
    }
    for (var entry in _defaultApiMap.values) {
      String? innerSym = entry['symbol']?.toString().toLowerCase();
      if (innerSym != null && (innerSym == searchSym || innerSym == baseSym)) return entry;
    }
    return null;
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} "
           "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _populateInitialRows() {
    for (var sym in trackedSymbols) {
      final entry = _findEntryForSymbol(sym);
      final d = entry ?? {};
      
      String formatInitial(dynamic val) {
        String s = val?.toString() ?? "";
        if (s.isEmpty || s == "0" || s == "0.0" || s == "0.00000") return "-";
        double? numeric = double.tryParse(s);
        return numeric != null ? numeric.toStringAsFixed(2) : s;
      }

      final existing = _rows[sym];
      final apiTime = formatInitial(d["time"]);

      _rows[sym] = StockData(
        sym,
        formatInitial(d["dprice"]),
        formatInitial(d["cprice"]),
        formatInitial(d["upside"]),
        formatInitial(d["downside"]),
        // Authoritative: API time overrides on first load
        apiTime != "-" ? apiTime : (existing?.time ?? "-"),
      );
    }
    safeSetState(() {});
  }

  void _selectCategory(String cat) {
    selectedCategory = cat;
    if (cat == "select_category") {
      trackedSymbols.clear();
      _rows.clear();
      for (var s in _subscriptions) s.cancel();
      _subscriptions.clear();
      for (var ws in _ws.values) ws.dispose();
      _ws.clear();
      safeSetState(() {});
      return;
    }

    final apiCat = mapCategory(cat);
    final filtered = allMarkets.where((m) => m.categoryName.toLowerCase().trim() == apiCat);
    trackedSymbols = filtered.map((e) => e.symbol).toList();

    for (var sub in _subscriptions) sub.cancel();
    _subscriptions.clear();
    for (var ws in _ws.values) ws.dispose();
    _ws.clear();

    _rows.clear();
    _populateInitialRows();

    if (!_isScannerLoading) _startWebSockets();
  }

  void _startWebSockets() {
    for (var sym in trackedSymbols) {
      final ws = WebSocketService(sym);
      _ws[sym] = ws;

      final sub = ws.stream.listen((data) {
        if (_disposed || !mounted) return;

        safeSetState(() {
          final prev = _rows[sym]!;
          final double price12 = data.close;
          
          // --- DIAMOND DETECTION FROM 48 & 49 ---
          final double d48 = data.kcxBuyStrategy2;
          final double d49 = data.kcxAddStrategy3;
          
          double diamondSignal = 0;
          if (d48 > 0 && d49 > 0) {
            diamondSignal = max(d48, d49);
          } else if (d48 > 0) {
            diamondSignal = d48;
          } else if (d49 > 0) {
            diamondSignal = d49;
          }
          
          final bool isDiamond = diamondSignal > 0;
          
          // --- Find closest upside & downside ---
          final checkValues = [
            data.ktrPlus1, data.ktrPlus2, data.ktrPlus3, 
            data.ktrMinus1, data.ktrMinus2, data.ktfMinus3, 
            data.pivot1, data.pivot2, data.mlpLine
          ];

          double? closestUpside;
          double? closestDownside;

          for (var val in checkValues) {
            if (val == 0) continue;
            if (val > price12) {
              if (closestUpside == null || val < closestUpside) closestUpside = val;
            }
            if (val < price12) {
              if (closestDownside == null || val > closestDownside) closestDownside = val;
            }
          }

          // Condition: If a diamond signal is detected, update both price and time
          final bool diamondModified = isDiamond && price12 > 0;

          _rows[sym] = StockData(
            sym,
            // --- Freeze Diamond Price when new Diamond appears ---
            diamondModified ? price12.toStringAsFixed(2) : prev.diamond,
            // --- Current price keeps updating normally ---
            price12.toStringAsFixed(2),
            // --- Update closest upside & downside ---
            closestUpside != null ? closestUpside.toStringAsFixed(2) : prev.upside,
            closestDownside != null ? closestDownside.toStringAsFixed(2) : prev.downside,
            // --- Update time whenever diamondSignal is modified ---
            diamondModified
                ? _formatDateTime(data.timestamp)
                : prev.time,
          );
        });
      });
      _subscriptions.add(sub);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: _isScannerLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text("${'loading'.tr} data...", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  )
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E2E6)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.tr))).toList(),
          onChanged: (val) => safeSetState(() => _selectCategory(val!)),
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (trackedSymbols.isEmpty) return const Center(child: Text(" "));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          _buildHeader(),
          Container(height: 1, color: const Color(0xFFE2E2E6)),
          Expanded(child: _buildRows()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _headerCell('symbol'.tr, 120),
          _headerCell('diamond_signal'.tr, 140),
          _headerCell('current'.tr, 140),
          _headerCell('upside'.tr, 140),
          _headerCell('downside'.tr, 150),
          _headerCell('time'.tr, 140),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 14),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6A4CC3))),
    );
  }

  Widget _buildRows() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(trackedSymbols.length, (i) {
          final sym = trackedSymbols[i];
          final r = _rows[sym]!;
          return Container(
            color: (i % 2 != 0) ? Colors.white : const Color(0xFFF6F5FA),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _cell(r.symbol, 120),
                _cell(r.diamond, 140),
                _cell(r.current, 140),
                _cell(r.upside, 140),
                _cell(r.downside, 150),
                _cell(r.time, 140),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _cell(String value, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 14),
      child: Text(value, style: const TextStyle(fontSize: 13)),
    );
  }
}
