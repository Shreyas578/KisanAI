import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kisan_ai/services/cache/marketplace_cache_service.dart';
import 'package:kisan_ai/core/config/api_config.dart';

/// Manages data synchronization between offline cache and online API
class SyncManager {
  final Dio _dio;
  final MarketplaceCacheService _marketplaceCache;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  Function? _onSyncProgress;
  Function? _onSyncComplete;

  SyncManager({
    required Dio dio,
    required MarketplaceCacheService marketplaceCache,
  }) : _dio = dio,
       _marketplaceCache = marketplaceCache;

  /// Start background sync
  Future<void> startSync({Function? onProgress, Function? onComplete}) async {
    _onSyncProgress = onProgress;
    _onSyncComplete = onComplete;

    // Check connectivity
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      print('⚠️ No connection. Skipping sync.');
      return;
    }

    if (_isSyncing) {
      print('⏳ Sync already in progress');
      return;
    }

    _isSyncing = true;

    try {
      print('🔄 Starting sync...');

      // Sync marketplace data
      await _syncMarketplace();

      // Add more sync operations as needed
      // await _syncPrices();
      // await _syncWeather();
      // await _syncNews();

      print('✅ Sync completed successfully');
      _onSyncComplete?.call(true);
    } catch (e) {
      print('❌ Sync error: $e');
      _onSyncComplete?.call(false, error: e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync marketplace listings and orders
  Future<void> _syncMarketplace() async {
    try {
      print('🛒 Syncing marketplace...');
      _onSyncProgress?.call('Syncing marketplace...');

      // Fetch latest listings
      try {
        final response = await _dio.get(
          '${ApiConfig.baseUrl}/api/marketplace/listings',
          options: Options(
            receiveTimeout: const Duration(seconds: 15),
            connectTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true && data['data'] != null) {
            await _marketplaceCache.cacheListings(
              List<Map<String, dynamic>>.from(data['data'] as List),
            );
            print('✅ Marketplace listings synced');
          }
        }
      } catch (e) {
        print('⚠️ Failed to fetch marketplace listings: $e');
        // Don't fail sync if listings fetch fails
      }

      // Upload pending orders
      _onSyncProgress?.call('Syncing pending orders...');
      final pendingOrders = await _marketplaceCache.getPendingOrders();

      for (final order in pendingOrders) {
        try {
          final response = await _dio.post(
            '${ApiConfig.baseUrl}/api/order/create',
            data: order,
            options: Options(
              receiveTimeout: const Duration(seconds: 15),
              connectTimeout: const Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 201) {
            // Remove from pending after successful sync
            await _marketplaceCache.removeSyncedOrder(order['id'] ?? '');
            print('✅ Order synced: ${order['id']}');
          }
        } catch (e) {
          print('⚠️ Failed to sync order ${order['id']}: $e');
          // Keep order in pending for retry
        }
      }

      print('✅ Marketplace sync complete');
    } catch (e) {
      print('❌ Marketplace sync error: $e');
      rethrow;
    }
  }

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;

  /// Force sync immediately
  Future<void> forceSync() => startSync();

  /// Cancel sync
  void cancelSync() {
    _isSyncing = false;
    print('⏹️ Sync cancelled');
  }
}
