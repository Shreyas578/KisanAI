import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/input_management/pesticide/state/pesticide_provider.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

class PesticideHomeScreen extends ConsumerStatefulWidget {
  const PesticideHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PesticideHomeScreen> createState() =>
      _PesticideHomeScreenState();
}

class _PesticideHomeScreenState extends ConsumerState<PesticideHomeScreen> {
  String _selectedStatus = 'All';
  String _selectedCropType = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Pesticide Management'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Text(
                      'Pesticide Management',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your pesticide schedules and crop protection',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Filter Bar
                    _buildFilterBar(),
                    const SizedBox(height: 24),
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    // Upcoming Applications
                    _buildUpcomingApplicationsSection(),
                    const SizedBox(height: 24),
                    // Pesticide Schedule List
                    _buildScheduleListSection(),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        onPressed: () {
          ref.read(appRouterProvider).push('/pesticide-schedule-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Status Filter
          _buildDropdownFilter(
            label: 'Status',
            value: _selectedStatus,
            items: ['All', 'Active', 'Inactive', 'Completed'],
            onChanged: (value) {
              setState(() => _selectedStatus = value!);
            },
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),
          // Crop Type Filter
          _buildDropdownFilter(
            label: 'Crop Type',
            value: _selectedCropType,
            items: [
              'All',
              'Rice',
              'Wheat',
              'Cotton',
              'Sugarcane',
              'Vegetables',
              'Fruits',
            ],
            onChanged: (value) {
              setState(() => _selectedCropType = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                items: items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          item.toString(),
                          style: AppTypography.bodyLarge.copyWith(
                            color: item == value
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (onChanged != null) onChanged(value);
                },
                dropdownColor: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          title: 'Active Schedules',
          value: '8',
          icon: Icons.check_circle,
          color: AppColors.accentGreen,
        ),
        _buildStatCard(
          title: 'Total Area (acres)',
          value: '180',
          icon: Icons.grass,
          color: AppColors.infoBlue,
        ),
        _buildStatCard(
          title: 'This Month Usage',
          value: '450 L',
          icon: Icons.local_fire_department,
          color: AppColors.warningAmber,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingApplicationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Upcoming Applications'),
          _buildApplicationList(),
        ],
      ),
    );
  }

  Widget _buildApplicationList() {
    return Consumer(
      builder: (context, ref, child) {
        // Build filters for the provider
        final filters = <String, dynamic>{
          if (_selectedStatus != 'All') 'status': _selectedStatus.toLowerCase(),
          if (_selectedCropType != 'All')
            'cropType': _selectedCropType.toLowerCase(),
          'limit': 10,
          'offset': 0,
        };

        final applicationsAsync = ref.watch(
          pesticideApplicationHistoryProvider(filters),
        );

        return applicationsAsync.when(
          data: (applications) => applications.isEmpty
              ? _buildEmptyApplicationsState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    return _buildApplicationCard(application);
                  },
                ),
          loading: () => ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ApplicationShimmerCard(),
              ApplicationShimmerCard(),
              ApplicationShimmerCard(),
            ],
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading applications: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyApplicationsState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No pesticide applications found',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first pesticide schedule to get started',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(PesticideApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: application.isExecuted
            ? AppColors.accentGreen.withOpacity(0.05)
            : AppColors.warningAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: application.isExecuted
              ? AppColors.accentGreen.withOpacity(0.2)
              : AppColors.warningAmber.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: application.isExecuted
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : AppColors.warningAmber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                application.isExecuted
                    ? Icons.check_circle
                    : Icons.pending_actions,
                color: application.isExecuted
                    ? AppColors.accentGreen
                    : AppColors.warningAmber,
                size: 18,
              ),
            ),
          ],
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
        trailing: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.accentGreen,
          ),
          onPressed: () {
            ref
                .read(appRouterProvider)
                .push('/pesticide-application-detail/${application.id}');
          },
        ),
      ),
    );
  }

  Widget _buildScheduleListSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Pesticide Schedules'),
          _buildScheduleList(),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Consumer(
      builder: (context, ref, child) {
        // Build filters for the provider
        final filters = <String, dynamic>{
          if (_selectedStatus != 'All') 'status': _selectedStatus.toLowerCase(),
          if (_selectedCropType != 'All')
            'cropType': _selectedCropType.toLowerCase(),
          'limit': 20,
          'offset': 0,
        };

        final schedulesAsync = ref.watch(pesticideSchedulesProvider(filters));

        return schedulesAsync.when(
          data: (schedules) => schedules.isEmpty
              ? _buildEmptySchedulesState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                ),
          loading: () => ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ScheduleShimmerCard(),
              ScheduleShimmerCard(),
              ScheduleShimmerCard(),
            ],
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading schedules: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySchedulesState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.local_florist,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No pesticide schedules found',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first pesticide schedule to get started',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(PesticideSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: schedule.isActive
            ? AppColors.accentGreen.withOpacity(0.05)
            : AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.isActive
              ? AppColors.accentGreen.withOpacity(0.2)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: schedule.isActive
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.local_florist,
                color: schedule.isActive
                    ? AppColors.accentGreen
                    : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
        title: Text(
          schedule.pesticideType,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: schedule.isActive
                ? AppColors.accentGreen
                : AppColors.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop: ${schedule.cropType}', style: AppTypography.bodySmall),
            const SizedBox(height: 2),
            Text(
              'Application Rate: ${schedule.applicationRate} ${schedule.unit}/acre',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Frequency: ${schedule.frequency}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Status: ${schedule.isActive ? 'Active' : 'Incomplete'}',
              style: TextStyle(
                color: schedule.isActive
                    ? AppColors.accentGreen
                    : AppColors.dangerRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accentGreen),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit pesticide schedule'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: schedule.isActive ? null : AppColors.dangerRed,
              ),
              onPressed: schedule.isActive
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Schedule'),
                          content: const Text(
                            'Are you sure you want to delete this pesticide schedule?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Schedule deleted'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
            ),
          ],
        ),
        onTap: () {
          ref
              .read(appRouterProvider)
              .push('/pesticide-schedule-detail/${schedule.id}');
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTypography.titleMedium),
    );
  }
}

// Shimmer cards for loading state
class ApplicationShimmerCard extends StatelessWidget {
  const ApplicationShimmerCard({Key? key}) : super(key: key);

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
                SizedBox(width: 32, height: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 200, height: 16),
                      SizedBox(width: 150, height: 12),
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

class ScheduleShimmerCard extends StatelessWidget {
  const ScheduleShimmerCard({Key? key}) : super(key: key);

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
                SizedBox(width: 32, height: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 150, height: 16),
                      SizedBox(width: 100, height: 12),
                      SizedBox(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const KisanShimmer(child: SizedBox(width: 200, height: 12)),
        ],
      ),
    );
  }
}
