import 'package:kisan_ai/core/connectivity/connectivity_service.dart';
import 'package:kisan_ai/core/cache/offline_cache_service.dart';
import 'dart:async';

/// Sync Manager - Auto-sync cached data when online
///
/// Monitors connectivity and automatically syncs data when
/// device comes online. Handles errors gracefully.

typedef OnSyncStart = void Function();
typedef OnSyncProgress = void Function(String message);
typedef OnSyncComplete = void Function(bool success, String message);

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  factory SyncManager() {
    return _instance;
  }

  SyncManager._internal();

  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineCacheService _cache = OfflineCacheService();

  late StreamSubscription<ConnectivityStatus> _connectivitySubscription;

  bool _wasOffline = false;
  bool _isSyncing = false;

  // Callbacks
  OnSyncStart? _onSyncStart;
  OnSyncProgress? _onSyncProgress;
  OnSyncComplete? _onSyncComplete;

  // Sync statistics
  int _totalSynced = 0;
  int _failedSyncs = 0;
  DateTime? _lastSyncTime;

  bool get isOffline =>
      _connectivity.currentStatus == ConnectivityStatus.offline;
  bool get isSyncing => _isSyncing;
  int get totalSynced => _totalSynced;
  int get failedSyncs => _failedSyncs;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize sync manager
  Future<void> initialize({
    required OnSyncStart onSyncStart,
    required OnSyncProgress onSyncProgress,
    required OnSyncComplete onSyncComplete,
  }) async {
    _onSyncStart = onSyncStart;
    _onSyncProgress = onSyncProgress;
    _onSyncComplete = onSyncComplete;

    // Initialize services
    _connectivity.initialize();
    await _cache.initialize();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onStatusChange.listen(
      (status) => _handleConnectivityChange(status),
    );

    // Check initial status
    _wasOffline = isOffline;

    print('✅ Sync Manager initialized');
  }

  /// Handle connectivity status changes
  Future<void> _handleConnectivityChange(ConnectivityStatus status) async {
    final isNowOffline = status == ConnectivityStatus.offline;

    // If we were offline and now online, sync data
    if (_wasOffline && !isNowOffline) {
      print('🔄 Device came online - starting sync');
      await performSync();
    }

    _wasOffline = isNowOffline;
  }

  /// Perform data sync
  /// Syncs prices, weather, marketplace listings, etc.
  Future<void> performSync({bool showProgress = true}) async {
    if (_isSyncing) {
      print('⚠️  Sync already in progress');
      return;
    }

    if (isOffline) {
      print('❌ Cannot sync - device is offline');
      _onSyncComplete?.call(false, 'Device is offline');
      return;
    }

    _isSyncing = true;
    _totalSynced = 0;
    _failedSyncs = 0;

    _onSyncStart?.call();
    _onSyncProgress?.call('Starting sync...');

    try {
      print('🔄 Starting data sync...');

      // Sync prices
      _onSyncProgress?.call('Syncing prices...');
      await _syncPrices();

      // Sync weather
      _onSyncProgress?.call('Syncing weather...');
      await _syncWeather();

      // Sync marketplace listings
      _onSyncProgress?.call('Syncing marketplace...');
      await _syncMarketplace();

      // Sync news
      _onSyncProgress?.call('Syncing news...');
      await _syncNews();

      // Clear expired cache
      _onSyncProgress?.call('Cleaning up...');
      await _cache.clearExpiredCache();

      _lastSyncTime = DateTime.now();

      print('✅ Sync completed successfully');
      _onSyncComplete?.call(true, 'Synced $_totalSynced items');
    } catch (e) {
      print('❌ Sync error: $e');
      _onSyncComplete?.call(false, 'Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync prices from API
  Future<void> _syncPrices() async {
    try {
      // This would call your actual API
      // For now, we're showing the pattern
      // In real implementation, call: await priceApi.getPrices()

      print('📊 Prices sync simulated');
      // In actual implementation:
      // final prices = await priceApi.getAllPrices();
      // for (final price in prices) {
      //   await _cache.cachePrice(...);
      // }
      _totalSynced += 5; // Simulated count
    } catch (e) {
      print('❌ Price sync error: $e');
      _failedSyncs++;
    }
  }

  /// Sync weather from API
  Future<void> _syncWeather() async {
    try {
      print('🌤️  Weather sync simulated');
      // In actual implementation:
      // final weather = await weatherApi.getWeather(location);
      // await _cache.cacheWeather(...);
      _totalSynced += 1;
    } catch (e) {
      print('❌ Weather sync error: $e');
      _failedSyncs++;
    }
  }

  /// Sync marketplace listings from API
  Future<void> _syncMarketplace() async {
    try {
      print('🛒 Marketplace sync simulated');
      // In actual implementation:
      // final listings = await marketplaceApi.getListings();
      // for (final listing in listings) {
      //   await _cache.cacheMarketplaceListing(...);
      // }
      _totalSynced += 20; // Simulated count
    } catch (e) {
      print('❌ Marketplace sync error: $e');
      _failedSyncs++;
    }
  }

  /// Sync news from API
  Future<void> _syncNews() async {
    try {
      print('📰 News sync simulated');
      // In actual implementation:
      // final news = await newsApi.getNews();
      // for (final article in news) {
      //   await _cache.cacheNews(...);
      // }
      _totalSynced += 10; // Simulated count
    } catch (e) {
      print('❌ News sync error: $e');
      _failedSyncs++;
    }
  }

  /// Get sync status as string
  String getSyncStatus() {
    if (_isSyncing) {
      return 'Syncing...';
    } else if (isOffline) {
      return 'Offline';
    } else if (_lastSyncTime != null) {
      final duration = DateTime.now().difference(_lastSyncTime!);
      if (duration.inMinutes < 1) {
        return 'Just synced';
      } else if (duration.inHours < 1) {
        return 'Synced ${duration.inMinutes}m ago';
      } else if (duration.inDays < 1) {
        return 'Synced ${duration.inHours}h ago';
      } else {
        return 'Synced ${duration.inDays}d ago';
      }
    } else {
      return 'Ready to sync';
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final stats = await _cache.getCacheStats();
    return {
      'cacheStats': stats,
      'lastSync': _lastSyncTime?.toIso8601String(),
      'totalSynced': _totalSynced,
      'failedSyncs': _failedSyncs,
      'isOnline': !isOffline,
      'isSyncing': _isSyncing,
    };
  }

  /// Manual sync trigger
  Future<void> manualSync() async {
    print('🔄 Manual sync triggered');
    await performSync();
  }

  /// Reset sync statistics
  void resetStatistics() {
    _totalSynced = 0;
    _failedSyncs = 0;
    _lastSyncTime = null;
  }

  /// Dispose manager
  void dispose() {
    _connectivitySubscription.cancel();
    print('✅ Sync Manager disposed');
  }
}
