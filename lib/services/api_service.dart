import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiService() {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.headers = {'Content-Type': 'application/json'};

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}
