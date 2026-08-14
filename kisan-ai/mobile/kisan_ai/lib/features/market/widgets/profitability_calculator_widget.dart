import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kisan_widgets.dart';

class ProfitabilityCalculatorWidget extends StatefulWidget {
  final List<Map<String, dynamic>> markets;
  final String? selectedCity;

  const ProfitabilityCalculatorWidget({
    super.key,
    required this.markets,
    this.selectedCity,
  });

  @override
  State<ProfitabilityCalculatorWidget> createState() => _ProfitabilityCalculatorWidgetState();
}

class _ProfitabilityCalculatorWidgetState extends State<ProfitabilityCalculatorWidget> {
  double _yieldQuintals = 50.0;
  double _productionCostPerQuintal = 800.0;
  double _transportCostPerQuintal = 50.0;
  String? _selectedMarketName;

  void _setDefaultMarket() {
    if (widget.markets.isNotEmpty) {
      if (widget.selectedCity != null) {
        try {
          final match = widget.markets.firstWhere(
            (m) => (m['name'] ?? '').toString().toLowerCase().contains(widget.selectedCity!.toLowerCase()) ||
                   (m['district'] ?? '').toString().toLowerCase().contains(widget.selectedCity!.toLowerCase())
          );
          _selectedMarketName = match['name'];
        } catch (_) {
          _selectedMarketName = widget.markets[0]['name'];
        }
      } else {
        _selectedMarketName = widget.markets[0]['name'];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _setDefaultMarket();
  }

  @override
  void didUpdateWidget(ProfitabilityCalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markets != oldWidget.markets || widget.selectedCity != oldWidget.selectedCity) {
      _setDefaultMarket();
    }
  }

  Map<String, dynamic>? get _selectedMarket {
    try {
      return widget.markets.firstWhere((m) => m['name'] == _selectedMarketName);
    } catch (e) {
      return widget.markets.isNotEmpty ? widget.markets[0] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.markets.isEmpty) {
      return const SizedBox.shrink();
    }

    final market = _selectedMarket;
    final modalPrice = (market?['modal'] ?? 0).toDouble();

    final revenue = _yieldQuintals * modalPrice;
    final prodCost = _yieldQuintals * _productionCostPerQuintal;
    final transportCost = _yieldQuintals * _transportCostPerQuintal;
    final mandiFee = revenue * 0.02; // 2% fee

    final netProfit = revenue - prodCost - transportCost - mandiFee;

    // Find best market
    Map<String, dynamic>? bestMarket;
    double highestProfit = -double.infinity;

    for (final m in widget.markets) {
      final p = (m['modal'] ?? 0).toDouble();
      final rev = _yieldQuintals * p;
      final mFee = rev * 0.02;
      // In a real scenario, transport cost might vary by market distance. 
      // Since we don't have distance, we apply the same transport cost estimate.
      final profit = rev - prodCost - transportCost - mFee;
      if (profit > highestProfit) {
        highestProfit = profit;
        bestMarket = m;
      }
    }

    final isBestMarketSelected = bestMarket != null && bestMarket['name'] == market?['name'];

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: AppColors.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Profitability Estimator',
                style: AppTypography.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Inputs
          _buildSlider('Expected Yield (Quintals)', _yieldQuintals, 10, 500, (val) => setState(() => _yieldQuintals = val)),
          _buildSlider('Production Cost (₹/Qtl)', _productionCostPerQuintal, 100, 5000, (val) => setState(() => _productionCostPerQuintal = val)),
          _buildSlider('Transport Cost (₹/Qtl)', _transportCostPerQuintal, 10, 500, (val) => setState(() => _transportCostPerQuintal = val)),

          const SizedBox(height: 16),
          const Text('Select Target Market', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedMarketName,
                dropdownColor: AppColors.surfaceElevated,
                items: widget.markets.map((m) {
                  return DropdownMenuItem<String>(
                    value: m['name'],
                    child: Text('${m['name']} (₹${m['modal']})', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMarketName = val);
                },
              ),
            ),
          ),
          
          if (!isBestMarketSelected && bestMarket != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Optimization: Selling at ${bestMarket['name']} could yield ₹${(highestProfit - netProfit).toStringAsFixed(0)} more profit.',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          
          // Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Revenue', style: TextStyle(color: AppColors.textSecondary)),
              Text('+ ₹${revenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Production Cost', style: TextStyle(color: AppColors.textSecondary)),
              Text('- ₹${prodCost.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.dangerRed)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transport & Mandi Fees (2%)', style: TextStyle(color: AppColors.textSecondary)),
              Text('- ₹${(transportCost + mandiFee).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.dangerRed)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: netProfit >= 0 ? AppColors.accentGreen.withOpacity(0.1) : AppColors.dangerRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('NET PROFIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  '₹${netProfit.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: netProfit >= 0 ? AppColors.accentGreen : AppColors.dangerRed,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentGreen,
            inactiveTrackColor: AppColors.surfaceElevated,
            thumbColor: Colors.white,
            trackHeight: 4,
            overlayColor: AppColors.accentGreen.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
