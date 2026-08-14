import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/input_management/pesticide/services/pesticide_service.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

/// Provider for ApiClient
final pesticideApiClientProvider = Provider<ApiClient>((ref) {
  // Use ApiConstants which points to localhost:3000 in development
  return ApiClient(ApiConstants.baseUrl);
});

/// Provider for PesticideService
final pesticideServiceProvider = Provider<PesticideService>((ref) {
  final apiClient = ref.read(pesticideApiClientProvider);
  return PesticideService(apiClient);
});

/// Provider for getting pesticide schedules with filters
final pesticideSchedulesProvider =
    FutureProvider.family<List<PesticideSchedule>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.getSchedules(
        farmId: filters['farmId'] as String?,
        cropType: filters['cropType'] as String?,
        status: filters['status'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for getting a specific pesticide schedule by ID
final pesticideScheduleProvider =
    FutureProvider.family<PesticideSchedule, String>((ref, scheduleId) {
      final service = ref.read(pesticideServiceProvider);
      return service.getScheduleById(scheduleId);
    });

/// Provider for creating a pesticide schedule
final createPesticideScheduleProvider =
    FutureProvider.family<PesticideSchedule, PesticideSchedule>((
      ref,
      schedule,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.createSchedule(schedule);
    });

/// Provider for updating a pesticide schedule
final updatePesticideScheduleProvider =
    FutureProvider.family<PesticideSchedule, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.updateSchedule(
        params['scheduleId'] as String,
        PesticideSchedule.fromJson(params['schedule'] as Map<String, dynamic>),
      );
    });

/// Provider for deleting a pesticide schedule
final deletePesticideScheduleProvider = FutureProvider.family<bool, String>((
  ref,
  scheduleId,
) {
  final service = ref.read(pesticideServiceProvider);
  return service.deleteSchedule(scheduleId);
});

/// Provider for getting pesticide application history
final pesticideApplicationHistoryProvider =
    FutureProvider.family<List<PesticideApplication>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.getApplicationHistory(
        scheduleId: filters['scheduleId'] as String?,
        farmId: filters['farmId'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for getting a specific pesticide application by ID
final pesticideApplicationProvider =
    FutureProvider.family<PesticideApplication, String>((ref, applicationId) {
      final service = ref.read(pesticideServiceProvider);
      return service.getApplicationById(applicationId);
    });

/// Provider for executing a pesticide schedule
final executePesticideScheduleProvider =
    FutureProvider.family<PesticideApplication, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.executeSchedule(
        params['scheduleId'] as String,
        actualPesticideAmount: params['actualPesticideAmount'] as double?,
        pesticideTypeUsed: params['pesticideTypeUsed'] as String?,
        notes: params['notes'] as String?,
      );
    });

/// Provider for getting pesticide recommendations
final pesticideRecommendationsProvider =
    FutureProvider.family<List<PesticideRecommendation>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(pesticideServiceProvider);
      return service.getRecommendations(
        params['farmId'] as String,
        cropType: params['cropType'] as String?,
        growthStage: params['growthStage'] as String?,
        pestType: params['pestType'] as String?,
      );
    });
