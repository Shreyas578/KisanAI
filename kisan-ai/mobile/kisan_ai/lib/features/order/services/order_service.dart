import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/order_model.dart';

/// Service for handling order-related API calls
class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  /// Get orders with filters
  Future<List<Order>> getOrders({
    String? status, // pending, confirmed, shipped, delivered, cancelled
    String? type, // buying, selling
    String? sortBy, // date, amount
    bool? descending,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      if (descending != null) {
        queryParams['descending'] = descending;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (offset != null) {
        queryParams['offset'] = offset;
      }

      final response = await _apiClient.dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get orders: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.orders}/$orderId',
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Failed to get order: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.marketplaceOrders,
        data: order.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return Order.fromJson(responseData);
      } else {
        throw Exception('Failed to create order: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update an existing order
  Future<Order> updateOrder(String orderId, Order order) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.orders}/$orderId',
        data: order.toJson(),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Failed to update order: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.orders}/$orderId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel order: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get user's orders
  Future<List<Order>> getUserOrders(String userId, {
    String? type, // buying, selling
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final role = type ?? 'buyer';
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.marketplaceOrders}/$userId/$role',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user orders: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get order statistics for a user
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.orders}/user/$userId/statistics',
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to get order statistics: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}