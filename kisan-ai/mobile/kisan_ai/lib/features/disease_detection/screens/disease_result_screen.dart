import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class DiseaseResultScreen extends ConsumerStatefulWidget {
  final String diagnosis;
  final double confidence;
  final Uint8List? imageBytes;

  const DiseaseResultScreen({
    Key? key,
    required this.diagnosis,
    required this.confidence,
    this.imageBytes,
  }) : super(key: key);

  @override
  ConsumerState<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends ConsumerState<DiseaseResultScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Diagnosis Result',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Image
                    if (widget.imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          widget.imageBytes!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.agriculture,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Diagnosis Card
                    KisanCard(
                      isElevated: true,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              widget.diagnosis == 'Healthy Leaf'
                                  ? Icons.check_circle
                                  : Icons.warning_amber_rounded,
                              size: 48,
                              color: widget.diagnosis == 'Healthy Leaf'
                                  ? AppColors.accentGreen
                                  : AppColors.dangerRed,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.diagnosis,
                              style: AppTypography.titleLarge.copyWith(
                                color: widget.diagnosis == 'Healthy Leaf'
                                    ? AppColors.accentGreen
                                    : AppColors.dangerRed,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%',
                              style: AppTypography.bodyLarge.copyWith(
                                color: widget.diagnosis == 'Healthy Leaf'
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Treatment Recommendations
                    if (widget.diagnosis != 'Healthy Leaf') ...[
                      Text(
                        'Treatment Recommendations',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTreatmentItem(
                              'Organic Solution',
                              'Apply neem oil spray every 7 days for 3 weeks.',
                              Icons.grass,
                              AppColors.accentGreen,
                            ),
                            const SizedBox(height: 12),
                            _buildTreatmentItem(
                              'Chemical Solution',
                              'Use recommended fungicide as per label instructions.',
                              Icons.food_bank,
                              AppColors.dangerRed,
                            ),
                            const SizedBox(height: 12),
                            _buildTreatmentItem(
                              'Preventive Measures',
                              'Ensure proper spacing and avoid overhead watering.',
                              Icons.healing,
                              AppColors.infoBlue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: KisanButton(
                            text: 'Mark as Treated',
                            isPrimary: widget.diagnosis != 'Healthy Leaf',
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() => _isLoading = true);
                                    // TODO: Save to history
                                    Future.delayed(const Duration(seconds: 1))
                                        .then((_) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Treatment recorded successfully'),
                                          backgroundColor: AppColors.accentGreen,
                                        ),
                                      );
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KisanButton(
                            text: 'Scan Another',
                            isPrimary: true,
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // Go back to scan screen
                                    ref.read(appRouterProvider).pop();
                                  },
                          ),
                        ),
                      ],
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

  Widget _buildTreatmentItem(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
