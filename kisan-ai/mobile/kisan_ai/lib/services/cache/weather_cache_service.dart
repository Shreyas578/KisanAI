import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Service for caching weather data locally
class WeatherCacheService {
  static const String _boxName = 'weather_cache';
  late Box<String> _box;

  /// Initialize cache
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Cache weather data
  Future<void> cacheWeather(
    double latitude,
    double longitude,
    Map<String, dynamic> weatherData,
  ) async {
    final key = '${latitude}_${longitude}';
    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'data': weatherData,
      'fetchedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(hours: 3)).toIso8601String(),
    };
    await _box.put(key, jsonEncode(data));
    print('✅ Cached weather for ($latitude, $longitude)');
  }

  /// Get cached weather
  Future<Map<String, dynamic>?> getCachedWeather(
    double latitude,
    double longitude,
  ) async {
    final key = '${latitude}_${longitude}';
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
      return null;
    }
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
        print('Error checking weather cache expiry: $e');
      }
    }

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }
}
