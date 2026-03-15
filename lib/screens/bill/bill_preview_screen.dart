import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

class BillPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const BillPreviewScreen({super.key, required this.transaction});

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();

    final createdAt = transaction['createdAt']?.toString() ?? '';
    String formattedDate = createdAt;
    try {
      formattedDate = DateFormat(
        'yyyy-MM-dd hh:mm a',
      ).format(DateTime.parse(createdAt));
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'LATEX PURCHASE BILL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Seller: ${transaction['sellerName'] ?? ''}'),
                pw.Text('Date: $formattedDate'),
                pw.SizedBox(height: 8),
                pw.Text('Liters: ${transaction['liters']}'),
                pw.Text('Density: ${transaction['density']}'),
                pw.Text('Density Decimal: ${transaction['densityDecimal']}'),
                pw.Text('Kilograms: ${transaction['kilograms']}'),
                pw.Text('Rate: Rs. ${transaction['rate']}'),
                pw.Text('Status: ${transaction['status']}'),
                pw.Divider(),
                pw.Text(
                  'Total Amount: Rs. ${transaction['totalAmount']}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Calculation',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${transaction['liters']} × ${transaction['densityDecimal']} = ${transaction['kilograms']} Kg',
                ),
                pw.Text(
                  '${transaction['kilograms']} × ${transaction['rate']} = Rs. ${transaction['totalAmount']}',
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PdfPreview(build: (format) async => (await _buildPdf()).save()),
    );
  }
}
