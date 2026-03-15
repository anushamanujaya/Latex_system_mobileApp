import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../services/local_db_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime selectedMonth = DateTime.now();

  List<MapEntry<dynamic, Map<String, dynamic>>> getFilteredTransactions(
    Box box,
  ) {
    final entries = box
        .toMap()
        .entries
        .map((entry) {
          return MapEntry(entry.key, Map<String, dynamic>.from(entry.value));
        })
        .where((entry) {
          final raw = entry.value['createdAt'];
          if (raw == null) return false;
          try {
            final dt = DateTime.parse(raw.toString());
            return dt.year == selectedMonth.year &&
                dt.month == selectedMonth.month;
          } catch (_) {
            return false;
          }
        })
        .toList();

    entries.sort((a, b) {
      final ad =
          DateTime.tryParse(a.value['createdAt']?.toString() ?? '') ??
          DateTime(2000);
      final bd =
          DateTime.tryParse(b.value['createdAt']?.toString() ?? '') ??
          DateTime(2000);
      return bd.compareTo(ad);
    });

    return entries;
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Box box = LocalDBService.box;
    final items = getFilteredTransactions(box);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickMonth,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Text(
              'Showing: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final key = items[index].key;
                      final item = items[index].value;

                      String formattedDate = '';
                      try {
                        formattedDate = DateFormat(
                          'yyyy-MM-dd – hh:mm a',
                        ).format(DateTime.parse(item['createdAt']));
                      } catch (_) {}

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['sellerName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Liters: ${item['liters']}'),
                              Text('Density: ${item['density']}'),
                              Text(
                                'Density Decimal: ${item['densityDecimal']}',
                              ),
                              Text('Kilograms: ${item['kilograms']}'),
                              Text('Rate: ${item['rate']}'),
                              Text('Total: ${item['totalAmount']}'),
                              Text('Status: ${item['status']}'),
                              const SizedBox(height: 6),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await box.delete(key);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
