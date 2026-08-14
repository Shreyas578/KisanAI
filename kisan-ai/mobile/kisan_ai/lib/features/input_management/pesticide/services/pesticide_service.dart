import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

/// Service for handling pesticide-related API calls
class PesticideService {
  final ApiClient _apiClient;

  PesticideService(this._apiClient);

  /// Get pesticide schedules with filters
  Future<List<PesticideSchedule>> getSchedules({
    String? farmId,
    String? cropType,
    String? status, // active, inactive, completed
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (farmId != null && farmId.isNotEmpty) {
        queryParams['farm_id'] = farmId;
      }
      if (cropType != null && cropType.isNotEmpty) {
        queryParams['crop_type'] = cropType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.dio.get(
        ApiConstants.pesticideSchedules,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => PesticideSchedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pesticide schedules: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific pesticide schedule by ID
  Future<PesticideSchedule> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.pesticideSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return PesticideSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to get pesticide schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new pesticide schedule
  Future<PesticideSchedule> createSchedule(PesticideSchedule schedule) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.pesticideSchedules,
        data: schedule.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PesticideSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to create pesticide schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing pesticide schedule
  Future<PesticideSchedule> updateSchedule(String scheduleId, PesticideSchedule schedule) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.pesticideSchedules}/$scheduleId',
        data: schedule.toJson(),
      );

      if (response.statusCode == 200) {
        return PesticideSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to update pesticide schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a pesticide schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.pesticideSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete pesticide schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get pesticide application history
  Future<List<PesticideApplication>> getApplicationHistory({
    String? scheduleId,
    String? farmId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (scheduleId != null && scheduleId.isNotEmpty) {
        queryParams['schedule_id'] = scheduleId;
      }
      if (farmId != null && farmId.isNotEmpty) {
        queryParams['farm_id'] = farmId;
      }

      final response = await _apiClient.dio.get(
        ApiConstants.pesticideApplications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => PesticideApplication.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pesticide application history: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific pesticide application by ID
  Future<PesticideApplication> getApplicationById(String applicationId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.pesticideApplications}/$applicationId',
      );

      if (response.statusCode == 200) {
        return PesticideApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to get pesticide application: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Execute a pesticide schedule
  Future<PesticideApplication> executeSchedule(String scheduleId, {
    double? actualPesticideAmount,
    String? pesticideTypeUsed,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.pesticideSchedules}/$scheduleId/execute',
        data: {
          if (actualPesticideAmount != null) 'actual_pesticide_amount': actualPesticideAmount,
          if (pesticideTypeUsed != null) 'pesticide_type_used': pesticideTypeUsed,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PesticideApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to execute pesticide schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get pesticide recommendations for a farm
  Future<List<PesticideRecommendation>> getRecommendations(String farmId, {
    String? cropType,
    String? growthStage,
    String? pestType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'farm_id': farmId,
      };

      if (cropType != null && cropType.isNotEmpty) {
        queryParams['crop_type'] = cropType;
      }
      if (growthStage != null && growthStage.isNotEmpty) {
        queryParams['growth_stage'] = growthStage;
      }
      if (pestType != null && pestType.isNotEmpty) {
        queryParams['pest_type'] = pestType;
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.pesticideSchedules}/recommendations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => PesticideRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pesticide recommendations: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}