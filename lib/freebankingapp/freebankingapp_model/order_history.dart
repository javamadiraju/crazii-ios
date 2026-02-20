class OrderHistory {
  final List<Invoice> invoices;

  OrderHistory({required this.invoices});

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      invoices: List<Invoice>.from(
        json['invoices'].map((x) => Invoice.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoices': invoices.map((x) => x.toJson()).toList(),
    };
  }
}

class Invoice {
  final String idInvoice;
  final String invoiceNumber;
  final String idUser;
  final String firstName;
  final String lastName;
  final String salesAmount;
  final String paymentType;
  final String invoiceDate;
  final String type;
  final String? creditId;
  final String? marketId;
  final String? strategyId;
  final String? productId;
  final String? videoId;
  final String remarks;
  final String createdAt;
  final String updatedAt;
  final String country;
  final String memberId;
  final String name;

  Invoice({
    required this.idInvoice,
    required this.invoiceNumber,
    required this.idUser,
    required this.firstName,
    required this.lastName,
    required this.salesAmount,
    required this.paymentType,
    required this.invoiceDate,
    required this.type,
    this.creditId,
    this.marketId,
    this.strategyId,
    this.productId,
    this.videoId,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.memberId,
    required this.name,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      idInvoice: json['id_invoice'],
      invoiceNumber: json['invoice_number'],
      idUser: json['id_user'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      salesAmount: json['sales_amount'],
      paymentType: json['payment_type'],
      invoiceDate: json['invoice_date'],
      type: json['type'],
      creditId: json['credit_id'],
      marketId: json['market_id'],
      strategyId: json['strategy_id'],
      productId: json['product_id'],
      videoId: json['video_id'],
      remarks: json['remarks'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      country: json['country'],
      memberId: json['member_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_invoice': idInvoice,
      'invoice_number': invoiceNumber,
      'id_user': idUser,
      'first_name': firstName,
      'last_name': lastName,
      'sales_amount': salesAmount,
      'payment_type': paymentType,
      'invoice_date': invoiceDate,
      'type': type,
      'credit_id': creditId,
      'market_id': marketId,
      'strategy_id': strategyId,
      'product_id': productId,
      'video_id': videoId,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country': country,
      'member_id': memberId,
      'name': name,
    };
  }
}
