import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return response.data;
  }
}
