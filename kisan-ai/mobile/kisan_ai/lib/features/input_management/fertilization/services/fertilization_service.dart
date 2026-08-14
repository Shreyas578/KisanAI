import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/fertilization_model.dart';

/// Service for handling fertilization-related API calls
class FertilizationService {
  final ApiClient _apiClient;

  FertilizationService(this._apiClient);

  /// Get fertilization schedules with filters
  Future<List<FertilizationSchedule>> getSchedules({
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
        ApiConstants.fertilizationSchedules,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FertilizationSchedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get fertilization schedules: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific fertilization schedule by ID
  Future<FertilizationSchedule> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.fertilizationSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return FertilizationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to get fertilization schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new fertilization schedule
  Future<FertilizationSchedule> createSchedule(FertilizationSchedule schedule) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.fertilizationSchedules,
        data: schedule.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FertilizationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to create fertilization schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing fertilization schedule
  Future<FertilizationSchedule> updateSchedule(String scheduleId, FertilizationSchedule schedule) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.fertilizationSchedules}/$scheduleId',
        data: schedule.toJson(),
      );

      if (response.statusCode == 200) {
        return FertilizationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to update fertilization schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a fertilization schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.fertilizationSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete fertilization schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get fertilization application history
  Future<List<FertilizationApplication>> getApplicationHistory({
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
        ApiConstants.fertilizationApplications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FertilizationApplication.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get fertilization application history: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific fertilization application by ID
  Future<FertilizationApplication> getApplicationById(String applicationId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.fertilizationApplications}/$applicationId',
      );

      if (response.statusCode == 200) {
        return FertilizationApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to get fertilization application: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Execute a fertilization schedule
  Future<FertilizationApplication> executeSchedule(String scheduleId, {
    double? actualFertilizerAmount,
    String? fertilizerTypeUsed,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.fertilizationSchedules}/$scheduleId/execute',
        data: {
          if (actualFertilizerAmount != null) 'actual_fertilizer_amount': actualFertilizerAmount,
          if (fertilizerTypeUsed != null) 'fertilizer_type_used': fertilizerTypeUsed,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FertilizationApplication.fromJson(response.data);
      } else {
        throw Exception('Failed to execute fertilization schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get fertilization recommendations for a farm
  Future<List<FertilizationRecommendation>> getRecommendations(String farmId, {
    String? cropType,
    String? growthStage,
    String? soilType,
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
      if (soilType != null && soilType.isNotEmpty) {
        queryParams['soil_type'] = soilType;
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.fertilizationSchedules}/recommendations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FertilizationRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get fertilization recommendations: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}