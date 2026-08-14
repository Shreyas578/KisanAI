import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/input_management/irrigation/state/irrigation_provider.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/irrigation_model.dart';

class IrrigationHomeScreen extends ConsumerStatefulWidget {
  const IrrigationHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IrrigationHomeScreen> createState() =>
      _IrrigationHomeScreenState();
}

class _IrrigationHomeScreenState extends ConsumerState<IrrigationHomeScreen> {
  String _selectedStatus = 'All';
  String _selectedCropType = 'All';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Irrigation Management'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Text(
                      'Irrigation Management',
                      style: AppTypography.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage your irrigation schedules and water usage',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Filter Bar
                    _buildFilterBar(),
                    SizedBox(height: 24),
                    // Quick Stats
                    _buildQuickStats(),
                    SizedBox(height: 24),
                    // Upcoming Irrigations
                    _buildUpcomingIrrigationsSection(),
                    SizedBox(height: 24),
                    // Irrigation Schedule List
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
          // Navigate to create irrigation schedule
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new irrigation schedule'),
              duration: Duration(seconds: 1),
            ),
          );
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
          Divider(color: AppColors.borderSubtle, height: 1),
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
          Divider(color: AppColors.borderSubtle, height: 1),
          // Date Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Schedule Date: ${_selectedDate.toString().split(' ')[0]}',
                    style: AppTypography.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
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
          SizedBox(height: 8),
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
          value: '12',
          icon: Icons.timer,
          color: AppColors.accentGreen,
        ),
        _buildStatCard(
          title: 'Water Used This Month',
          value: '2.4 ML',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Upcoming Irrigations',
          value: '5',
          icon: Icons.schedule,
          color: Colors.orange,
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
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingIrrigationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming Irrigations', style: AppTypography.titleMedium),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildUpcomingIrrigationCard(
                title: 'North Field - Rice',
                date: 'Tomorrow, 6:00 AM',
                duration: '2 hours',
                waterAmount: '1.2 inches',
                status: 'Scheduled',
              ),
              _buildUpcomingIrrigationCard(
                title: 'East Field - Wheat',
                date: 'Today, 4:00 PM',
                duration: '1.5 hours',
                waterAmount: '0.8 inches',
                status: 'In Progress',
              ),
              _buildUpcomingIrrigationCard(
                title: 'South Field - Sugarcane',
                date: 'Day after tomorrow, 8:00 AM',
                duration: '3 hours',
                waterAmount: '2.0 inches',
                status: 'Scheduled',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingIrrigationCard({
    required String title,
    required String date,
    required String duration,
    required String waterAmount,
    required String status,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: status == 'In Progress'
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'In Progress'
              ? AppColors.accentGreen
              : AppColors.borderSubtle,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodyMedium),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: AppTypography.bodySmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'In Progress'
                        ? AppColors.accentGreen.withOpacity(0.2)
                        : AppColors.warningAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == 'In Progress'
                          ? AppColors.accentGreen
                          : AppColors.warningAmber,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.water_drop, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(waterAmount, style: AppTypography.bodySmall),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(duration, style: AppTypography.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Irrigation Schedules', style: AppTypography.titleMedium),
        SizedBox(height: 12),
        _buildScheduleList(),
      ],
    );
  }

  Widget _buildScheduleList() {
    return Consumer(
      builder: (context, ref, child) {
        // Build filters for the provider
        final filters = <String, dynamic>{
          if (_selectedStatus != 'All') 'status': _selectedStatus.toLowerCase(),
          if (_selectedCropType != 'All') 'cropType': _selectedCropType,
          'limit': 20,
          'offset': 0,
        };

        final schedulesAsync = ref.watch(irrigationSchedulesProvider(filters));

        return schedulesAsync.when(
          data: (schedules) => schedules.isEmpty
              ? _buildEmptyScheduleState()
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

  Widget _buildEmptyScheduleState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grass, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No irrigation schedules found',
            style: AppTypography.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Create your first irrigation schedule to get started',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          KisanButton(
            text: 'Create Schedule',
            isPrimary: true,
            onPressed: () {
              // Navigate to create schedule screen
              // TODO: Implement navigation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(IrrigationSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: schedule.isActive
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.opacity,
                color: schedule.isActive
                    ? AppColors.accentGreen
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
        title: Text(
          schedule.title,
          style: AppTypography.titleMedium.copyWith(
            color: schedule.isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop: ${schedule.cropType}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Area: ${schedule.area} acres',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Frequency: ${schedule.frequency}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Status: ${schedule.isActive ? 'Active' : 'Inactive'}',
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
                  SnackBar(
                    content: Text('Edit schedule: ${schedule.title}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            SizedBox(height: 4),
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
                            'Are you sure you want to delete this schedule?',
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
                                  SnackBar(
                                    content: Text(
                                      'Schedule deleted: ${schedule.title}',
                                    ),
                                    duration: const Duration(seconds: 1),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing details: ${schedule.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer card for loading state
class ScheduleShimmerCard extends StatelessWidget {
  const ScheduleShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200]!,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const KisanShimmer(child: Icon(Icons.opacity, size: 20)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KisanShimmer(child: SizedBox(width: 120, height: 16)),
            SizedBox(height: 4),
            const KisanShimmer(child: SizedBox(width: 80, height: 12)),
            SizedBox(height: 4),
            const KisanShimmer(child: SizedBox(width: 80, height: 12)),
          ],
        ),
      ),
    );
  }
}
