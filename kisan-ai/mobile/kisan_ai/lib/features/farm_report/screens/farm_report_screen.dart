import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/features/farm_report/state/farm_report_notifier.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmReportScreen extends ConsumerStatefulWidget {
  const FarmReportScreen({super.key});

  @override
  ConsumerState<FarmReportScreen> createState() => _FarmReportScreenState();
}

class _FarmReportScreenState extends ConsumerState<FarmReportScreen> {
  @override
  void initState() {
    super.initState();
    // In a real app we might fetch the latest report here automatically
  }

  Future<void> _generateReport() async {
    ref.read(farmReportLoadingProvider.notifier).state = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.farmReportEndpoint}/generate'),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final reportType = body['report']?['type'] ?? 'unknown';
        final data = body['report']?['data'] ?? body['data'];
        ref.read(farmReportNotifierProvider.notifier).setReport(reportType, data);
        ref.read(showFarmReportFormProvider.notifier).state = false;
      } else {
        throw Exception('Failed to generate report (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
      }
      debugPrint('Report generation error: $e');
    } finally {
      ref.read(farmReportLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final generatedReport = ref.watch(farmReportNotifierProvider);
    final isLoading = ref.watch(farmReportLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: KisanAppBar(title: 'Smart Farm Report')),
            if (generatedReport == null)
              SliverFillRemaining(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildEmptyState(isLoading),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _buildReportWidget(generatedReport),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 72,
          color: AppColors.accentGreen.withOpacity(0.8),
        ),
        const SizedBox(height: 16),
        Text(
          'AI Farm Analysis',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generate a personalized, comprehensive AI report based on your farm profile and location. The AI will recommend the best crops or create a 365-day plan.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _generateReport,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isLoading ? 'Generating (Takes ~30s)...' : 'Generate Smart Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.primaryBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportWidget(FarmReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              report.reportType == '365_day_plan' ? '365-Day Crop Plan' : 'Crop Recommendation',
              style: AppTypography.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () {
                ref.read(farmReportNotifierProvider.notifier).clearReport();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (report.reportType == '365_day_plan')
          _build365DayPlanWidget(report.data)
        else
          _buildCropRecommendationWidget(report.data),
        const SizedBox(height: 24),
        KisanButton(
          text: 'Generate New Report',
          onPressed: () {
            ref.read(farmReportNotifierProvider.notifier).clearReport();
          },
          isPrimary: false,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _build365DayPlanWidget(Map<String, dynamic> data) {
    final summary = data['farm_summary'] ?? {};
    final financial = data['financial_summary'] ?? {};
    final monthPlans = (data['month_plans'] as List?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        KisanCard(
          isElevated: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: AppColors.accentGreen),
                    const SizedBox(width: 8),
                    Text('Crop: ${summary['crop_name'] ?? 'N/A'}', style: AppTypography.titleMedium),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('Farmer', summary['farmer_name']?.toString() ?? 'N/A'),
                _buildInfoRow('Location', summary['location']?.toString() ?? 'N/A'),
                _buildInfoRow('Land Area', summary['land_area']?.toString() ?? 'N/A'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Financials
        _buildSectionCard('Financial Projections', [
          _buildInfoRow('Estimated Cost', financial['total_estimated_cost']?.toString() ?? 'N/A'),
          _buildInfoRow('Expected Revenue', financial['expected_revenue_average']?.toString() ?? 'N/A'),
          _buildInfoRow('Net Profit', financial['net_profit_estimate_average']?.toString() ?? 'N/A', isHighlight: true),
          _buildInfoRow('ROI', financial['roi_percentage']?.toString() ?? 'N/A'),
          if (financial['cost_breakdown'] != null && financial['cost_breakdown'] is Map)
            ..._buildCostBreakdown(financial['cost_breakdown'] as Map<String, dynamic>),
        ]),
        const SizedBox(height: 16),
        
        // Month Plans
        Text('Monthly Plan', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        ...monthPlans.map((month) => _buildMonthCard(month as Map<String, dynamic>)).toList(),
      ],
    );
  }
  
  List<Widget> _buildCostBreakdown(Map<String, dynamic> breakdown) {
    return [
      const SizedBox(height: 12),
      Text('Cost Breakdown:', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      ...breakdown.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  Text(entry.value.toString(), style: const TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.5, // Dummy value since we don't have total numeric amount easily available
                backgroundColor: AppColors.surfaceElevated,
                color: AppColors.accentGreen,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              )
            ],
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildMonthCard(Map<String, dynamic> month) {
    final keyTasks = (month['key_tasks'] as List?) ?? [];
    final pestWatch = (month['pest_disease_watch'] as List?) ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surfaceElevated,
      elevation: 0,
      child: ExpansionTile(
        title: Text('${month['month_name']} (Month ${month['month_number']})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(month['month_summary']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (keyTasks.isNotEmpty) ...[
                  const Text('Key Tasks:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                  const SizedBox(height: 8),
                  ...keyTasks.map((t) => _buildBulletPoint(t.toString())).toList(),
                  const SizedBox(height: 12),
                ],
                if (month['fertilizer'] != null) ...[
                  const Row(children: [Icon(Icons.science, size: 16, color: Colors.blue), SizedBox(width: 8), Text('Fertilizer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
                  const SizedBox(height: 4),
                  Text(month['fertilizer'].toString(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                if (month['irrigation'] != null) ...[
                  const Row(children: [Icon(Icons.water_drop, size: 16, color: Colors.cyan), SizedBox(width: 8), Text('Irrigation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan))]),
                  const SizedBox(height: 4),
                  Text(month['irrigation'].toString(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                if (pestWatch.isNotEmpty) ...[
                  const Row(children: [Icon(Icons.bug_report, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Pest & Disease Watch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))]),
                  const SizedBox(height: 8),
                  ...pestWatch.map((p) => _buildBulletPoint(p.toString())).toList(),
                  const SizedBox(height: 12),
                ],
                if (month['weather_advisory'] != null) ...[
                  Row(children: [
                    const Icon(Icons.cloud, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Weather: ${month['weather_advisory']}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.orange, fontSize: 14))),
                  ]),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCropRecommendationWidget(Map<String, dynamic> data) {
    final aiPick = data['ai_top_pick'] ?? {};
    final crops = (data['top_5_crops'] as List?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Pick Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentGreen.withOpacity(0.8), AppColors.accentGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text('AI Top Recommendation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                aiPick['crop']?.toString().toUpperCase() ?? 'N/A',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                aiPick['primary_reason']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                child: Text('Profit est: ${aiPick['expected_profit_season_1'] ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        Text('Top 5 Suitable Crops', style: AppTypography.titleMedium),
        const SizedBox(height: 12),
        ...crops.map((crop) => _buildCropCard(crop as Map<String, dynamic>)).toList(),
      ],
    );
  }
  
  Widget _buildCropCard(Map<String, dynamic> crop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KisanCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${crop['rank']} ${crop['crop_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${crop['suitability_score']}',
                      style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(crop['why_suitable']?.toString() ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(child: _buildMiniStat('Profit', crop['expected_profit_per_acre']?.toString() ?? 'N/A')),
                  Expanded(child: _buildMiniStat('Risk', crop['risk_level']?.toString() ?? 'N/A')),
                  Expanded(child: _buildMiniStat('Water', crop['water_requirement']?.toString() ?? 'N/A')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return KisanCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleMedium),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                color: isHighlight ? AppColors.accentGreen : AppColors.textPrimary,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, top: 4),
            child: Icon(Icons.circle, size: 6, color: AppColors.accentGreen),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
