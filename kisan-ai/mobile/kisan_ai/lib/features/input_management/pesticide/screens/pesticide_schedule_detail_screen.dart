import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/input_management/pesticide/state/pesticide_provider.dart';
import 'package:kisan_ai/features/input_management/pesticide/services/pesticide_service.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

class PesticideScheduleDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;

  const PesticideScheduleDetailScreen({Key? key, required this.scheduleId})
    : super(key: key);

  @override
  ConsumerState<PesticideScheduleDetailScreen> createState() =>
      _PesticideScheduleDetailScreenState();
}

class _PesticideScheduleDetailScreenState
    extends ConsumerState<PesticideScheduleDetailScreen> {
  bool _isExecuting = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Schedule Details'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildScheduleDetailContent(ref),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: !(_isExecuting || _isSaving)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentGreen,
              onPressed: _executeSchedule,
              label: _isExecuting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBackground,
                      ),
                    )
                  : const Text('Execute Schedule'),
              icon: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }

  Widget _buildScheduleDetailContent(WidgetRef ref) {
    final scheduleAsync = ref.watch(
      pesticideScheduleProvider(widget.scheduleId),
    );

    return scheduleAsync.when(
      data: (schedule) => _buildScheduleDetails(schedule),
      loading: () => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ScheduleDetailShimmer(),
          ScheduleDetailShimmer(),
          ScheduleDetailShimmer(),
          ScheduleDetailShimmer(),
        ],
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading schedule details: $error',
          style: TextStyle(color: AppColors.dangerRed),
        ),
      ),
    );
  }

  Widget _buildScheduleDetails(PesticideSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Schedule Header
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: schedule.isActive
                ? AppColors.accentGreen.withOpacity(0.05)
                : AppColors.textSecondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: schedule.isActive
                  ? AppColors.accentGreen.withOpacity(0.2)
                  : AppColors.textSecondary.withOpacity(0.2),
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
                      color: schedule.isActive
                          ? AppColors.accentGreen.withOpacity(0.2)
                          : AppColors.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_florist,
                      color: schedule.isActive
                          ? AppColors.accentGreen
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.pesticideType,
                          style: AppTypography.titleLarge.copyWith(
                            color: schedule.isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pesticide Type',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (schedule.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Details', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              _buildInfoRow(
                label: 'Crop Type',
                value: schedule.cropType,
                icon: Icons.grass,
              ),
              _buildInfoRow(
                label: 'Application Rate',
                value: '${schedule.applicationRate} ${schedule.unit}/acre',
                icon: Icons.local_florist,
              ),
              _buildInfoRow(
                label: 'Frequency',
                value: schedule.frequency,
                icon: Icons.timer,
              ),
              _buildInfoRow(
                label: 'Area',
                value: '${schedule.area} acres',
                icon: Icons.square_foot,
              ),
              _buildInfoRow(
                label: 'Start Date',
                value: schedule.startDate.toString().split(' ')[0],
                icon: Icons.calendar_today,
              ),
              if (schedule.endDate != null)
                _buildInfoRow(
                  label: 'End Date',
                  value: schedule.endDate!.toString().split(' ')[0],
                  icon: Icons.calendar_today,
                ),
            ],
          ),
        ),
        // Application History
        _buildSectionHeader('Application History'),
        _buildApplicationHistoryList(ref, schedule.id),
        const SizedBox(height: 24),
        // Actions
        _buildSectionHeader('Actions'),
        _buildActionButtons(schedule),
      ],
    );
  }

  Widget _buildApplicationHistoryList(WidgetRef ref, String scheduleId) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(
          pesticideApplicationHistoryProvider({
            'scheduleId': scheduleId,
            'limit': 20,
            'offset': 0,
          }),
        );

        return historyAsync.when(
          data: (applications) => applications.isEmpty
              ? _buildEmptyHistoryState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    return _buildApplicationHistoryCard(application);
                  },
                ),
          loading: () => ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ApplicationHistoryShimmer(),
              ApplicationHistoryShimmer(),
              ApplicationHistoryShimmer(),
            ],
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading history: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistoryState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No application history found',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Execute this schedule to see application history here',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationHistoryCard(PesticideApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
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
            size: 20,
          ),
        ),
        title: Text(
          'Application on ${application.applicationDate.toString().split(' ')[0]}',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: application.isExecuted
                ? AppColors.accentGreen
                : AppColors.warningAmber,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesticide: ${application.pesticideType}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Amount: ${application.quantity} ${application.unit}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Area: ${application.area} acres',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        trailing: application.isExecuted
            ? const Icon(Icons.check_circle, color: AppColors.accentGreen)
            : const Icon(Icons.pending_actions, color: AppColors.warningAmber),
      ),
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
          Icon(icon, size: 20, color: AppColors.accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label: $value', style: AppTypography.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTypography.titleMedium),
    );
  }

  Widget _buildActionButtons(PesticideSchedule schedule) {
    return Column(
      children: [
        if (!schedule.isExecuting)
          KisanButton(
            text: 'Execute Schedule',
            isPrimary: true,
            onPressed: _executeSchedule,
            width: double.infinity,
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // TODO: Edit schedule
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.accentGreen),
            foregroundColor: AppColors.accentGreen,
          ),
          child: const Text('Edit Schedule'),
        ),
        const SizedBox(height: 12),
        if (!schedule.isActive)
          OutlinedButton(
            onPressed: () {
              // TODO: Activate schedule
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.accentGreen),
              foregroundColor: AppColors.accentGreen,
            ),
            child: const Text('Activate Schedule'),
          ),
      ],
    );
  }

  void _executeSchedule() async {
    setState(() => _isExecuting = true);

    try {
      // TODO: Get current farm ID from auth/profile
      final String farmId = 'current_farm_id';

      final pesticideService = ref.read(pesticideServiceProvider);
      final application = await pesticideService.executeSchedule(
        widget.scheduleId,
        // In a real app, you might want to show a form to get actual values
      );

      if (mounted) {
        setState(() => _isExecuting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule executed successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );

        // Refresh the schedule data
        ref.refresh(pesticideScheduleProvider(widget.scheduleId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExecuting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to execute schedule: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }
}

// Shimmer effect for loading state
class ScheduleDetailShimmer extends StatelessWidget {
  const ScheduleDetailShimmer({Key? key}) : super(key: key);

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
          const KisanShimmer(child: SizedBox(width: 100, height: 24)),
          const SizedBox(height: 8),
          const KisanShimmer(child: SizedBox(width: 300, height: 16)),
          const SizedBox(height: 8),
          const KisanShimmer(child: SizedBox(width: 200, height: 16)),
          const SizedBox(height: 8),
          const KisanShimmer(child: SizedBox(width: 200, height: 16)),
        ],
      ),
    );
  }
}

// Shimmer effect for application history
class ApplicationHistoryShimmer extends StatelessWidget {
  const ApplicationHistoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                SizedBox(width: 40, height: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 200, height: 16),
                      SizedBox(width: 150, height: 12),
                      SizedBox(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const KisanShimmer(child: SizedBox(width: 300, height: 12)),
        ],
      ),
    );
  }
}
