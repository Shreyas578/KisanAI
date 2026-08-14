import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Service for caching agricultural news locally
class NewsCacheService {
  static const String _boxName = 'news_cache';
  late Box<String> _box;

  /// Initialize cache
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Cache news articles
  Future<void> cacheNews(List<Map<String, dynamic>> articles) async {
    final data = {
      'articles': articles,
      'fetchedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(hours: 6)).toIso8601String(),
    };
    await _box.put('cached_news', jsonEncode(data));
    print('✅ Cached ${articles.length} news articles');
  }

  /// Get cached news
  Future<List<Map<String, dynamic>>?> getCachedNews() async {
    final data = _box.get('cached_news');

    if (data == null) return null;

    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(decoded['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        return null; // Cache expired
      }

      return List<Map<String, dynamic>>.from(decoded['articles'] as List);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _box.delete('cached_news');
  }
}
