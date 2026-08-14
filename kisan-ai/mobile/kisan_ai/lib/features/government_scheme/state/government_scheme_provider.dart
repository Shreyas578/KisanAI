import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/government_scheme/services/government_scheme_service.dart';
import 'package:kisan_ai/shared/models/government_scheme_model.dart';

/// Provider for ApiClient
final governmentSchemeApiClientProvider = Provider<ApiClient>((ref) {
  // Use ApiConstants which points to localhost:3000 in development
  return ApiClient(ApiConstants.baseUrl);
});

/// Provider for GovernmentSchemeService
final governmentSchemeServiceProvider = Provider<GovernmentSchemeService>((
  ref,
) {
  final apiClient = ref.read(governmentSchemeApiClientProvider);
  return GovernmentSchemeService(apiClient);
});

/// Provider for getting schemes with filters
final governmentSchemesProvider =
    FutureProvider.family<List<GovernmentScheme>, String>((
      ref,
      filtersStr,
    ) {
      // filtersStr format: schemeType|cropType|farmerType|activeOnly
      final parts = filtersStr.split('|');
      final schemeType = parts[0].isEmpty ? null : parts[0];
      final cropType = parts[1].isEmpty ? null : parts[1];
      final farmerType = parts[2].isEmpty ? null : parts[2];
      final activeOnly = parts[3] == 'true';

      final service = ref.read(governmentSchemeServiceProvider);
      return service.getSchemes(
        schemeType: schemeType,
        cropType: cropType,
        farmerType: farmerType,
        activeOnly: activeOnly,
      );
    });

/// Provider for getting a specific scheme by ID
final governmentSchemeProvider =
    FutureProvider.family<GovernmentScheme, String>((ref, schemeId) {
      final service = ref.read(governmentSchemeServiceProvider);
      return service.getSchemeById(schemeId);
    });

/// Provider for applying for a scheme
final applyForSchemeProvider =
    FutureProvider.family<FarmerSchemeApplication, FarmerSchemeApplication>((
      ref,
      application,
    ) {
      final service = ref.read(governmentSchemeServiceProvider);
      return service.applyForScheme(application);
    });

/// Provider for getting user's applications
final userSchemeApplicationsProvider =
    FutureProvider.family<List<FarmerSchemeApplication>, String>((
      ref,
      farmerId,
    ) {
      final service = ref.read(governmentSchemeServiceProvider);
      return service.getUserApplications(farmerId);
    });

/// Provider for getting a specific application by ID
final schemeApplicationProvider =
    FutureProvider.family<FarmerSchemeApplication, String>((
      ref,
      applicationId,
    ) {
      final service = ref.read(governmentSchemeServiceProvider);
      return service.getApplicationById(applicationId);
    });

/// Provider for updating application status
final updateApplicationStatusProvider =
    FutureProvider.family<FarmerSchemeApplication, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final service = ref.read(governmentSchemeServiceProvider);
      return service.updateApplicationStatus(
        params['applicationId'] as String,
        params['status'] as String,
        approvalReference: params['approvalReference'] as String?,
        remarks: params['remarks'] as String?,
      );
    });
