import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  bool isLoading = false;
  List<TransactionModel> transactions = [];

  Future<void> fetchTransactions() async {
    isLoading = true;
    notifyListeners();

    try {
      transactions = await _transactionService.getTransactions();
    } catch (e) {
      transactions = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required String sellerName,
    required double liters,
    required double rate,
    required double amount,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _transactionService.createTransaction(
        sellerName: sellerName,
        liters: liters,
        rate: rate,
        amount: amount,
      );
      await fetchTransactions();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
