import 'package:hive/hive.dart';
import 'local_db_service.dart';

class ReportSummary {
  final double totalLiters;
  final double totalKilograms;
  final double totalMoneyPaid;
  final double totalAmountAll;
  final int count;

  ReportSummary({
    required this.totalLiters,
    required this.totalKilograms,
    required this.totalMoneyPaid,
    required this.totalAmountAll,
    required this.count,
  });
}

class ReportService {
  static ReportSummary getSummary({DateTime? month}) {
    final Box box = LocalDBService.box;
    final items = box.values.map((e) => Map<String, dynamic>.from(e)).where((
      item,
    ) {
      if (month == null) return true;
      final raw = item['createdAt'];
      if (raw == null) return false;
      try {
        final dt = DateTime.parse(raw.toString());
        return dt.year == month.year && dt.month == month.month;
      } catch (_) {
        return false;
      }
    }).toList();

    double totalLiters = 0;
    double totalKilograms = 0;
    double totalMoneyPaid = 0;
    double totalAmountAll = 0;

    for (final item in items) {
      final liters = (item['liters'] ?? 0).toDouble();
      final kilograms = (item['kilograms'] ?? 0).toDouble();
      final totalAmount = (item['totalAmount'] ?? 0).toDouble();
      final status = item['status']?.toString() ?? 'Not Paid';

      totalLiters += liters;
      totalKilograms += kilograms;
      totalAmountAll += totalAmount;

      if (status == 'Paid') {
        totalMoneyPaid += totalAmount;
      }
    }

    return ReportSummary(
      totalLiters: totalLiters,
      totalKilograms: totalKilograms,
      totalMoneyPaid: totalMoneyPaid,
      totalAmountAll: totalAmountAll,
      count: items.length,
    );
  }
}
