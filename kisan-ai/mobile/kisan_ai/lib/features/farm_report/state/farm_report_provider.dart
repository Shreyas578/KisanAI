import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/farm_report/services/farm_report_service.dart';
import 'package:kisan_ai/shared/models/farm_report_model.dart';

/// Provider for ApiClient
final farmReportApiClientProvider = Provider<ApiClient>((ref) {
  // Use ApiConstants which points to localhost:3000 in development
  return ApiClient(ApiConstants.baseUrl);
});

/// Provider for FarmReportService
final farmReportServiceProvider = Provider<FarmReportService>((ref) {
  final apiClient = ref.read(farmReportApiClientProvider);
  return FarmReportService(apiClient);
});

/// Provider for generating a farm report
final generateFarmReportProvider = FutureProvider.family<FarmReport, String>((
  ref,
  farmId,
) {
  final service = ref.read(farmReportServiceProvider);
  return service.generateFarmReport(farmId);
});

/// Provider for getting the latest farm report
final latestFarmReportProvider = FutureProvider.family<FarmReport, String>((
  ref,
  farmId,
) {
  final service = ref.read(farmReportServiceProvider);
  return service.getLatestFarmReport(farmId);
});

/// Provider for getting farm report history
final farmReportHistoryProvider =
    FutureProvider.family<List<FarmReport>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(farmReportServiceProvider);
      return service.getFarmReportHistory(
        farmId: params['farmId'] as String,
        limit: params['limit'] as int?,
        offset: params['offset'] as int?,
      );
    });
