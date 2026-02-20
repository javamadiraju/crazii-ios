class CreditHistory {
  final String idUser;
  final String creditType;
  final String balance;
  final String idHistory;
  final String transactionId;
  final String idCredit;
  final String transactionType;
  final String previousBalance;
  final String amount;
  final String remark;
  final String createdAt;

  CreditHistory({
    required this.idUser,
    required this.creditType,
    required this.balance,
    required this.idHistory,
    required this.transactionId,
    required this.idCredit,
    required this.transactionType,
    required this.previousBalance,
    required this.amount,
    required this.remark,
    required this.createdAt,
  });

  static String _extractCleanRemark(String remark) {
    if (remark.isEmpty) return '';

    final RegExp regex = RegExp(r'Market\s*-\s*(.*?)\s+at\s');
    final match = regex.firstMatch(remark);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    return remark;
  }

  factory CreditHistory.fromJson(Map<String, dynamic> json) {
    return CreditHistory(
      idUser: json['id_user']?.toString() ?? '',
      creditType: json['credit_type'] ?? '',
      balance: json['balance']?.toString() ?? '',
      idHistory: json['id_history']?.toString() ?? '',
      transactionId: json['transaction_id'] ?? '',
      idCredit: json['id_credit']?.toString() ?? '',
      transactionType: json['transaction_type'] ?? '',
      previousBalance: json['previous_balance']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      remark: _extractCleanRemark(json['remark'] ?? ''),
      createdAt: json['created_at'] ?? '',
    );
  }
}
