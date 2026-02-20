class Product {
  final String id;
  final String name;
  final String description;
  final String credits;
  final String? bonusCredits;
  final String bonusCreditExpiry;
  final String price;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? archiveRemarks;
  final DateTime? archiveDate;

  // 🔥 New field from API
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    this.bonusCredits,
    required this.bonusCreditExpiry,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.archiveRemarks,
    this.archiveDate,

    // 🔥 NEW REQUIRED FIELD
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      credits: json['credits'] ?? '',
      bonusCredits: json['bonus_credits'],
      bonusCreditExpiry: json['bonus_credit_expiry'] ?? '0',
      price: json['price'] ?? '0.00',
      status: json['status'] ?? 'UNKNOWN',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      archiveRemarks: json['archive_remarks'],
      archiveDate: json['archive_date'] != null
          ? DateTime.tryParse(json['archive_date'])
          : null,

      // 🔥 NEW IMAGE MAPPING
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'credits': credits,
      'bonus_credits': bonusCredits,
      'bonus_credit_expiry': bonusCreditExpiry,
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archive_remarks': archiveRemarks,
      'archive_date': archiveDate?.toIso8601String(),

      // 🔥 NEW IMAGE
      'image': image,
    };
  }
}
