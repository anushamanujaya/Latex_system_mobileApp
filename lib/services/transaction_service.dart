import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService {
  final ApiService _apiService = ApiService();

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiService.dio.get('/transactions');

    final data = response.data;

    if (data is List) {
      return data.map((item) => TransactionModel.fromJson(item)).toList();
    }

    if (data is Map<String, dynamic> && data['transactions'] is List) {
      return (data['transactions'] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<void> createTransaction({
    required String sellerName,
    required double liters,
    required double rate,
    required double amount,
  }) async {
    await _apiService.dio.post(
      '/transactions',
      data: {
        'sellerName': sellerName,
        'liters': liters,
        'rate': rate,
        'amount': amount,
      },
    );
  }
}
