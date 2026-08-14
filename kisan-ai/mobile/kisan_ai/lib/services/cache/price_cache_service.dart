import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Service for caching commodity prices locally
class PriceCacheService {
  static const String _boxName = 'price_cache';
  late Box<String> _box;

  /// Initialize cache
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Cache price data
  Future<void> cachePrice(
    String commodity,
    String state,
    Map<String, dynamic> priceData,
  ) async {
    final key = '${commodity}_${state}';
    final data = {
      'commodity': commodity,
      'state': state,
      'data': priceData,
      'fetchedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(hours: 12)).toIso8601String(),
    };
    await _box.put(key, jsonEncode(data));
    print('✅ Cached price for $commodity in $state');
  }

  /// Get cached price
  Future<Map<String, dynamic>?> getCachedPrice(
    String commodity,
    String state,
  ) async {
    final key = '${commodity}_${state}';
    final data = _box.get(key);

    if (data == null) return null;

    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(decoded['expiresAt'] as String);

      return {
        'data': decoded['data'],
        'fetchedAt': decoded['fetchedAt'],
        'isStale': DateTime.now().isAfter(expiresAt),
      };
    } catch (e) {
      print('Error decoding cached price: $e');
      return null;
    }
  }

  /// Get all cached prices
  Future<List<Map<String, dynamic>>> getAllCachedPrices() async {
    final result = <Map<String, dynamic>>[];

    for (final entry in _box.values) {
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        result.add(decoded);
      } catch (e) {
        print('Error decoding cached entry: $e');
      }
    }

    return result;
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    final keysToDelete = <String>[];

    for (final entry in _box.entries) {
      try {
        final decoded = jsonDecode(entry.value) as Map<String, dynamic>;
        final expiresAt = DateTime.parse(decoded['expiresAt'] as String);
        if (now.isAfter(expiresAt)) {
          keysToDelete.add(entry.key);
        }
      } catch (e) {
        print('Error checking cache expiry: $e');
      }
    }

    for (final key in keysToDelete) {
      await _box.delete(key);
    }

    if (keysToDelete.isNotEmpty) {
      print('🧹 Cleared ${keysToDelete.length} expired cache entries');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _box.clear();
    print('🧹 Cleared all price cache');
  }
}
