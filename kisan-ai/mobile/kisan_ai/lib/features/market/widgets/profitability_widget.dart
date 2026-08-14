import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kisan_widgets.dart';

class ProfitabilityWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ProfitabilityWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    final estimatedCost = data!['estimatedCost'] ?? 0;
    final estimatedRevenue = data!['estimatedRevenue'] ?? 0;
    final netProfit = estimatedRevenue - estimatedCost;
    final margin = estimatedRevenue > 0 ? (netProfit / estimatedRevenue) * 100 : 0;
    
    final isProfitable = netProfit > 0;
    final Color color = isProfitable ? AppColors.accentGreen : AppColors.dangerRed;

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: color),
              const SizedBox(width: 8),
              Text('Profitability Estimate', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Estimated Cost', '₹$estimatedCost', AppColors.textSecondary),
          const SizedBox(height: 8),
          _buildRow('Expected Revenue', '₹$estimatedRevenue', AppColors.textPrimary),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          _buildRow(
            isProfitable ? 'Net Profit' : 'Net Loss', 
            '₹${netProfit.abs()}', 
            color,
            isBold: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProfitable ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${margin.toStringAsFixed(1)}% Margin',
                  style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
