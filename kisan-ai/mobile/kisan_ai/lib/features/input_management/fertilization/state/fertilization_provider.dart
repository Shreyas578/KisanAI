import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/input_management/fertilization/services/fertilization_service.dart';
import 'package:kisan_ai/shared/models/fertilization_model.dart';

/// Provider for ApiClient
final fertilizationApiClientProvider = Provider<ApiClient>((ref) {
  // Use ApiConstants which points to localhost:3000 in development
  return ApiClient(ApiConstants.baseUrl);
});

/// Provider for FertilizationService
final fertilizationServiceProvider = Provider<FertilizationService>((ref) {
  final apiClient = ref.read(fertilizationApiClientProvider);
  return FertilizationService(apiClient);
});

/// Provider for getting fertilization schedules with filters
final fertilizationSchedulesProvider =
    FutureProvider.family<List<FertilizationSchedule>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.getSchedules(
        farmId: filters['farmId'] as String?,
        cropType: filters['cropType'] as String?,
        status: filters['status'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for getting a specific fertilization schedule by ID
final fertilizationScheduleProvider =
    FutureProvider.family<FertilizationSchedule, String>((ref, scheduleId) {
      final service = ref.read(fertilizationServiceProvider);
      return service.getScheduleById(scheduleId);
    });

/// Provider for creating a fertilization schedule
final createFertilizationScheduleProvider =
    FutureProvider.family<FertilizationSchedule, FertilizationSchedule>((
      ref,
      schedule,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.createSchedule(schedule);
    });

/// Provider for updating a fertilization schedule
final updateFertilizationScheduleProvider =
    FutureProvider.family<FertilizationSchedule, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.updateSchedule(
        params['scheduleId'] as String,
        FertilizationSchedule.fromJson(
          params['schedule'] as Map<String, dynamic>,
        ),
      );
    });

/// Provider for deleting a fertilization schedule
final deleteFertilizationScheduleProvider = FutureProvider.family<bool, String>(
  (ref, scheduleId) {
    final service = ref.read(fertilizationServiceProvider);
    return service.deleteSchedule(scheduleId);
  },
);

/// Provider for getting fertilization execution history
final fertilizationExecutionHistoryProvider =
    FutureProvider.family<List<FertilizationExecution>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.getApplicationHistory(
        scheduleId: filters['scheduleId'] as String?,
        farmId: filters['farmId'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for executing a fertilization schedule
final executeFertilizationScheduleProvider =
    FutureProvider.family<FertilizationExecution, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.executeSchedule(
        params['scheduleId'] as String,
        actualFertilizerAmount: params['actualFertilizerAmount'] as double?,
        notes: params['notes'] as String?,
      );
    });

/// Provider for getting a specific fertilization application by ID
final fertilizationApplicationProvider =
    FutureProvider.family<FertilizationApplication, String>((
      ref,
      applicationId,
    ) {
      final service = ref.read(fertilizationServiceProvider);
      return service.getApplicationById(applicationId);
    });

/// Provider for getting fertilization recommendations
final fertilizationRecommendationsProvider =
    FutureProvider.family<
      List<FertilizationRecommendation>,
      Map<String, dynamic>
    >((ref, params) {
      final service = ref.read(fertilizationServiceProvider);
      return service.getRecommendations(
        params['farmId'] as String,
        cropType: params['cropType'] as String?,
        growthStage: params['growthStage'] as String?,
      );
    });
