import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/core/theme/app_typography.dart';
import 'package:kisan_ai/core/network/connectivity_service.dart';

class OfflineBanner extends ConsumerWidget {
  final String? customMessage;

  const OfflineBanner({super.key, this.customMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityServiceProvider);

    return isOnline.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (online) {
        // Only show banner if offline
        if (online) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.dangerRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.dangerRed.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 20, color: AppColors.dangerRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customMessage ?? 'No internet connection',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.dangerRed,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
