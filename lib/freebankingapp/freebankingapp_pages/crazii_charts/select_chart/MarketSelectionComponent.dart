// market_selection_component.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import '../chartapi.dart';

class Market {
  final String id;
  final String name;
  final String credit;
  final String symbol;
  final String category;
  final String tf5m;
  final String tf1d;

  Market({
    required this.id,
    required this.name,
    required this.credit,
    required this.symbol,
    required this.category,
    required this.tf5m,
    required this.tf1d,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    // Robust null handling for API responses
    String s(dynamic val) => val?.toString() ?? "";
    
    return Market(
      id: s(json['id_market']),
      name: s(json['symbol']),
      credit: s(json['credit']),
      symbol: s(json['symbol']),
      category: s(json['category_name']).trim(),
      tf5m: s(json['5M']),
      tf1d: s(json['1D']),
    );
  }

  @override
  String toString() => symbol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Market && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MarketSelectionComponent extends StatefulWidget {
  final Market? selectedMarket;
  final Function(Market?) onSelectionChanged;
  final String selectedTimeFrame;
  final Function(String) onTimeFrameChanged;

  const MarketSelectionComponent({
    Key? key,
    required this.selectedMarket,
    required this.onSelectionChanged,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
  }) : super(key: key);

  @override
  _MarketSelectionComponentState createState() =>
      _MarketSelectionComponentState();
}

class _MarketSelectionComponentState extends State<MarketSelectionComponent> {
  Market? _selectedMarket;
  List<Market> _marketList = [];
  List<Market> _filteredMarketList = [];
  bool hasFetchedMarkets = false;
  String? _marketError;
  String _selectedCategory = 'commodities';
  late String selectedTimeFrame;
  final ChartApi chartApi = ChartApi();
  String? _lastLang;

  final List<String> _categoryKeys = [
    'indices',
    'commodities',
    'forex',
    'us_stocks',
    'china_stocks',
    'crypto',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMarket = widget.selectedMarket;
    selectedTimeFrame = widget.selectedTimeFrame;
    _selectedCategory = 'commodities';
  }

  @override
  void didUpdateWidget(MarketSelectionComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMarket != oldWidget.selectedMarket) {
      setState(() {
        _selectedMarket = widget.selectedMarket;
      });
    }
    if (widget.selectedTimeFrame != oldWidget.selectedTimeFrame) {
      setState(() {
        selectedTimeFrame = widget.selectedTimeFrame;
      });
      _filterMarkets();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final currentLang = locale.languageCode;

    if (_lastLang != currentLang) {
      _lastLang = currentLang;
      fetchMarketOptions(currentLang);
    }
  }

  Future<void> fetchMarketOptions(String langCode) async {
    final Uri url = Uri.parse('https://cgmember.com/api/market?lang=$langCode');
    debugPrint('📡 Fetching markets: $url');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        final List<Market> markets = jsonData.map((e) => Market.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            _marketList = markets;
            hasFetchedMarkets = true;
            _filterMarketsInternal(); 
          });
        }
      } else {
        debugPrint('❌ Market API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Market fetch exception: $e');
    }
  }

  void _filterMarketsInternal() {
    _filteredMarketList = _marketList.where((market) {
      String cat = market.category.toLowerCase();
      
      // Comprehensive mapping for all supported languages
      final categoryMap = {
        // English
        'indices': 'indices', 'indice': 'indices',
        'commodities': 'commodities', 'commodity': 'commodities',
        'forex': 'forex',
        'us stocks': 'us_stocks', 'us stock': 'us_stocks',
        'china stocks': 'china_stocks', 'china stock': 'china_stocks',
        'crypto': 'crypto', 'cryptocurrency': 'crypto',
        
        // Chinese
        '指数': 'indices',
        '商品': 'commodities',
        '外汇': 'forex',
        '美股': 'us_stocks',
        '中国股': 'china_stocks',
        '加密货币': 'crypto',
        
        // Vietnamese
        'chỉ số': 'indices',
        'hàng hóa': 'commodities',
        'ngoại hối': 'forex',
        'cổ phiếu mỹ': 'us_stocks',
        'cổ phiếu trung quốc': 'china_stocks',
        'tiền điện tử': 'crypto',
      };
      
      String mappedCategory = categoryMap[cat] ?? cat;
      final categoryMatch = mappedCategory == _selectedCategory;
      
      // Ensure we only match if timeframe is supported ('1' string from API)
      final timeframeMatch = (selectedTimeFrame == '5M' && market.tf5m == '1') ||
          (selectedTimeFrame == 'D1' && market.tf1d == '1');
          
      return categoryMatch && timeframeMatch;
    }).toList();
    
    debugPrint('🔍 Filtered Count for $_selectedCategory ($selectedTimeFrame): ${_filteredMarketList.length}');
  }

  void _filterMarkets() {
    setState(() {
      _filterMarketsInternal();
    });
  }

  void _filterMarketsByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedMarket = null;
      _filterMarketsInternal();
    });
    widget.onSelectionChanged(null);
  }

  void _validateSelection() {
    setState(() {
      _marketError = _selectedMarket == null ? "please_select_market".tr : null;
    });
  }

  InputDecoration get _baseDecoration => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB38F3F), width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    String? selectedMarketId;
    if (_selectedMarket != null) {
      bool exists = _filteredMarketList.any((m) => m.id == _selectedMarket!.id);
      if (exists) {
        selectedMarketId = _selectedMarket!.id;
      }
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 350),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_market_category'.tr,
            style: const TextStyle(
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categoryKeys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key.tr),
              );
            }).toList(),
            onChanged: (String? newCategory) {
              if (newCategory != null) {
                _filterMarketsByCategory(newCategory);
              }
            },
            decoration: _baseDecoration,
          ),
          const SizedBox(height: 16),
          Text(
            'select_timeframe'.tr,
            style: const TextStyle(
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedTimeFrame,
            decoration: _baseDecoration,
            items: [
              DropdownMenuItem(value: '5M', child: Text('tf_5m'.tr)),
              DropdownMenuItem(value: 'D1', child: Text('tf_d1'.tr)),
            ],
            onChanged: (String? newVal) {
              if (newVal != null && newVal != selectedTimeFrame) {
                setState(() {
                  selectedTimeFrame = newVal;
                  _selectedMarket = null;
                  _marketError = null;
                  _filterMarketsInternal();
                });
                widget.onTimeFrameChanged(newVal);
                widget.onSelectionChanged(null);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'select_market'.tr,
            style: const TextStyle(
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('market_dropdown_${_lastLang}_${_selectedCategory}_${selectedTimeFrame}'),
            value: selectedMarketId,
            hint: Text("select_market".tr),
            decoration: _baseDecoration,
            items: _filteredMarketList.map((market) {
              return DropdownMenuItem<String>(
                value: market.id,
                child: Text(market.symbol.isEmpty ? "ID: ${market.id}" : market.symbol),
              );
            }).toList(),
            onChanged: (String? newId) {
              if (newId != null) {
                final market = _filteredMarketList.firstWhere((m) => m.id == newId);
                setState(() {
                  _selectedMarket = market;
                  _validateSelection();
                });
                widget.onSelectionChanged(market);
              }
            },
          ),
          if (_marketError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _marketError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
