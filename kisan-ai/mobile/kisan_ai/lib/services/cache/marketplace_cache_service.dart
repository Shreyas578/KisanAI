import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Service for caching marketplace listings and orders
class MarketplaceCacheService {
  static const String _boxName = 'marketplace_cache';
  late Box<String> _box;

  /// Initialize cache
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      print('✅ Marketplace cache initialized');
    } catch (e) {
      print('❌ Cache init error: $e');
      rethrow;
    }
  }

  /// Cache marketplace listings
  Future<void> cacheListings(List<Map<String, dynamic>> listings) async {
    try {
      final data = {
        'listings': listings,
        'fetchedAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
      };
      await _box.put('marketplace_listings', jsonEncode(data));
      print('✅ Cached ${listings.length} marketplace listings');
    } catch (e) {
      print('❌ Cache listings error: $e');
    }
  }

  /// Get cached listings
  Future<List<Map<String, dynamic>>?> getCachedListings() async {
    try {
      final data = _box.get('marketplace_listings');
      if (data == null) return null;

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(decoded['expiresAt'] as String);

      // Check if cache expired
      if (DateTime.now().isAfter(expiresAt)) {
        print('⚠️ Marketplace cache expired');
        return null;
      }

      final listings = List<Map<String, dynamic>>.from(
        decoded['listings'] as List,
      );
      print('✅ Retrieved ${listings.length} cached listings');
      return listings;
    } catch (e) {
      print('❌ Get cached listings error: $e');
      return null;
    }
  }

  /// Queue order for sync
  Future<void> queueOrder(Map<String, dynamic> order) async {
    try {
      final ordersJson = _box.get('pending_orders') ?? '[]';
      final orders = List<Map<String, dynamic>>.from(
        jsonDecode(ordersJson) as List,
      );

      orders.add({...order, 'queuedAt': DateTime.now().toIso8601String()});

      await _box.put('pending_orders', jsonEncode(orders));
      print('✅ Order queued for sync');
    } catch (e) {
      print('❌ Queue order error: $e');
    }
  }

  /// Get pending orders
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      final ordersJson = _box.get('pending_orders') ?? '[]';
      final orders = List<Map<String, dynamic>>.from(
        jsonDecode(ordersJson) as List,
      );
      print('✅ Retrieved ${orders.length} pending orders');
      return orders;
    } catch (e) {
      print('❌ Get pending orders error: $e');
      return [];
    }
  }

  /// Remove synced order
  Future<void> removeSyncedOrder(String orderId) async {
    try {
      final ordersJson = _box.get('pending_orders') ?? '[]';
      final orders = List<Map<String, dynamic>>.from(
        jsonDecode(ordersJson) as List,
      );

      orders.removeWhere((o) => o['id'] == orderId);
      await _box.put('pending_orders', jsonEncode(orders));
      print('✅ Removed synced order: $orderId');
    } catch (e) {
      print('❌ Remove synced order error: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      await _box.clear();
      print('✅ Marketplace cache cleared');
    } catch (e) {
      print('❌ Clear cache error: $e');
    }
  }

  /// Get cache stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final listings = await getCachedListings();
      final orders = await getPendingOrders();

      return {
        'cachedListings': listings?.length ?? 0,
        'pendingOrders': orders.length,
        'totalItems': _box.length,
      };
    } catch (e) {
      print('❌ Get stats error: $e');
      return {};
    }
  }
}
