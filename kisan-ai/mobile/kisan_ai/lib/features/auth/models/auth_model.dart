import 'dart:convert';

/// Login request model
class LoginRequest {
  final String phone;
  final String password;
  final String? fcmToken;

  LoginRequest({required this.phone, required this.password, this.fcmToken});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Login response model
class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final User? user;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }
}

/// User model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // farmer, buyer, supplier, admin
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'farmer',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Register request model
class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role; // farmer, buyer, supplier
  final String? fcmToken;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
