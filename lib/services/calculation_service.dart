import '../core/constants/density_map.dart';

class CalculationResult {
  final int density;
  final double densityDecimal;
  final double liters;
  final double kilograms;
  final double rate;
  final double totalAmount;

  CalculationResult({
    required this.density,
    required this.densityDecimal,
    required this.liters,
    required this.kilograms,
    required this.rate,
    required this.totalAmount,
  });
}

class CalculationService {
  static CalculationResult calculate({
    required double liters,
    required int density,
    required double rate,
  }) {
    final densityDecimal = densityMap[density];

    if (densityDecimal == null) {
      throw Exception('Invalid density value');
    }

    final kilograms = liters * densityDecimal;
    final totalAmount = kilograms * rate;

    return CalculationResult(
      density: density,
      densityDecimal: densityDecimal,
      liters: liters,
      kilograms: kilograms,
      rate: rate,
      totalAmount: totalAmount,
    );
  }
}
