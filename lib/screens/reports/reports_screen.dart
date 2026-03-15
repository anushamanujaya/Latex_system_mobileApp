import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedMonth = DateTime.now();

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

  Widget card(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = ReportService.getSummary(month: selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            onPressed: pickMonth,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade50,
              child: Text(
                'Report Month: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  card('Total Liters', summary.totalLiters.toStringAsFixed(2)),
                  card(
                    'Total Kilograms',
                    summary.totalKilograms.toStringAsFixed(2),
                  ),
                  card('Money Paid', summary.totalMoneyPaid.toStringAsFixed(2)),
                  card(
                    'Total Amount',
                    summary.totalAmountAll.toStringAsFixed(2),
                  ),
                  card('Transaction Count', summary.count.toString()),
                  card(
                    'Pending Amount',
                    (summary.totalAmountAll - summary.totalMoneyPaid)
                        .toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
