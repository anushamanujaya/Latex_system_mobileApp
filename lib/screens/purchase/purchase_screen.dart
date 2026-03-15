import 'package:flutter/material.dart';
import '../../services/local_db_service.dart';
import '../../services/calculation_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../bill/bill_preview_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final sellerController = TextEditingController();
  final litersController = TextEditingController();
  final densityController = TextEditingController();
  final rateController = TextEditingController();

  double densityDecimal = 0;
  double kilograms = 0;
  double totalAmount = 0;
  bool isLoading = false;
  String status = 'Not Paid';

  void calculateAmount() {
    final liters = double.tryParse(litersController.text.trim()) ?? 0;
    final density = int.tryParse(densityController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;

    try {
      final result = CalculationService.calculate(
        liters: liters,
        density: density,
        rate: rate,
      );

      setState(() {
        densityDecimal = result.densityDecimal;
        kilograms = result.kilograms;
        totalAmount = result.totalAmount;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Density must be one of: 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150',
          ),
        ),
      );
    }
  }

  Future<void> savePurchase() async {
    final sellerName = sellerController.text.trim();
    final liters = double.tryParse(litersController.text.trim()) ?? 0;
    final density = int.tryParse(densityController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;

    if (sellerName.isEmpty || liters <= 0 || density <= 0 || rate <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid data')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = CalculationService.calculate(
        liters: liters,
        density: density,
        rate: rate,
      );

      final tx = {
        'sellerName': sellerName,
        'liters': result.liters,
        'density': result.density,
        'densityDecimal': result.densityDecimal,
        'kilograms': result.kilograms,
        'rate': result.rate,
        'totalAmount': result.totalAmount,
        'status': status,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await LocalDBService.addTransaction(tx);

      if (!mounted) return;

      sellerController.clear();
      litersController.clear();
      densityController.clear();
      rateController.clear();

      setState(() {
        densityDecimal = 0;
        kilograms = 0;
        totalAmount = 0;
        status = 'Not Paid';
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BillPreviewScreen(transaction: tx)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save purchase: $e')));
    }
  }

  @override
  void dispose() {
    sellerController.dispose();
    litersController.dispose();
    densityController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              controller: sellerController,
              hintText: 'Seller Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: litersController,
              hintText: 'Liters',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: densityController,
              hintText: 'Density (50 - 150)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: rateController,
              hintText: 'Rate (Rs per kg)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                DropdownMenuItem(value: 'Not Paid', child: Text('Not Paid')),
              ],
              onChanged: (value) {
                setState(() {
                  status = value ?? 'Not Paid';
                });
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: calculateAmount,
                child: const Text('Calculate'),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    infoRow(
                      'Density Decimal',
                      densityDecimal.toStringAsFixed(2),
                    ),
                    infoRow('Kilograms', kilograms.toStringAsFixed(2)),
                    infoRow('Total Amount', totalAmount.toStringAsFixed(2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Purchase',
              onPressed: isLoading ? null : savePurchase,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
