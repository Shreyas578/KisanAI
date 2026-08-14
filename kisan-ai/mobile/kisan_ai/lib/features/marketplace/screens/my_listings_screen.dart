import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/offline_banner.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final String userId = currentUser?.id ?? '';

    // Parse filter for the provider
    final filters = <String, dynamic>{
      if (_selectedFilter != 'All') 'status': _selectedFilter.toLowerCase(),
    };

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your listings')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            const SizedBox(height: 8),
            Expanded(child: _buildListingsList(ref, userId, filters)),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        onPressed: () {
          ref.read(appRouterProvider).go('/create-listing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListingsList(
    WidgetRef ref,
    String userId,
    Map<String, dynamic> filters,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final listingsAsync = ref.watch(
          userMarketplaceListingsProvider({
            'userId': userId,
            ...filters,
            'limit': 20,
            'offset': 0,
          }),
        );

        return listingsAsync.when(
          data: (listings) => listings.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Filter Bar
                    _buildFilterBar(ref),
                    const SizedBox(height: 16),
                    // Listings List
                    Expanded(
                      child: ListView.builder(
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return _buildListingCard(listing);
                        },
                      ),
                    ),
                  ],
                ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accentGreen),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading listings: $error',
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
            Icons.inventory_2,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('No listings yet', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create your first listing to start selling',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          KisanButton(
            text: 'Create Listing',
            isPrimary: true,
            onPressed: () {
              ref.read(appRouterProvider).go('/create-listing');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Listings', style: AppTypography.titleMedium),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  items: ['All', 'Active', 'Sold', 'Inactive']
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: AppTypography.bodyLarge.copyWith(
                              color: _selectedFilter == status
                                  ? AppColors.primaryBackground
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                  dropdownColor: AppColors.surface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingCard(MarketplaceListing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: listing.isActive
            ? AppColors.accentGreen.withOpacity(0.1)
            : listing.status == 'sold'
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.dangerRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: listing.isActive
              ? AppColors.accentGreen
              : listing.status == 'sold'
              ? AppColors.successGreen
              : AppColors.dangerRed,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: listing.imageUrl.isNotEmpty
              ? Image.network(
                  listing.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
                )
              : Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
        ),
        title: Text(
          listing.title,
          style: AppTypography.titleMedium.copyWith(
            color: listing.isActive
                ? AppColors.accentGreen
                : listing.status == 'sold'
                ? AppColors.successGreen
                : AppColors.dangerRed,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₱${listing.price}/${listing.unit}',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: listing.isActive
                    ? AppColors.accentGreen
                    : listing.status == 'sold'
                    ? AppColors.successGreen
                    : AppColors.dangerRed,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📍 ${listing.location}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: listing.isActive
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : listing.status == 'sold'
                    ? AppColors.successGreen.withOpacity(0.2)
                    : AppColors.dangerRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                listing.isActive
                    ? 'Active'
                    : listing.status == 'sold'
                    ? 'Sold'
                    : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: listing.isActive
                      ? AppColors.accentGreen
                      : listing.status == 'sold'
                      ? AppColors.successGreen
                      : AppColors.dangerRed,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '👁️ ${listing.views} views',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to listing detail
          ref.read(appRouterProvider).go('/listing-detail/${listing.id}');
        },
      ),
    );
  }
}
