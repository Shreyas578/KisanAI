import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class ApplicationConfirmationScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicationConfirmationScreen({Key? key, required this.applicationId})
    : super(key: key);

  @override
  ConsumerState<ApplicationConfirmationScreen> createState() =>
      _ApplicationConfirmationScreenState();
}

class _ApplicationConfirmationScreenState
    extends ConsumerState<ApplicationConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Application Submitted'),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Application Submitted Successfully!',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your application has been received and is under review. You will receive updates on your registered mobile number.',
                      style: AppTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.description,
                          label: 'Application ID',
                          value: widget.applicationId,
                        ),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Submission Date',
                          value: DateTime.now().toString().split(' ')[0],
                        ),
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Expected Processing Time',
                          value: '15-30 days',
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    KisanButton(
                      text: 'Go to Home',
                      isPrimary: true,
                      onPressed: () {
                        // Navigate to home screen
                        // In a real app, you might go to a dashboard or home
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.settings.name == '/');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // View application details
                        // TODO: Navigate to application detail screen
                      },
                      child: const Text(
                        'View Application Details',
                        style: TextStyle(color: AppColors.accentGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label: $value', style: AppTypography.bodyLarge),
          ),
        ],
      ),
    );
  }
}
