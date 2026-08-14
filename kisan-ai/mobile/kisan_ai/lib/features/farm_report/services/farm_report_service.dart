import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/farm_report_model.dart';

/// Service for handling farm report-related API calls
class FarmReportService {
  final ApiClient _apiClient;

  FarmReportService(this._apiClient);

  /// Generate a new farm report for the given farm ID
  Future<FarmReport> generateFarmReport(String farmId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.farmReportGenerate}?farm_id=$farmId',
      );

      if (response.statusCode == 200) {
        return FarmReport.fromJson(response.data);
      } else {
        throw Exception('Failed to generate farm report: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get the latest farm report for the given farm ID
  Future<FarmReport> getLatestFarmReport(String farmId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.farmReport}?farm_id=$farmId',
      );

      if (response.statusCode == 200) {
        return FarmReport.fromJson(response.data);
      } else {
        throw Exception('Failed to get farm report: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get farm report history for the given farm ID
  Future<List<FarmReport>> getFarmReportHistory({
    required String farmId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'farm_id': farmId,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.dio.get(
        ApiConstants.farmReportHistory,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => FarmReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get farm report history: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get available report templates/types
  Future<List<String>> getReportTypes() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.farmReport}/types',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return List<String>.from(data);
      } else {
        throw Exception('Failed to get report types: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}