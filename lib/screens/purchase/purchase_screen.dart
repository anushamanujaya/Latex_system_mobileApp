import 'package:flutter/material.dart';
import '../../services/local_db_service.dart';
import '../../services/calculation_service.dart';
import '../../services/voice_service.dart';
import '../../services/voice_purchase_parser.dart';
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

  final VoiceService _voiceService = VoiceService();

  double densityDecimal = 0;
  double kilograms = 0;
  double totalAmount = 0;
  bool isLoading = false;
  bool isListening = false;
  String status = 'Not Paid';
  String spokenText = '';

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

  Future<void> startVoiceInput() async {
    final ok = await _voiceService.init();

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission not available')),
      );
      return;
    }

    setState(() {
      isListening = true;
      spokenText = '';
    });

    await _voiceService.startListening(
      onResult: (text) {
        final parsed = VoicePurchaseParser.parse(text);

        setState(() {
          spokenText = text;

          if ((parsed['sellerName'] ?? '').toString().isNotEmpty) {
            sellerController.text = parsed['sellerName'].toString();
          }

          final liters = parsed['liters'];
          if (liters != null && liters != 0) {
            litersController.text = liters.toString();
          }

          final density = parsed['density'];
          if (density != null && density != 0) {
            densityController.text = density.toString();
          }

          final rate = parsed['rate'];
          if (rate != null && rate != 0) {
            rateController.text = rate.toString();
          }

          status = parsed['status']?.toString() ?? 'Not Paid';
        });

        final hasEnoughData =
            (double.tryParse(litersController.text.trim()) ?? 0) > 0 &&
            (int.tryParse(densityController.text.trim()) ?? 0) > 0 &&
            (double.tryParse(rateController.text.trim()) ?? 0) > 0;

        if (hasEnoughData) {
          calculateAmount();
        }
      },
    );
  }

  Future<void> stopVoiceInput() async {
    await _voiceService.stopListening();
    if (!mounted) return;
    setState(() {
      isListening = false;
    });
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
        spokenText = '';
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
    _voiceService.stopListening();
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

  Widget buildVoiceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening ? Colors.red : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isListening ? 'Listening...' : 'Voice Purchase',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (spokenText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(spokenText),
              ),
            if (spokenText.isNotEmpty) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isListening ? null : startVoiceInput,
                    icon: const Icon(Icons.mic),
                    label: const Text('Start Voice'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isListening ? stopVoiceInput : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            buildVoiceSection(),
            const SizedBox(height: 16),
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
              child: Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: calculateAmount,
                    child: const Text('Calculate'),
                  ),
                  TextButton(
                    onPressed: () {
                      sellerController.clear();
                      litersController.clear();
                      densityController.clear();
                      rateController.clear();

                      setState(() {
                        densityDecimal = 0;
                        kilograms = 0;
                        totalAmount = 0;
                        status = 'Not Paid';
                        spokenText = '';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
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
