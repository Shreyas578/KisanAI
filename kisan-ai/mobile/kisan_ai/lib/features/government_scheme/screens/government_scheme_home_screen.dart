import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/government_scheme/state/government_scheme_provider.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/government_scheme_model.dart';

class GovernmentSchemeHomeScreen extends ConsumerStatefulWidget {
  const GovernmentSchemeHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GovernmentSchemeHomeScreen> createState() =>
      _GovernmentSchemeHomeScreenState();
}

class _GovernmentSchemeHomeScreenState
    extends ConsumerState<GovernmentSchemeHomeScreen> {
  String _selectedSchemeType = 'All';
  String _selectedFarmerType = 'All';
  bool _showActiveOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Government Schemes'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Text(
                      'Government Schemes for Farmers',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find and apply for relevant government schemes',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Filter Bar
                    _buildFilterBar(ref),
                    const SizedBox(height: 24),
                    // Schemes List
                    _buildSchemesList(ref),
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
          // Show dialog to request new scheme information
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Request Scheme Information'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tell us what type of scheme you are interested in:',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g., Loan schemes, Subsidy schemes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
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
                        content: Text(
                          'Thank you! We will add relevant schemes soon.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Widget _buildFilterBar(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              // Scheme Type Filter
              _buildDropdownFilter(
                label: 'Scheme Type',
                value: _selectedSchemeType,
                items: [
                  'All',
                  'Subsidy',
                  'Loan',
                  'Insurance',
                  'Training',
                  'Equipment',
                ],
                onChanged: (value) {
                  setState(() => _selectedSchemeType = value!);
                },
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              // Farmer Type Filter
              _buildDropdownFilter(
                label: 'Farmer Type',
                value: _selectedFarmerType,
                items: [
                  'All',
                  'Small Farmer',
                  'Marginal Farmer',
                  'Large Farmer',
                  'Women Farmer',
                  'Young Farmer',
                ],
                onChanged: (value) {
                  setState(() => _selectedFarmerType = value!);
                },
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              // Active Only Switch
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Show Active Schemes Only',
                      style: AppTypography.bodyMedium,
                    ),
                    Switch(
                      value: _showActiveOnly,
                      activeColor: AppColors.accentGreen,
                      onChanged: (value) {
                        setState(() => _showActiveOnly = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildSchemesList(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        // Build filters for the provider: schemeType|cropType|farmerType|activeOnly
        final String schemeType = _selectedSchemeType != 'All' ? _selectedSchemeType.toLowerCase() : '';
        final String cropType = ''; // Add cropType if needed in future
        final String farmerType = _selectedFarmerType != 'All' ? _selectedFarmerType.toLowerCase() : '';
        final String activeOnly = _showActiveOnly.toString();
        
        final String filtersStr = '$schemeType|$cropType|$farmerType|$activeOnly';

        final schemesAsync = ref.watch(governmentSchemesProvider(filtersStr));

        return schemesAsync.when(
          data: (schemes) => schemes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schemes.length,
                  itemBuilder: (context, index) {
                    final scheme = schemes[index];
                    return _buildSchemeCard(scheme);
                  },
                ),
          loading: () => ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SchemeShimmerCard(),
              SchemeShimmerCard(),
              SchemeShimmerCard(),
            ],
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading schemes: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('No schemes found', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters to see more schemes',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          KisanButton(
            text: 'Reset Filters',
            isPrimary: true,
            onPressed: () {
              setState(() {
                _selectedSchemeType = 'All';
                _selectedFarmerType = 'All';
                _showActiveOnly = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: scheme.isActive
            ? AppColors.accentGreen.withOpacity(0.05)
            : AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.isActive
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
                color: scheme.isActive
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSchemeIcon(scheme.schemeType),
                color: scheme.isActive
                    ? AppColors.accentGreen
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
        title: Text(
          scheme.title,
          style: AppTypography.titleMedium.copyWith(
            color: scheme.isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Scheme Type: ${scheme.schemeType}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scheme.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Beneficiary: ${scheme.rawEligibilityCriteria}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${scheme.isActive ? 'Active' : 'Inactive'}',
              style: TextStyle(
                color: scheme.isActive
                    ? AppColors.accentGreen
                    : AppColors.dangerRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: scheme.isActive ? AppColors.accentGreen : Colors.grey,
        ),
        onTap: () {
          ref
              .read(appRouterProvider)
              .push('/government-scheme-detail/${scheme.id}');
        },
      ),
    );
  }

  IconData _getSchemeIcon(String schemeType) {
    switch (schemeType.toLowerCase()) {
      case 'subsidy':
        return Icons.monetization_on;
      case 'loan':
        return Icons.account_balance;
      case 'insurance':
        return Icons.security;
      case 'training':
        return Icons.school;
      case 'equipment':
        return Icons.agriculture;
      default:
        return Icons.public;
    }
  }
}

// Shimmer card for loading state
class SchemeShimmerCard extends StatelessWidget {
  const SchemeShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const KisanShimmer(child: Icon(Icons.public, size: 20)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KisanShimmer(child: SizedBox(width: 120, height: 16)),
            const SizedBox(height: 4),
            const KisanShimmer(child: SizedBox(width: 80, height: 12)),
            const SizedBox(height: 4),
            const KisanShimmer(child: SizedBox(width: 60, height: 12)),
          ],
        ),
      ),
    );
  }
}
