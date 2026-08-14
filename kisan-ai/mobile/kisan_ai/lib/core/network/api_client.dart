import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio client for API calls with interceptors for logging, error handling, and auth
class ApiClient {
  Dio _dio = Dio();
  final String _baseUrl;

  ApiClient(this._baseUrl) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));

    // Add ngrok bypass header
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';

    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        // Handle common error cases
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          handler.next(e.copyWith(
            error: Exception('Network timeout. Please check your connection.'),
          ));
          return;
        }
        handler.next(e);
      },
    ));
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Set authorization token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Set content type header
  void setContentType(String contentType) {
    _dio.options.headers['Content-Type'] = contentType;
  }

  /// Close the Dio instance
  void close() {
    _dio.close();
  }
}