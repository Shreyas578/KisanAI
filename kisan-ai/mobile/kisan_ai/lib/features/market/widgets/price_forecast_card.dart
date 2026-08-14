import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kisan_widgets.dart';

class PriceForecastCard extends StatelessWidget {
  final Map<String, dynamic>? forecastData;
  final bool isLoading;

  const PriceForecastCard({
    super.key,
    this.forecastData,
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

    if (forecastData == null) {
      return const SizedBox.shrink();
    }

    final forecast = (forecastData!['forecast'] as List?) ?? [];
    final trend = forecastData!['trend'] ?? 'stable';
    final seasonContext = forecastData!['season_context'] ?? '';
    final bestSellWeek = forecastData!['best_sell_week'] ?? 1;
    final bestSellDay = forecastData!['best_sell_day'] ?? 'Week $bestSellWeek';

    final isBullish = trend.toString().toLowerCase() == 'bullish';
    final isBearish = trend.toString().toLowerCase() == 'bearish';

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.accentGreen),
              const SizedBox(width: 8),
              Text(
                'AI Price Insights (4 Weeks)',
                style: AppTypography.titleSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBullish ? AppColors.accentGreen.withOpacity(0.2) : (isBearish ? AppColors.dangerRed.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isBullish ? AppColors.accentGreen : (isBearish ? AppColors.dangerRed : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (seasonContext.isNotEmpty) ...[
            Text('Market Context', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(seasonContext.toString(), style: AppTypography.bodySmall),
            const SizedBox(height: 16),
          ],
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.accentGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Best Time to Sell', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(bestSellDay.toString(), style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                      if (forecast.isNotEmpty && forecast.length >= bestSellWeek)
                        Text(forecast[bestSellWeek - 1]['note']?.toString() ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text('Weekly Forecast', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ...forecast.map((weekData) {
            final w = weekData as Map<String, dynamic>;
            final price = w['price'] ?? 0;
            final change = (w['change_pct'] ?? 0).toDouble();
            final isUp = change > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    decoration: BoxDecoration(color: const Color(0xFF151D19), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text('Week ${w['week']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        if (w['date_range'] != null)
                          Text(w['date_range'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 8)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isUp ? AppColors.accentGreen : AppColors.dangerRed),
                  Text('${change.abs()}%', style: TextStyle(color: isUp ? AppColors.accentGreen : AppColors.dangerRed, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(w['note']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
