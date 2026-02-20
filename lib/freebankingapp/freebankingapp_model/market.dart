class Market {
  final String idMarket;
  final String symbol;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? credit;
  final String categoryName; // ✅ NEW FIELD

  Market({
    required this.idMarket,
    required this.symbol,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.credit,
    required this.categoryName, // ✅ Add to constructor
  });

  factory Market.fromJson(Map<String, dynamic> json) => Market(
        idMarket: json["id_market"] ?? '',
        symbol: json["symbol"] ?? '',
        name: json["market_name"] ?? '', // or json["name"] based on your API
        status: json["status"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        credit: json["credit"],
        categoryName: json["category_name"] ?? '', // ✅ Extract from JSON
      );
}
