import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/features/auth/repository/auth_repository.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';

/// Helper function to create an API client with authentication token
Future<ApiClient> createAuthenticatedApiClient(Ref ref, String baseUrl) async {
  final apiClient = ApiClient(baseUrl);

  // Watch the auth state so this provider rebuilds when auth status/token changes
  ref.watch(authProvider);

  // Get the access token from auth repository
  final authRepo = ref.watch(authRepositoryProvider);
  final accessToken = await authRepo.getAccessToken();

  // Set the token if available
  if (accessToken != null && accessToken.isNotEmpty) {
    apiClient.setToken(accessToken);
  }

  return apiClient;
}

/// Provider for a generic authenticated API client
final authenticatedApiClientProvider = FutureProvider.family<ApiClient, String>(
  (ref, baseUrl) async {
    return createAuthenticatedApiClient(ref, baseUrl);
  },
);
