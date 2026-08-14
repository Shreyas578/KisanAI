import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';

/// Repository for handling authentication operations
class AuthRepository {
  final AuthService _authService;
  final Ref _ref;

  AuthRepository(this._authService, this._ref);

  // Key constants for shared preferences
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userInfoKey = 'user_info';

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _authService.login(request);

      if (response.success && response.accessToken != null) {
        // Save tokens to secure storage
        await _saveTokens(response.accessToken!, response.refreshToken);
        // Save user info
        if (response.user != null) {
          await _saveUserInfo(response.user!);
        }
      }

      return response;
    } catch (e) {
      return AuthResponse(success: false, message: 'Login failed: $e');
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _authService.register(request);

      if (response.success && response.accessToken != null) {
        // Save tokens to secure storage
        await _saveTokens(response.accessToken!, response.refreshToken);
        // Save user info
        if (response.user != null) {
          await _saveUserInfo(response.user!);
        }
      }

      return response;
    } catch (e) {
      return AuthResponse(success: false, message: 'Registration failed: $e');
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      await _clearUserData();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        return AuthResponse(
          success: false,
          message: 'No refresh token available',
        );
      }

      final response = await _authService.refreshToken(refreshToken);

      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
      }

      return response;
    } catch (e) {
      return AuthResponse(success: false, message: 'Token refresh failed: $e');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userInfoKey);

      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await _getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Get the access token
  Future<String?> getAccessToken() async {
    return _getAccessToken();
  }

  // Private helper methods

  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> _saveUserInfo(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, jsonEncode(user.toJson()));
  }

  Future<User?> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userInfoKey);

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userInfoKey);
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Create API client with base URL from constants
  final apiClient = ApiClient(ApiConstants.baseUrl);
  final authService = AuthService(apiClient);
  return AuthRepository(authService, ref);
});
