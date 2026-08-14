import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class CropSuggestionScreen extends StatefulWidget {
  const CropSuggestionScreen({Key? key}) : super(key: key);

  @override
  State<CropSuggestionScreen> createState() =>
      _CropSuggestionScreenState();
}

class _CropSuggestionScreenState extends State<CropSuggestionScreen> {
  final List<Map<String, dynamic>> _recommendations = [
    {
      'crop': 'Rice',
      'suitability': 95,
      'reason': 'High water availability and clay loam soil',
      'icon': Icons.rice_bowl,
    },
    {
      'crop': 'Sugarcane',
      'suitability': 88,
      'reason': 'Good irrigation facilities and warm climate',
      'icon': Icons.local_florist,
    },
    {
      'crop': 'Cotton',
      'suitability': 75,
      'reason': 'Moderate rainfall and black soil suitability',
      'icon': Icons.checkroom,
    },
    {
      'crop': 'Maize',
      'suitability': 82,
      'reason': 'Suitable for crop rotation with legumes',
      'icon': Icons.grain,
    },
    {
      'crop': 'Soybean',
      'suitability': 78,
      'reason': 'Fixes nitrogen, improving soil for next season',
      'icon': Icons.food_bank,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Crop Suggestions',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      'Based on your farm details, here are the most suitable crops for your land:',
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        final rec = _recommendations[index];
                        return _buildRecommendationCard(rec);
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: KisanButton(
                        text: 'Get Detailed Plan',
                        isPrimary: true,
                        onPressed: () {
                          // TODO: Navigate to detailed planning
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Detailed planning feature coming soon'),
                              backgroundColor: AppColors.accentGreen,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rec['suitability'] >= 80
              ? AppColors.accentGreen
              : rec['suitability'] >= 60
                  ? AppColors.warningAmber
                  : AppColors.dangerRed,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              rec['icon'] as IconData,
              size: 32,
              color: rec['suitability'] >= 80
                  ? AppColors.accentGreen
                  : rec['suitability'] >= 60
                      ? AppColors.warningAmber
                      : AppColors.dangerRed,
            ),
            title: Text(
              '${rec['crop']}',
              style: AppTypography.titleMedium,
            ),
            subtitle: Text(
              '${rec['reason']}',
              style: AppTypography.bodyMedium,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: rec['suitability'] >= 80
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : rec['suitability'] >= 60
                        ? AppColors.warningAmber.withOpacity(0.2)
                        : AppColors.dangerRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${rec['suitability']}% Match',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rec['suitability'] >= 80
                      ? AppColors.accentGreen
                      : rec['suitability'] >= 60
                          ? AppColors.warningAmber
                          : AppColors.dangerRed,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              value: rec['suitability'] / 100,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                rec['suitability'] >= 80
                    ? AppColors.accentGreen
                    : rec['suitability'] >= 60
                        ? AppColors.warningAmber
                        : AppColors.dangerRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
