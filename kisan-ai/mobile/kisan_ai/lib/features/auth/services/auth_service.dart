import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/features/auth/models/auth_model.dart';

/// Service for handling authentication-related API calls
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.authRegister,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Logout user
  Future<AuthResponse> logout() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.authLogout);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        return AuthResponse(
          success: false,
          message: response.data['message'] ?? 'Logout failed',
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Handle Dio exceptions and convert to user-friendly messages
  AuthResponse _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AuthResponse(
          success: false,
          message: 'Network timeout. Please check your connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'An error occurred';
        return AuthResponse(
          success: false,
          message: 'Error $statusCode: $errorMessage',
        );
      case DioExceptionType.cancel:
        return AuthResponse(
          success: false,
          message: 'Request was cancelled',
        );
      default:
        return AuthResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
    }
  }
}