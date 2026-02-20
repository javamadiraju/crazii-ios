// select_chart.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MarketSelectionComponent.dart';
import 'StrategySelectionComponent.dart';
import 'PaymentButtonComponent.dart';
import 'purchasedsymbolscomponent.dart';
import 'purchasedsymbols.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_drawer/crazii_drawer.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import '../chartapi.dart';

class SelectChart extends StatefulWidget {
  const SelectChart({Key? key}) : super(key: key);

  @override
  _SelectChartState createState() => _SelectChartState();
}

class _SelectChartState extends State<SelectChart> {
  List<Market> selectedMarkets = [];
  String? selectedStrategy;
  String? marketError;
  String? strategyError;

  List<PurchasedSymbols> _purchasedList = [];
  List<String> _purchasedKeys = []; // For quick check isAlreadyPurchased

  final ChartApi _chartApi = ChartApi();

  bool _isLoadingSymbols = true;
  String? _fetchError;
  String? _lastLang;

  String selectedTimeFrame = '5M';

  // 🔹 Drawer values
  String cashCredit = "0";
  String bonusCredit = "0";
  String fullName = "User";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reactively detect locale changes
    final locale = Localizations.localeOf(context);
    final currentLang = locale.languageCode;

    if (_lastLang != currentLang) {
      _lastLang = currentLang;
      _loadPurchasedSymbols(currentLang);
    }
  }

  Future<void> _loadPurchasedSymbols([String? lang]) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    final String? userJson = prefs.getString('user');

    if (accessToken == null || userJson == null) {
      if (mounted) {
        setState(() {
          _fetchError = "Missing credentials. Please log in again.";
          _isLoadingSymbols = false;
        });
      }
      return;
    }

    try {
      final User user = User.fromJson(jsonDecode(userJson));
      final String userId = user.data.idUser;

      fullName = '${user.data.firstName} ${user.data.lastName}';

      final List<PurchasedSymbols> purchasedList =
          await _chartApi.fetchPurchasedMarkets(userId, lang: lang);

      if (mounted) {
        setState(() {
          _purchasedList = purchasedList;
          _purchasedKeys = purchasedList
              .map((ps) => '${ps.marketId}-${ps.strategyId}-${ps.timeframe}')
              .toList();

          _isLoadingSymbols = false;
          _fetchError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fetchError = "Failed to fetch purchased symbols.";
          _isLoadingSymbols = false;
        });
      }
    }
  }

  void updateMarkets(List<Market> markets) {
    setState(() {
      selectedMarkets = markets;
      marketError = null;
    });
  }

  void updateStrategy(String? strategyId) {
    setState(() {
      selectedStrategy = strategyId;
      strategyError = null;
    });
  }

  void handleValidationErrors(String marketErr, String strategyErr) {
    setState(() {
      marketError = marketErr.isEmpty ? null : marketErr;
      strategyError = strategyErr.isEmpty ? null : strategyErr;
    });
  }

  void _handlePayment() {
    // This local update is a fallback until _loadPurchasedSymbols refetches
    if (selectedMarkets.isEmpty || selectedStrategy == null) return;
    
    _loadPurchasedSymbols(_lastLang);
  }

  bool get isAlreadyPurchased {
    if (selectedMarkets.length != 1 || selectedStrategy == null) return false;

    final marketId = selectedMarkets.first.id;
    final strategyId = selectedStrategy!;
    final frameValue = selectedTimeFrame == 'D1' ? '1440' : '5';

    final symbolKey = '$marketId-$strategyId-$frameValue';
    return _purchasedKeys.contains(symbolKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CraziiDrawer(),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 55,
              child: CraziiHeader(productName: ''),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 
                        const SizedBox(height: 12),

                        MarketSelectionComponent(
                          selectedMarket:
                              selectedMarkets.isNotEmpty
                                  ? selectedMarkets.first
                                  : null,
                          onSelectionChanged: (Market? m) {
                            updateMarkets(m != null ? [m] : []);
                          },
                          selectedTimeFrame: selectedTimeFrame,
                          onTimeFrameChanged: (String newTf) {
                            setState(() {
                              selectedTimeFrame = newTf;
                            });
                          },
                        ),

                        if (marketError != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              marketError!,
                              style:
                                  const TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 8),

                        StrategySelectionComponent(
                          selectedStrategy: selectedStrategy,
                          onSelectionChanged: updateStrategy,
                        ),

                        if (strategyError != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              strategyError!,
                              style:
                                  const TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 16),

                        PaymentButtonComponent(
                          selectedMarkets:
                              selectedMarkets.map((m) => m.id).toList(),
                          selectedStrategies: selectedStrategy != null
                              ? [selectedStrategy!]
                              : [],
                          onValidationFailed: handleValidationErrors,
                          onPayment: _handlePayment,
                          symbol: selectedMarkets.isNotEmpty
                              ? selectedMarkets.first.symbol
                              : '',
                          onPurchaseSuccess: (symbol) async {
                            await Future.delayed(
                                const Duration(seconds: 1));
                            _loadPurchasedSymbols(_lastLang);
                          },
                          isAlreadyPurchased: isAlreadyPurchased,
                          onRefresh: () => _loadPurchasedSymbols(_lastLang),
                          selectedTimeFrame: selectedTimeFrame,
                        ),

                        PurchasedMarketListComponent(
                          purchasedSymbols: _purchasedList,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const SafeArea(
        top: false,
        child: CraziiFooter(selectedIndex: 0),
      ),
    );
  }
}
