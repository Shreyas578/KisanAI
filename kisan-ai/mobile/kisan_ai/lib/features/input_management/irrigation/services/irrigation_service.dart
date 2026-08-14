import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/irrigation_model.dart';

/// Service for handling irrigation-related API calls
class IrrigationService {
  final ApiClient _apiClient;

  IrrigationService(this._apiClient);

  /// Get irrigation schedules with filters
  Future<List<IrrigationSchedule>> getSchedules({
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
        ApiConstants.irrigationSchedules,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => IrrigationSchedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get irrigation schedules: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific irrigation schedule by ID
  Future<IrrigationSchedule> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.irrigationSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return IrrigationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to get irrigation schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new irrigation schedule
  Future<IrrigationSchedule> createSchedule(IrrigationSchedule schedule) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.irrigationSchedules,
        data: schedule.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IrrigationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to create irrigation schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing irrigation schedule
  Future<IrrigationSchedule> updateSchedule(String scheduleId, IrrigationSchedule schedule) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.irrigationSchedules}/$scheduleId',
        data: schedule.toJson(),
      );

      if (response.statusCode == 200) {
        return IrrigationSchedule.fromJson(response.data);
      } else {
        throw Exception('Failed to update irrigation schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete an irrigation schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.irrigationSchedules}/$scheduleId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete irrigation schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get irrigation execution history
  Future<List<IrrigationExecution>> getExecutionHistory({
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
        ApiConstants.irrigationExecutions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => IrrigationExecution.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get irrigation execution history: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Execute an irrigation schedule
  Future<IrrigationExecution> executeSchedule(String scheduleId, {
    double? actualWaterAmount,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.irrigationSchedules}/$scheduleId/execute',
        data: {
          if (actualWaterAmount != null) 'actual_water_amount': actualWaterAmount,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IrrigationExecution.fromJson(response.data);
      } else {
        throw Exception('Failed to execute irrigation schedule: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get irrigation recommendations for a farm
  Future<List<IrrigationRecommendation>> getRecommendations(String farmId, {
    String? cropType,
    String? growthStage,
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

      final response = await _apiClient.dio.get(
        '${ApiConstants.irrigationSchedules}/recommendations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => IrrigationRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get irrigation recommendations: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}