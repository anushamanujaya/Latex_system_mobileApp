class TransactionModel {
  final String id;
  final String sellerName;
  final double liters;
  final double rate;
  final double amount;
  final String date;

  TransactionModel({
    required this.id,
    required this.sellerName,
    required this.liters,
    required this.rate,
    required this.amount,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? '',
      liters: (json['liters'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date']?.toString() ?? '',
    );
  }
}
