import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/input_management/irrigation/services/irrigation_service.dart';
import 'package:kisan_ai/shared/models/irrigation_model.dart';

/// Provider for ApiClient
final irrigationApiClientProvider = Provider<ApiClient>((ref) {
  // Use ApiConstants which points to localhost:3000 in development
  return ApiClient(ApiConstants.baseUrl);
});

/// Provider for IrrigationService
final irrigationServiceProvider = Provider<IrrigationService>((ref) {
  final apiClient = ref.read(irrigationApiClientProvider);
  return IrrigationService(apiClient);
});

/// Provider for getting irrigation schedules with filters
final irrigationSchedulesProvider =
    FutureProvider.family<List<IrrigationSchedule>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(irrigationServiceProvider);
      return service.getSchedules(
        farmId: filters['farmId'] as String?,
        cropType: filters['cropType'] as String?,
        status: filters['status'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for getting a specific irrigation schedule by ID
final irrigationScheduleProvider =
    FutureProvider.family<IrrigationSchedule, String>((ref, scheduleId) {
      final service = ref.read(irrigationServiceProvider);
      return service.getScheduleById(scheduleId);
    });

/// Provider for creating an irrigation schedule
final createIrrigationScheduleProvider =
    FutureProvider.family<IrrigationSchedule, IrrigationSchedule>((
      ref,
      schedule,
    ) {
      final service = ref.read(irrigationServiceProvider);
      return service.createSchedule(schedule);
    });

/// Provider for updating an irrigation schedule
final updateIrrigationScheduleProvider =
    FutureProvider.family<IrrigationSchedule, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(irrigationServiceProvider);
      return service.updateSchedule(
        params['scheduleId'] as String,
        IrrigationSchedule.fromJson(params['schedule'] as Map<String, dynamic>),
      );
    });

/// Provider for deleting an irrigation schedule
final deleteIrrigationScheduleProvider = FutureProvider.family<bool, String>((
  ref,
  scheduleId,
) {
  final service = ref.read(irrigationServiceProvider);
  return service.deleteSchedule(scheduleId);
});

/// Provider for getting irrigation execution history
final irrigationExecutionHistoryProvider =
    FutureProvider.family<List<IrrigationExecution>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(irrigationServiceProvider);
      return service.getExecutionHistory(
        scheduleId: filters['scheduleId'] as String?,
        farmId: filters['farmId'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for executing an irrigation schedule
final executeIrrigationScheduleProvider =
    FutureProvider.family<IrrigationExecution, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(irrigationServiceProvider);
      return service.executeSchedule(
        params['scheduleId'] as String,
        actualWaterAmount: params['actualWaterAmount'] as double?,
        notes: params['notes'] as String?,
      );
    });

/// Provider for getting irrigation recommendations
final irrigationRecommendationsProvider =
    FutureProvider.family<List<IrrigationRecommendation>, Map<String, dynamic>>(
      (ref, params) {
        final service = ref.read(irrigationServiceProvider);
        return service.getRecommendations(
          params['farmId'] as String,
          cropType: params['cropType'] as String?,
          growthStage: params['growthStage'] as String?,
        );
      },
    );
