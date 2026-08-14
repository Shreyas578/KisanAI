import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/network/authenticated_api_client_provider.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/marketplace/services/marketplace_service.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';

/// Provider for ApiClient with authentication
final marketplaceApiClientProvider = FutureProvider<ApiClient>((ref) async {
  return createAuthenticatedApiClient(ref, ApiConstants.baseUrl);
});

/// Provider for MarketplaceService - kept as regular provider for backwards compatibility
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ApiClient(ApiConstants.baseUrl));
});

/// Provider for getting marketplace listings with filters
final marketplaceListingsProvider =
    FutureProvider.family<List<MarketplaceListing>, Map<String, dynamic>>((
      ref,
      filters,
    ) async {
      final apiClient = await ref.read(marketplaceApiClientProvider.future);
      final service = MarketplaceService(apiClient);
      return service.getListings(
        category: filters['category'] as String?,
        searchQuery: filters['searchQuery'] as String?,
        minPrice: filters['minPrice'] as double?,
        maxPrice: filters['maxPrice'] as double?,
        location: filters['location'] as String?,
        verifiedOnly: filters['verifiedOnly'] as bool?,
        sortBy: filters['sortBy'] as String?,
        limit: filters['limit'] as int? ?? 20,
        offset: filters['offset'] as int? ?? 0,
      );
    });

/// Provider for getting a specific listing by ID
final marketplaceListingProvider =
    FutureProvider.family<MarketplaceListing, String>((ref, listingId) async {
      final apiClient = await ref.read(marketplaceApiClientProvider.future);
      final service = MarketplaceService(apiClient);
      return service.getListingById(listingId);
    });

/// Provider for getting user's listings
final userMarketplaceListingsProvider =
    FutureProvider.family<List<MarketplaceListing>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final apiClient = await ref.read(marketplaceApiClientProvider.future);
      final service = MarketplaceService(apiClient);
      final userId = params['userId'] as String;
      
      // Since backend doesn't have a dedicated user filter yet, fetch all and filter locally
      final allListings = await service.getListings(limit: 100); // Fetch a reasonable amount
      
      var userListings = allListings.where((l) => l.sellerId == userId).toList();
      
      if (params['status'] != null && params['status'] != 'all') {
        userListings = userListings.where((l) => l.status == params['status']).toList();
      }
      
      return userListings;
    });

/// Provider for getting marketplace categories
final marketplaceCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiClient = await ref.read(marketplaceApiClientProvider.future);
  final service = MarketplaceService(apiClient);
  return service.getCategories();
});

/// Provider for getting featured listings
final featuredMarketplaceListingsProvider =
    FutureProvider.family<List<MarketplaceListing>, int>((ref, limit) async {
      final apiClient = await ref.read(marketplaceApiClientProvider.future);
      final service = MarketplaceService(apiClient);
      return service.getFeaturedListings(limit: limit);
    });
