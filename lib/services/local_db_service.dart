import 'package:hive/hive.dart';

class LocalDBService {
  static final Box box = Hive.box('transactions');

  static Future<void> addTransaction(Map<String, dynamic> data) async {
    await box.add(data);
  }

  static List<Map<String, dynamic>> getTransactions() {
    return box.values.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static List<Map<String, dynamic>> getTransactionsByMonth({
    required int year,
    required int month,
  }) {
    return box.values.map((item) => Map<String, dynamic>.from(item)).where((
      item,
    ) {
      final raw = item['createdAt'];
      if (raw == null) return false;
      try {
        final dt = DateTime.parse(raw.toString());
        return dt.year == year && dt.month == month;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  static Future<void> deleteTransaction(dynamic key) async {
    await box.delete(key);
  }
}
