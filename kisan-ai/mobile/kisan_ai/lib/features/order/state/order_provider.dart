import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/network/authenticated_api_client_provider.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/order/services/order_service.dart';
import 'package:kisan_ai/shared/models/order_model.dart';

/// Provider for ApiClient with authentication
final orderApiClientProvider = FutureProvider<ApiClient>((ref) async {
  return createAuthenticatedApiClient(ref, ApiConstants.baseUrl);
});

/// Provider for OrderService - kept as regular provider for backwards compatibility
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ApiClient(ApiConstants.baseUrl));
});

/// Provider for getting orders with filters
final ordersProvider = FutureProvider.family<List<Order>, Map<String, dynamic>>(
  (ref, filters) async {
    final apiClient = await ref.read(orderApiClientProvider.future);
    final service = OrderService(apiClient);
    return service.getOrders(
      status: filters['status'] as String?,
      type: filters['type'] as String?,
      sortBy: filters['sortBy'] as String?,
      descending: filters['descending'] as bool?,
      limit: filters['limit'] as int?,
      offset: filters['offset'] as int?,
    );
  },
);

/// Provider for getting a specific order by ID
final orderProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final apiClient = await ref.read(orderApiClientProvider.future);
  final service = OrderService(apiClient);
  return service.getOrderById(orderId);
});

/// Provider for getting user's orders
final userOrdersProvider =
    FutureProvider.family<List<Order>, String>((
      ref,
      paramsStr, // Format: "userId_role"
    ) async {
      final parts = paramsStr.split('_');
      final userId = parts[0];
      final role = parts.length > 1 ? parts[1] : 'buyer';
      
      final apiClient = await ref.read(orderApiClientProvider.future);
      final service = OrderService(apiClient);
      return service.getUserOrders(
        userId,
        type: role,
        limit: 20,
        offset: 0,
      );
    });

/// Provider for getting order statistics for a user
final orderStatisticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      final apiClient = await ref.read(orderApiClientProvider.future);
      final service = OrderService(apiClient);
      return service.getOrderStatistics(userId);
    });
