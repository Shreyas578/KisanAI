import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/government_scheme/state/government_scheme_provider.dart';
import 'package:kisan_ai/features/government_scheme/services/government_scheme_service.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/government_scheme_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GovernmentSchemeDetailScreen extends ConsumerStatefulWidget {
  final String schemeId;

  const GovernmentSchemeDetailScreen({
    Key? key,
    required this.schemeId,
  }) : super(key: key);

  @override
  ConsumerState<GovernmentSchemeDetailScreen> createState() =>
      _GovernmentSchemeDetailScreenState();
}

class _GovernmentSchemeDetailScreenState
    extends ConsumerState<GovernmentSchemeDetailScreen> {
  bool _isApplied = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Scheme Details',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildSchemeDetailContent(ref),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isApplied
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentGreen,
              onPressed: _isSaving ? null : _applyForScheme,
              label: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBackground,
                      ),
                    )
                  : const Text('Apply for Scheme'),
              icon: const Icon(Icons.app_registration),
            )
          : null,
    );
  }

  Widget _buildSchemeDetailContent(WidgetRef ref) {
    final schemeAsync = ref.watch(governmentSchemeProvider(widget.schemeId));

    return schemeAsync.when(
      data: (scheme) => _buildSchemeDetails(scheme),
      loading: () => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          SchemeDetailShimmer(),
          SchemeDetailShimmer(),
          SchemeDetailShimmer(),
          SchemeDetailShimmer(),
        ],
      ),
      error: (error, stackTrace) => Center(
            child: Text(
              'Error loading scheme details: $error',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
    );
  }

  Widget _buildSchemeDetails(GovernmentScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scheme Header
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.title,
                        style: AppTypography.titleLarge.copyWith(
                          color: scheme.isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scheme Type: ${scheme.schemeType}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (scheme.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
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
            Text(
              'Description',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              scheme.description,
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
        ),
        // Eligibility Criteria
        _buildSectionHeader('Eligibility Criteria'),
        _buildEligibilityCriteria(scheme.rawEligibilityCriteria),
        const SizedBox(height: 24),
        // Benefits
        _buildSectionHeader('Benefits'),
        _buildBenefits(scheme.rawBenefits),
        const SizedBox(height: 24),
        // Application Process
        _buildSectionHeader('Application Process'),
        _buildApplicationProcess(scheme.applicationProcess),
        const SizedBox(height: 24),
        // Required Documents
        _buildSectionHeader('Required Documents'),
        _buildRequiredDocuments(scheme.requiredDocuments.split(',')),
        const SizedBox(height: 24),
        // Important Dates
        _buildSectionHeader('Important Dates'),
        _buildImportantDates({
          'startDate': scheme.applicationStartDate,
          if (scheme.applicationEndDate != null) 'endDate': scheme.applicationEndDate!,
          if (scheme.schemeStartDate != null) 'effectiveDate': scheme.schemeStartDate!,
        }),
        const SizedBox(height: 24),
        // Official Links
        _buildSectionHeader('Official Links'),
        _buildOfficialLink(scheme.officialWebsite),
        const SizedBox(height: 24),
      ],
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

  Widget _buildEligibilityCriteria(String criteria) {
    return _buildInfoCard(
      title: 'Who Can Apply?',
      content: criteria,
      icon: Icons.person,
    );
  }

  Widget _buildBenefits(String benefits) {
    return _buildInfoCard(
      title: 'What Benefits Do You Get?',
      content: benefits,
      icon: Icons.monetization_on,
    );
  }

  Widget _buildApplicationProcess(String process) {
    return _buildInfoCard(
      title: 'How to Apply?',
      content: process,
            icon: Icons.description,
    );
  }

  Widget _buildRequiredDocuments(List<String> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents Required',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: documents
              .map((doc) => Chip(
                    label: Text(doc),
                    backgroundColor:
                        AppColors.accentGreen.withOpacity(0.1),
                    labelPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildImportantDates(Map<String, DateTime> dates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dates.containsKey('startDate'))
          _buildInfoRow(
            label: 'Application Start Date',
            value: dates['startDate']!.toString().split(' ')[0],
            icon: Icons.calendar_today,
          ),
        if (dates.containsKey('endDate'))
          _buildInfoRow(
            label: 'Application End Date',
            value: dates['endDate']!.toString().split(' ')[0],
            icon: Icons.calendar_today,
          ),
        if (dates.containsKey('effectiveDate'))
          _buildInfoRow(
            label: 'Effective From',
            value: dates['effectiveDate']!.toString().split(' ')[0],
            icon: Icons.calendar_today,
          ),
      ],
    );
  }

  Widget _buildOfficialLink(String url) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.accentGreen),
        title: Text(
          'Registration Portal',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          url.isNotEmpty ? url : 'Website not available',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            decoration: url.isNotEmpty ? TextDecoration.underline : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.open_in_new, size: 20, color: AppColors.textSecondary),
        onTap: () async {
          if (url.isNotEmpty) {
            final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open the link')),
                );
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
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

  void _applyForScheme() {
    setState(() => _isSaving = true);

    // TODO: Get current user ID from auth
    final String farmerId = 'current_farmer_id';

    // Create a basic application
    final application = FarmerSchemeApplication(
      id: '',
      schemeId: widget.schemeId,
      farmerId: farmerId,
      applicationDate: DateTime.now(),
      status: 'submitted',
      createdAt: DateTime.now(),
      // Additional fields would be filled based on form inputs
    );

    // Use the provider to submit the application
    final governmentSchemeService =
        ref.read(governmentSchemeServiceProvider);
    governmentSchemeService.applyForScheme(application).then(
      (applicationResult) {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _isApplied = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      },
    ).catchError((error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $error'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    });
  }
}

// Shimmer effect for loading state
class SchemeDetailShimmer extends StatelessWidget {
  const SchemeDetailShimmer({Key? key}) : super(key: key);

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
        ],
      ),
    );
  }
}
