import 'package:flutter/material.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/core/connectivity/connectivity_service.dart';
import 'package:kisan_ai/core/sync/sync_manager.dart';

/// Offline/Online Status Badge
/// Shows current connectivity status with appropriate styling
class ConnectivityBadge extends StatelessWidget {
  final ConnectivityService connectivity;
  final SyncManager syncManager;

  const ConnectivityBadge({
    required this.connectivity,
    required this.syncManager,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: connectivity.onStatusChange,
      initialData: connectivity.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.offline;
        final isOffline = status == ConnectivityStatus.offline;

        if (syncManager.isSyncing) {
          return _buildSyncingBadge();
        }

        if (isOffline) {
          return _buildOfflineBadge();
        }

        return _buildOnlineBadge(connectivity.getConnectionTypeString(status));
      },
    );
  }

  Widget _buildOnlineBadge(String connectionType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGreen, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done, size: 16, color: AppColors.accentGreen),
          SizedBox(width: 6),
          Text(
            'Online • $connectionType',
            style: AppTypography.bodySmal.copyWith(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange),
          SizedBox(width: 6),
          Text(
            'Offline',
            style: AppTypography.bodySmal.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Syncing...',
            style: AppTypography.bodySmal.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline Banner - Full width banner showing offline status
class OfflineBanner extends StatelessWidget {
  final ConnectivityService connectivity;
  final bool showOnlyWhenOffline;

  const OfflineBanner({
    required this.connectivity,
    this.showOnlyWhenOffline = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: connectivity.onStatusChange,
      initialData: connectivity.currentStatus,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectivityStatus.offline;

        if (showOnlyWhenOffline && !isOffline) {
          return SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOffline ? Colors.orange : AppColors.accentGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOffline ? 'You are offline' : 'You are online',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isOffline ? 'Using cached data' : 'Using live data',
                      style: AppTypography.bodySmal.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Last Updated Badge - Shows when data was last cached
class LastUpdatedBadge extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool isStale;
  final Duration staleDuration;

  const LastUpdatedBadge({
    required this.lastUpdated,
    this.isStale = false,
    this.staleDuration = const Duration(hours: 24),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null) {
      return SizedBox.shrink();
    }

    final duration = DateTime.now().difference(lastUpdated!);
    String timeText;

    if (duration.inMinutes < 1) {
      timeText = 'Just now';
    } else if (duration.inHours < 1) {
      timeText = '${duration.inMinutes}m ago';
    } else if (duration.inDays < 1) {
      timeText = '${duration.inHours}h ago';
    } else {
      timeText = '${duration.inDays}d ago';
    }

    final backgroundColor = isStale
        ? Colors.orange.withOpacity(0.1)
        : AppColors.accentGreen.withOpacity(0.1);

    final textColor = isStale ? Colors.orange : AppColors.accentGreen;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        'Updated $timeText',
        style: AppTypography.bodySmal.copyWith(color: textColor, fontSize: 10),
      ),
    );
  }
}

/// Data Source Indicator - Shows if data is from cache or live
class DataSourceIndicator extends StatelessWidget {
  final bool isFromCache;
  final bool isStale;
  final DateTime? cachedAt;

  const DataSourceIndicator({
    required this.isFromCache,
    this.isStale = false,
    this.cachedAt,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFromCache) {
      return Tooltip(
        message: 'Live data from server',
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '📡 Live',
            style: AppTypography.bodySmal.copyWith(
              color: AppColors.accentGreen,
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    if (isStale) {
      return Tooltip(
        message: 'Cached data - may be outdated',
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '⚠️ Cached',
            style: AppTypography.bodySmal.copyWith(
              color: Colors.orange,
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: 'Cached data',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '💾 Cached',
          style: AppTypography.bodySmal.copyWith(
            color: AppColors.accentGreen,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

/// Sync Status Card - Shows sync statistics and status
class SyncStatusCard extends StatelessWidget {
  final SyncManager syncManager;

  const SyncStatusCard({required this.syncManager, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: AppColors.accentGreen),
                SizedBox(width: 12),
                Text(
                  'Sync Status',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildStatusRow('Status', syncManager.getSyncStatus()),
            SizedBox(height: 8),
            _buildStatusRow('Total Synced', '${syncManager.totalSynced} items'),
            SizedBox(height: 8),
            if (syncManager.failedSyncs > 0)
              _buildStatusRow(
                'Failed',
                '${syncManager.failedSyncs} items',
                color: Colors.red,
              ),
            SizedBox(height: 8),
            if (syncManager.lastSyncTime != null)
              _buildStatusRow(
                'Last Sync',
                _formatDateTime(syncManager.lastSyncTime!),
              ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncManager.isSyncing
                    ? null
                    : () => syncManager.manualSync(),
                icon: syncManager.isSyncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh),
                label: Text(syncManager.isSyncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Offline Data Warning - Shows when using cached/offline data
class OfflineDataWarning extends StatelessWidget {
  final bool show;
  final String message;

  const OfflineDataWarning({
    required this.show,
    this.message =
        'You are viewing cached data. Prices and availability may have changed.',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.orange.shade600, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmal.copyWith(
                color: Colors.orange.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
