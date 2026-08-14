import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/input_management/pesticide/state/pesticide_provider.dart';
import 'package:kisan_ai/features/input_management/pesticide/services/pesticide_service.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

class PesticideApplicationDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const PesticideApplicationDetailScreen({
    Key? key,
    required this.applicationId,
  }) : super(key: key);

  @override
  ConsumerState<PesticideApplicationDetailScreen> createState() =>
      _PesticideApplicationDetailScreenState();
}

class _PesticideApplicationDetailScreenState
    extends ConsumerState<PesticideApplicationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Application Details',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildApplicationDetailContent(ref),
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

  Widget _buildApplicationDetailContent(WidgetRef ref) {
    final applicationAsync = ref.watch(pesticideApplicationProvider(widget.applicationId));

    return applicationAsync.when(
      data: (application) => _buildApplicationDetails(application),
      loading: () => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ApplicationDetailShimmer(),
          ApplicationDetailShimmer(),
          ApplicationDetailShimmer(),
          ApplicationDetailShimmer(),
        ],
      ),
      error: (error, stackTrace) => Center(
            child: Text(
              'Error loading application details: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
    );
  }

  Widget _buildApplicationDetails(PesticideApplication application) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Application Header
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: application.isExecuted
                ? AppColors.accentGreen.withOpacity(0.05)
                : AppColors.warningAmber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: application.isExecuted
                  ? AppColors.accentGreen.withOpacity(0.2)
                  : AppColors.warningAmber.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: application.isExecuted
                          ? AppColors.accentGreen.withOpacity(0.2)
                          : AppColors.warningAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      application.isExecuted ? Icons.check_circle : Icons.pending_actions,
                      color: application.isExecuted
                          ? AppColors.accentGreen
                          : AppColors.warningAmber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application on ${application.applicationDate.toString().split(' ')[0]}',
                          style: AppTypography.titleLarge.copyWith(
                            color: application.isExecuted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pesticide Application',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Application Details',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                label: 'Pesticide Type',
                value: application.pesticideType,
                icon: Icons.local_florist,
              ),
              _buildInfoRow(
                label: 'Amount Applied',
                value: '${application.quantity} ${application.unit}',
                icon: Icons.local_fire_department,
              ),
              _buildInfoRow(
                label: 'Area Covered',
                value: '${application.area} acres',
                icon: Icons.square_foot,
              ),
              _buildInfoRow(
                label: 'Application Date',
                value: application.applicationDate.toString().split(' ')[0],
                icon: Icons.calendar_today,
              ),
              if (application.notes != null && application.notes!.isNotEmpty)
                _buildInfoRow(
                  label: 'Notes',
                  value: application.notes!,
                  icon: Icons.note,
                ),
            ],
          ),
        ),
        // Related Schedule Info
        _buildSectionHeader('Related Schedule'),
        _buildScheduleInfo(application),
        const SizedBox(height: 24),
        // Status Section
        _buildSectionHeader('Status'),
        _buildStatusSection(application),
      ],
    );
  }

  Widget _buildScheduleInfo(PesticideApplication application) {
    // In a real app, we would fetch the schedule details
    // For now, we'll show placeholder info
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            label: 'Schedule ID',
            value: application.scheduleId,
            icon: Icons.list_alt,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Pesticide Type',
            value: application.pesticideType,
            icon: Icons.local_florist,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Crop Type',
            value: application.cropType ?? 'Not specified',
            icon: Icons.grass,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(PesticideApplication application) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: application.isExecuted
                ? AppColors.accentGreen.withOpacity(0.1)
                : AppColors.warningAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: application.isExecuted
                  ? AppColors.accentGreen.withOpacity(0.2)
                  : AppColors.warningAmber.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Execution Status',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.isExecuted ? 'Executed' : 'Pending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: application.isExecuted
                          ? AppColors.accentGreen
                          : AppColors.warningAmber,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: application.isExecuted
                      ? AppColors.accentGreen.withOpacity(0.2)
                      : AppColors.warningAmber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  application.isExecuted
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: application.isExecuted
                      ? AppColors.accentGreen
                      : AppColors.warningAmber,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTypography.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleMedium,
      ),
    );
  }
}

// Shimmer effect for loading state
class ApplicationDetailShimmer extends StatelessWidget {
  const ApplicationDetailShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KisanShimmer(
            child: Row(
              children: [
                SizedBox(width: 48, height: 48),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 200, height: 24),
                      SizedBox(width: 150, height: 16),
                      SizedBox(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const KisanShimmer(
            child: SizedBox(width: 100, height: 24),
          ),
          const SizedBox(height: 8),
          const KisanShimmer(
            child: SizedBox(width: 300, height: 16),
          ),
          const SizedBox(height: 8),
          const KisanShimmer(
            child: SizedBox(width: 200, height: 16),
          ),
          const SizedBox(height: 8),
          const KisanShimmer(
            child: SizedBox(width: 200, height: 16),
          ),
        ],
      ),
    );
  }
}
