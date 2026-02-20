import 'package:flutter/material.dart';
import '../quotes/webchart.dart';
import 'package:get/get.dart';
import 'purchasedsymbols.dart';

class PurchasedMarketListComponent extends StatelessWidget {
  final List<PurchasedSymbols> purchasedSymbols;

  const PurchasedMarketListComponent({
    Key? key,
    required this.purchasedSymbols,
  }) : super(key: key);

  String _getTranslatedTimeframe(String tfRaw) {
    if (tfRaw == "1440") {
      return "tf_d1".tr;
    } else if (tfRaw == "5") {
      return "tf_5m".tr;
    }
    return tfRaw;
  }

  @override
  Widget build(BuildContext context) {
    if (purchasedSymbols.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          "no_records".tr,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Text(
          "purchased_markets".tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: purchasedSymbols.length,
          itemBuilder: (context, index) {
            final ps = purchasedSymbols[index];
            
            final marketDisplayName = ps.marketName;
            final strategyDisplayName = ps.strategyName;
            final timeframeDisplayName = _getTranslatedTimeframe(ps.timeframe);

            final fullText = "$marketDisplayName - $strategyDisplayName - $timeframeDisplayName";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 2),
                    width: 12,
                    child: const Text(
                      "•",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Pass IDs for functionality but also pass names for display
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebChart(
                              symbol: ps.marketId, 
                              strategy: ps.strategyId, 
                              timeframe: ps.timeframe,
                              symbolName: ps.marketName, // Added to fix title display
                            ),
                          ),
                        );
                      },
                      child: Text(
                        fullText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC27A00),
                          decoration: TextDecoration.none,
                          fontFamily: 'Exo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
