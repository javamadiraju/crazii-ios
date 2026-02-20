class PurchasedSymbols {
  final String marketId;
  final String marketName;
  final String strategyId;
  final String strategyName;
  final String timeframe; // <-- New field added

  PurchasedSymbols({
    required this.marketId,
    required this.marketName,
    required this.strategyId,
    required this.strategyName,
    required this.timeframe, // <-- Include in constructor
  });

  factory PurchasedSymbols.fromJson(Map<String, dynamic> json) {
    return PurchasedSymbols(
      marketId: json['market_id']?.toString() ?? '0',
      marketName: json['market_name']?.toString() ?? 'Unknown Market',
      strategyId: json['strategy_id']?.toString() ?? '0',
      strategyName: json['strategy_name']?.toString() ?? 'Unknown Strategy',
      timeframe: json['timeframe']?.toString() ?? '0', // <-- Add parsing here
    );
  }
}
