import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool isLoggedIn = false;

  Future<bool> checkLoginStatus() async {
    final token = await _storage.read(key: 'token');
    isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      final token = result['token']?.toString() ?? '';
      if (token.isNotEmpty) {
        await _storage.write(key: 'token', value: token);
        isLoggedIn = true;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    isLoggedIn = false;
    notifyListeners();
  }
}
