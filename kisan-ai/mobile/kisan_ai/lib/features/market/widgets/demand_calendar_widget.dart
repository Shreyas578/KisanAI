import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kisan_widgets.dart';

class DemandCalendarWidget extends StatelessWidget {
  final Map<String, dynamic>? demandData;
  final bool isLoading;

  const DemandCalendarWidget({
    super.key,
    this.demandData,
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

    if (demandData == null) {
      return const SizedBox.shrink();
    }

    final score = demandData!['demandScore'] ?? 0;
    final outlook = demandData!['outlook'] ?? 'Average';
    final bestMonths = demandData!['bestSellingMonths'] as List? ?? [];
    final activeBuyers = demandData!['activeBuyers'] ?? 'N/A';
    final competitionLevel = demandData!['competitionLevel'] ?? 'N/A';
    final demandDrivers = demandData!['demandDrivers'] as List? ?? [];
    final insight = demandData!['insight'] ?? '';

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Text(
                'Demand Calendar',
                style: AppTypography.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demand Score', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('$score/100', style: AppTypography.titleMedium.copyWith(color: score > 70 ? AppColors.accentGreen : Colors.orange)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Outlook', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(outlook.toString().toUpperCase(), style: AppTypography.titleSmall),
                ],
              ),
            ],
          ),
          if (bestMonths.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Best Selling Months:', style: AppTypography.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bestMonths.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(m.toString(), style: AppTypography.labelSmall),
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Buyers', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(activeBuyers.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Competition', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(competitionLevel.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (demandDrivers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Key Demand Drivers:', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...demandDrivers.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.accentGreen)),
                  Expanded(child: Text(d.toString(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                ],
              ),
            )),
          ],
          if (insight.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insight.toString(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
