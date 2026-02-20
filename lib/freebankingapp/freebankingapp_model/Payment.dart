class Payment {
  final String id;
  final String name;
  final String description;
  final String credits;
  final String? bonusCredits; // Nullable field
  final String bonusCreditExpiry;
  final String price;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? archiveRemarks; // Nullable field
  final DateTime? archiveDate; // Nullable field

  Payment({
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
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '', // Default to an empty string if null
      name: json['name'] ?? '', // Default to an empty string if null
      description: json['description'] ?? '', // Default to an empty string
      credits: json['credits'] ?? '', // Default to an empty string
      bonusCredits: json['bonus_credits'], // Nullable string
      bonusCreditExpiry: json['bonus_credit_expiry'] ?? '0', // Default to '0'
      price: json['price'] ?? '0.00', // Default to '0.00'
      status: json['status'] ?? 'UNKNOWN', // Default to 'UNKNOWN'
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      archiveRemarks: json['archive_remarks'], // Nullable string
      archiveDate: json['archive_date'] != null
          ? DateTime.tryParse(json['archive_date'])
          : null, // Nullable DateTime
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
    };
  }
}
