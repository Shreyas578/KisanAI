import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

/// Offline Cache Service - SQLite based caching
///
/// Caches prices, weather, marketplace listings, and other data
/// for offline access. Auto-syncs when online.

class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  static const String _dbName = 'kisan_offline.db';
  static const int _dbVersion = 1;

  late Database _db;
  bool _initialized = false;

  factory OfflineCacheService() {
    return _instance;
  }

  OfflineCacheService._internal();

  bool get isInitialized => _initialized;

  /// Initialize database
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      _db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);

      _initialized = true;
      print('✅ Offline cache initialized');
    } catch (e) {
      print('❌ Error initializing cache: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Price cache table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS price_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commodity TEXT NOT NULL,
        state TEXT NOT NULL,
        price REAL NOT NULL,
        min_price REAL,
        max_price REAL,
        market TEXT,
        unit TEXT,
        price_json TEXT,
        cached_at TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        UNIQUE(commodity, state, market)
      )
    ''');

    // Weather cache table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT NOT NULL UNIQUE,
        temperature REAL NOT NULL,
        humidity REAL,
        condition TEXT,
        wind_speed REAL,
        forecast_json TEXT,
        cached_at TEXT NOT NULL,
        valid_until TEXT NOT NULL
      )
    ''');

    // Marketplace listings cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS marketplace_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listing_id TEXT NOT NULL UNIQUE,
        seller_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity REAL,
        unit TEXT,
        category TEXT,
        images_json TEXT,
        location TEXT,
        listing_json TEXT,
        cached_at TEXT NOT NULL,
        valid_until TEXT NOT NULL
      )
    ''');

    // Disease detection cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS disease_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT,
        crop TEXT,
        disease TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT,
        treatment_json TEXT,
        recommendation_json TEXT,
        result_json TEXT,
        cached_at TEXT NOT NULL,
        UNIQUE(image_path, disease)
      )
    ''');

    // News cache
    await db.execute('''
      CREATE TABLE IF NOT EXISTS news_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        news_id TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        summary TEXT,
        content TEXT,
        source TEXT,
        url TEXT,
        category TEXT,
        cached_at TEXT NOT NULL,
        valid_until TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_price_commodity ON price_cache(commodity, state)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_weather_location ON weather_cache(location)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_marketplace_category ON marketplace_cache(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_disease_crop ON disease_cache(crop)',
    );

    print('✅ Database tables created');
  }

  // ============= PRICE CACHE =============

  /// Cache price data
  Future<void> cachePrice({
    required String commodity,
    required String state,
    required double price,
    double? minPrice,
    double? maxPrice,
    String? market,
    String? unit,
    Map<String, dynamic>? fullData,
  }) async {
    try {
      await _db.insert('price_cache', {
        'commodity': commodity,
        'state': state,
        'price': price,
        'min_price': minPrice,
        'max_price': maxPrice,
        'market': market,
        'unit': unit ?? 'quintal',
        'price_json': fullData != null ? jsonEncode(fullData) : null,
        'cached_at': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('❌ Error caching price: $e');
    }
  }

  /// Get cached price
  Future<Map<String, dynamic>?> getCachedPrice(
    String commodity,
    String state,
  ) async {
    try {
      final rows = await _db.query(
        'price_cache',
        where: 'commodity = ? AND state = ?',
        whereArgs: [commodity, state],
        orderBy: 'cached_at DESC',
        limit: 1,
      );

      if (rows.isEmpty) return null;

      final row = rows.first;
      final isStale = DateTime.now().isAfter(
        DateTime.parse(row['valid_until'] as String),
      );

      return {
        'price': row['price'],
        'minPrice': row['min_price'],
        'maxPrice': row['max_price'],
        'market': row['market'],
        'unit': row['unit'],
        'cachedAt': row['cached_at'],
        'isStale': isStale,
        'fullData': row['price_json'] != null
            ? jsonDecode(row['price_json'] as String)
            : null,
      };
    } catch (e) {
      print('❌ Error retrieving cached price: $e');
      return null;
    }
  }

  // ============= WEATHER CACHE =============

  /// Cache weather data
  Future<void> cacheWeather({
    required String location,
    required double temperature,
    double? humidity,
    String? condition,
    double? windSpeed,
    Map<String, dynamic>? forecast,
  }) async {
    try {
      await _db.insert('weather_cache', {
        'location': location,
        'temperature': temperature,
        'humidity': humidity,
        'condition': condition,
        'wind_speed': windSpeed,
        'forecast_json': forecast != null ? jsonEncode(forecast) : null,
        'cached_at': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now()
            .add(Duration(hours: 12))
            .toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('❌ Error caching weather: $e');
    }
  }

  /// Get cached weather
  Future<Map<String, dynamic>?> getCachedWeather(String location) async {
    try {
      final rows = await _db.query(
        'weather_cache',
        where: 'location = ?',
        whereArgs: [location],
        limit: 1,
      );

      if (rows.isEmpty) return null;

      final row = rows.first;
      final isStale = DateTime.now().isAfter(
        DateTime.parse(row['valid_until'] as String),
      );

      return {
        'temperature': row['temperature'],
        'humidity': row['humidity'],
        'condition': row['condition'],
        'windSpeed': row['wind_speed'],
        'cachedAt': row['cached_at'],
        'isStale': isStale,
        'forecast': row['forecast_json'] != null
            ? jsonDecode(row['forecast_json'] as String)
            : null,
      };
    } catch (e) {
      print('❌ Error retrieving cached weather: $e');
      return null;
    }
  }

  // ============= MARKETPLACE CACHE =============

  /// Cache marketplace listing
  Future<void> cacheMarketplaceListing({
    required String listingId,
    required String title,
    required double price,
    String? description,
    double? quantity,
    String? unit,
    String? category,
    String? location,
    List<String>? images,
    Map<String, dynamic>? fullData,
  }) async {
    try {
      await _db.insert('marketplace_cache', {
        'listing_id': listingId,
        'title': title,
        'price': price,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        'location': location,
        'images_json': images != null ? jsonEncode(images) : null,
        'listing_json': fullData != null ? jsonEncode(fullData) : null,
        'cached_at': DateTime.now().toIso8601String(),
        'valid_until': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('❌ Error caching listing: $e');
    }
  }

  /// Get all cached listings by category
  Future<List<Map<String, dynamic>>> getCachedListingsByCategory(
    String category,
  ) async {
    try {
      final rows = await _db.query(
        'marketplace_cache',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'cached_at DESC',
      );

      return rows.map((row) {
        final isStale = DateTime.now().isAfter(
          DateTime.parse(row['valid_until'] as String),
        );
        return {
          'listingId': row['listing_id'],
          'title': row['title'],
          'price': row['price'],
          'description': row['description'],
          'quantity': row['quantity'],
          'unit': row['unit'],
          'location': row['location'],
          'images': row['images_json'] != null
              ? List<String>.from(jsonDecode(row['images_json'] as String))
              : [],
          'cachedAt': row['cached_at'],
          'isStale': isStale,
          'fullData': row['listing_json'] != null
              ? jsonDecode(row['listing_json'] as String)
              : null,
        };
      }).toList();
    } catch (e) {
      print('❌ Error retrieving cached listings: $e');
      return [];
    }
  }

  // ============= DISEASE CACHE =============

  /// Cache disease detection result
  Future<void> cacheDiseaseResult({
    required String disease,
    required double confidence,
    String? imagePath,
    String? crop,
    String? severity,
    Map<String, dynamic>? treatment,
    Map<String, dynamic>? recommendation,
  }) async {
    try {
      await _db.insert('disease_cache', {
        'image_path': imagePath,
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'severity': severity,
        'treatment_json': treatment != null ? jsonEncode(treatment) : null,
        'recommendation_json': recommendation != null
            ? jsonEncode(recommendation)
            : null,
        'cached_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('❌ Error caching disease result: $e');
    }
  }

  /// Get cached disease results for crop
  Future<List<Map<String, dynamic>>> getCachedDiseasesByCrop(
    String crop,
  ) async {
    try {
      final rows = await _db.query(
        'disease_cache',
        where: 'crop = ?',
        whereArgs: [crop],
        orderBy: 'cached_at DESC',
      );

      return rows.map((row) {
        return {
          'disease': row['disease'],
          'confidence': row['confidence'],
          'severity': row['severity'],
          'treatment': row['treatment_json'] != null
              ? jsonDecode(row['treatment_json'] as String)
              : null,
          'recommendation': row['recommendation_json'] != null
              ? jsonDecode(row['recommendation_json'] as String)
              : null,
          'cachedAt': row['cached_at'],
        };
      }).toList();
    } catch (e) {
      print('❌ Error retrieving cached diseases: $e');
      return [];
    }
  }

  // ============= GENERAL CACHE OPERATIONS =============

  /// Clear all expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now().toIso8601String();

      await _db.delete(
        'price_cache',
        where: 'valid_until < ?',
        whereArgs: [now],
      );

      await _db.delete(
        'weather_cache',
        where: 'valid_until < ?',
        whereArgs: [now],
      );

      await _db.delete(
        'marketplace_cache',
        where: 'valid_until < ?',
        whereArgs: [now],
      );

      await _db.delete(
        'news_cache',
        where: 'valid_until < ?',
        whereArgs: [now],
      );

      print('✅ Expired cache cleared');
    } catch (e) {
      print('❌ Error clearing expired cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    try {
      final priceCount =
          Sqflite.firstIntValue(
            await _db.rawQuery('SELECT COUNT(*) as count FROM price_cache'),
          ) ??
          0;
      final weatherCount =
          Sqflite.firstIntValue(
            await _db.rawQuery('SELECT COUNT(*) as count FROM weather_cache'),
          ) ??
          0;
      final marketplaceCount =
          Sqflite.firstIntValue(
            await _db.rawQuery(
              'SELECT COUNT(*) as count FROM marketplace_cache',
            ),
          ) ??
          0;
      final diseaseCount =
          Sqflite.firstIntValue(
            await _db.rawQuery('SELECT COUNT(*) as count FROM disease_cache'),
          ) ??
          0;

      return {
        'prices': priceCount,
        'weather': weatherCount,
        'marketplace': marketplaceCount,
        'disease': diseaseCount,
        'total': priceCount + weatherCount + marketplaceCount + diseaseCount,
      };
    } catch (e) {
      print('❌ Error getting cache stats: $e');
      return {};
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _db.delete('price_cache');
      await _db.delete('weather_cache');
      await _db.delete('marketplace_cache');
      await _db.delete('disease_cache');
      await _db.delete('news_cache');
      print('✅ All cache cleared');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
    }
  }

  /// Close database
  Future<void> close() async {
    try {
      await _db.close();
      _initialized = false;
      print('✅ Cache database closed');
    } catch (e) {
      print('❌ Error closing cache database: $e');
    }
  }
}
