import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kisan_widgets.dart';

class NewsTrendsWidget extends StatelessWidget {
  final Map<String, dynamic>? newsData;
  final bool isLoading;

  const NewsTrendsWidget({
    super.key,
    this.newsData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const KisanCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accentGreen),
          ),
        ),
      );
    }

    if (newsData == null) {
      return const SizedBox.shrink();
    }

    final sentimentScore = newsData!['sentimentScore'] ?? 0;
    final summary = newsData!['summary'] ?? '';
    final impact = newsData!['impact'] ?? 'neutral';

    final Color impactColor = impact.toString().toLowerCase() == 'positive' 
        ? AppColors.accentGreen 
        : (impact.toString().toLowerCase() == 'negative' ? AppColors.dangerRed : Colors.orange);

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.newspaper, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                'Market News & Trends',
                style: AppTypography.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: impactColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Impact: ${impact.toString().toUpperCase()}',
                  style: AppTypography.labelSmall.copyWith(color: impactColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sentiment Score: $sentimentScore/100',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
