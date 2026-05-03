
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_1123150059/core/constants/api_constants.dart';
import 'package:uts_1123150059/core/services/secure_storage.dart';


class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio(); // Singleton pattern
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor 1: Logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('[REQUEST] ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[RESPONSE] ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('[ERROR] ${error.response?.statusCode}');
          if (error.response?.statusCode == 401) {
            await SecureStorage.clearAll(); // Auto logout
          }
          handler.next(error);
        },
      ),
    );

    // Interceptor 2: Auto-inject Bearer Token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    return dio;
  }
}
