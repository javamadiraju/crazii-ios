class InvoiceDetail 
  {
  final String idInvoice;
  final String invoiceNumber;
  final String idUser;
  final String firstName;
  final String lastName;
  final String salesAmount;
  final String purchasedCredits;
  final String invoiceDate;
  final String market;
  final String remarks;
  final String? data;
  final String createdAt;
  final String updatedAt;
  final String? credit;
  final String action;
  final String country;

  InvoiceDetail({
    required this.idInvoice,
    required this.invoiceNumber,
    required this.idUser,
    required this.firstName,
    required this.lastName,
    required this.salesAmount,
    required this.purchasedCredits,
    required this.invoiceDate,
    required this.market,
    required this.remarks,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.credit,
    required this.action,
    required this.country,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      idInvoice: json['id_invoice'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      idUser: json['id_user'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      salesAmount: json['sales_amount'] ?? '',
      purchasedCredits: json['purchased_credits'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      market: json['market'] ?? '',
      remarks: json['remarks'] ?? '',
      data: json['data'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      credit: json['credit'],
      action: json['action'] ?? '',
      country: json['country'] ?? '',
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
      'purchased_credits': purchasedCredits,
      'invoice_date': invoiceDate,
      'market': market,
      'remarks': remarks,
      'data': data,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'credit': credit,
      'action': action,
      'country': country,
    };
  }
}
