import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/government_scheme_model.dart';

/// Service for handling government scheme-related API calls
class GovernmentSchemeService {
  final ApiClient _apiClient;

  GovernmentSchemeService(this._apiClient);

  /// Get schemes with filters
  Future<List<GovernmentScheme>> getSchemes({
    String? schemeType,
    String? cropType,
    String? farmerType,
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (schemeType != null && schemeType.isNotEmpty) {
        queryParams['scheme_type'] = schemeType;
      }
      if (cropType != null && cropType.isNotEmpty) {
        queryParams['crop_type'] = cropType;
      }
      if (farmerType != null && farmerType.isNotEmpty) {
        queryParams['farmer_type'] = farmerType;
      }
      if (activeOnly != null) {
        queryParams['active_only'] = activeOnly;
      }

      final response = await _apiClient.dio.get(
        ApiConstants.governmentSchemes,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => GovernmentScheme.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get schemes: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get scheme by ID
  Future<GovernmentScheme> getSchemeById(String schemeId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.governmentSchemes}/$schemeId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return GovernmentScheme.fromJson(data);
      } else {
        throw Exception('Failed to get scheme: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Apply for scheme
  Future<FarmerSchemeApplication> applyForScheme(FarmerSchemeApplication application) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.governmentSchemeApplications,
        data: application.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return FarmerSchemeApplication.fromJson(data);
      } else {
        throw Exception('Failed to apply for scheme: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get user's applications
  Future<List<FarmerSchemeApplication>> getUserApplications(String farmerId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.governmentSchemeApplications}/user',
        queryParameters: {
          'farmer_id': farmerId,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FarmerSchemeApplication.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user applications: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get application by ID
  Future<FarmerSchemeApplication> getApplicationById(String applicationId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.governmentSchemeApplications}/$applicationId',
      );

      if (response.statusCode == 200) {
        return FarmerSchemeApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to get application: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update application status (for officials)
  Future<FarmerSchemeApplication> updateApplicationStatus(
    String applicationId,
    String status, {
    String? approvalReference,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.governmentSchemeApplications}/$applicationId/status',
        data: {
          'status': status,
          if (approvalReference != null) 'approval_reference': approvalReference,
          if (remarks != null) 'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        return FarmerSchemeApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to update application status: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}