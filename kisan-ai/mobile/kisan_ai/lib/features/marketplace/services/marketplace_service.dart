import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';

/// Service for handling marketplace-related API calls
class MarketplaceService {
  final ApiClient _apiClient;

  MarketplaceService(this._apiClient);

  /// Get marketplace listings with filters
  Future<List<MarketplaceListing>> getListings({
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? location,
    bool? verifiedOnly,
    String? sortBy, // newest, price_low_high, price_high_low
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (verifiedOnly != null) {
        queryParams['verified_only'] = verifiedOnly;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      final response = await _apiClient.dio.get(
        ApiConstants.marketplaceListings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MarketplaceListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get marketplace listings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific listing by ID
  Future<MarketplaceListing> getListingById(String listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.marketplaceListings}/$listingId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return MarketplaceListing.fromJson(data);
      } else {
        throw Exception('Failed to get listing: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new marketplace listing
  Future<MarketplaceListing> createListing(MarketplaceListing listing) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.marketplaceCreateListing,
        data: listing.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return MarketplaceListing.fromJson(data);
      } else {
        throw Exception('Failed to create listing: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing marketplace listing
  Future<MarketplaceListing> updateListing(String listingId, MarketplaceListing listing) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.marketplaceListings}/$listingId',
        data: listing.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return MarketplaceListing.fromJson(data);
      } else {
        throw Exception('Failed to update listing: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a marketplace listing
  Future<bool> deleteListing(String listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.marketplaceListings}/$listingId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete listing: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get user's marketplace listings
  Future<List<MarketplaceListing>> getUserListings(String userId, {
    String? status, // active, inactive, sold
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'user_id': userId,
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.marketplaceListings}/user',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MarketplaceListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user listings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get marketplace categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.marketplaceListings}/categories',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return List<String>.from(data);
      } else {
        throw Exception('Failed to get categories: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get featured/popular listings
  Future<List<MarketplaceListing>> getFeaturedListings({int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.marketplaceListings}/featured',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MarketplaceListing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get featured listings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}