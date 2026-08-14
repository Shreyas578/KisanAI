import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/language_voice_widgets.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/utils/ipfs_utils.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF00E676).withOpacity(0.2)
            : const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF2A3830),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF8BA898),
        ),
      ),
    );
  }
}

class _MarketplaceTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _MarketplaceTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF8BA898),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceListing listing;

  const _ProductCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111814),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3830), width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to listing detail
          if (listing.id.isNotEmpty) {
            context.push('/marketplace/listing/${listing.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Use IPFS gateway if available
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: listing.images.isNotEmpty
                  ? IPFSUtils.displayImage(
                      ipfsHash: listing.images.first,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    )
                  : listing.imageUrl.isNotEmpty
                  ? Image.network(
                      listing.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
                    )
                  : Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0FFF4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${listing.price}/${listing.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E676),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF8BA898),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8BA898),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        if (listing.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E676),
                              ),
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Color(0xFF00E676),
                          ),
                          onPressed: () {
                            if (listing.id.isNotEmpty) {
                              context.push('/marketplace/listing/${listing.id}');
                            }
                          },
                        ),
                      ],
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
}

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _searchQuery = '';
  String _selectedTab = 'Produce';
  String _listingType = 'All'; // 'All' or 'My'
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Watch farmer profile to get user's state for location filtering
    final farmerProfile = ref.watch(farmerProfileProvider);
    String? userState = farmerProfile?.state;

    // Fetch all listings (we will filter by category on the client side)
    final filters = <String, dynamic>{
      // Location filtering disabled to show all available listings in the marketplace
      // if (userState != null && userState.isNotEmpty) 'location': userState,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KisanAppBar(title: 'Marketplace', showSearch: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildListingTypeToggle(),
                const SizedBox(height: 16),
                _buildMarketplaceTabs(ref),
                const SizedBox(height: 16),
                _buildProductGrid(ref, filters),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: const Color(0xFF0A0F0D),
        onPressed: () {
          // Create new listing
          ref.read(appRouterProvider).go('/create-listing');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickFilters(WidgetRef ref, Map<String, dynamic> filters) {
    return Consumer(
      builder: (context, ref, child) {
        final listingsAsync = ref.watch(marketplaceListingsProvider(filters));

        return listingsAsync.when(
          data: (listings) => KisanCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                ).onTap(() => setState(() => _selectedFilter = 'All')),
                _FilterChip(
                  label: 'Produce',
                  isSelected: _selectedFilter == 'Produce',
                ).onTap(() => setState(() => _selectedFilter = 'Produce')),
                _FilterChip(
                  label: 'Inputs',
                  isSelected: _selectedFilter == 'Inputs',
                ).onTap(() => setState(() => _selectedFilter = 'Inputs')),
                _FilterChip(
                  label: 'Equipment',
                  isSelected: _selectedFilter == 'Equipment',
                ).onTap(() => setState(() => _selectedFilter = 'Equipment')),
              ],
            ),
          ),
          loading: () => const KisanCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Produce', isSelected: false),
                _FilterChip(label: 'Inputs', isSelected: false),
                _FilterChip(label: 'Equipment', isSelected: false),
              ],
            ),
          ),
          error: (error, stackTrace) => KisanCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Produce', isSelected: false),
                _FilterChip(label: 'Inputs', isSelected: false),
                _FilterChip(label: 'Equipment', isSelected: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListingTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _listingType = 'All'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _listingType == 'All' ? AppColors.accentGreen : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _listingType == 'All' ? AppColors.accentGreen : AppColors.borderSubtle,
                  ),
                ),
                child: Center(
                  child: Text(
                    'All Listings',
                    style: TextStyle(
                      color: _listingType == 'All' ? AppColors.primaryBackground : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _listingType = 'My'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _listingType == 'My' ? AppColors.accentGreen : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _listingType == 'My' ? AppColors.accentGreen : AppColors.borderSubtle,
                  ),
                ),
                child: Center(
                  child: Text(
                    'My Listings',
                    style: TextStyle(
                      color: _listingType == 'My' ? AppColors.primaryBackground : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTabs(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        // We don't need data for tabs, just the UI state
        return KisanCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MarketplaceTab(
                label: 'Produce',
                isSelected: _selectedTab == 'Produce',
              ).onTap(() => setState(() => _selectedTab = 'Produce')),
              _MarketplaceTab(
                label: 'Inputs',
                isSelected: _selectedTab == 'Inputs',
              ).onTap(() => setState(() => _selectedTab = 'Inputs')),
              _MarketplaceTab(
                label: 'Equipment',
                isSelected: _selectedTab == 'Equipment',
              ).onTap(() => setState(() => _selectedTab = 'Equipment')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(WidgetRef ref, Map<String, dynamic> filters) {
    return Consumer(
      builder: (context, ref, child) {
        final listingsAsync = ref.watch(marketplaceListingsProvider(filters));

        return listingsAsync.when(
          data: (listings) => LayoutBuilder(
            builder: (context, constraints) {
              // Calculate cross axis count based on screen width
              int crossAxisCount = (constraints.maxWidth / 180).floor();
              if (crossAxisCount < 2) crossAxisCount = 2;
              if (crossAxisCount > 3) crossAxisCount = 3;

              // Filter listings based on listing type
              final currentUser = ref.watch(currentUserProvider);
              var displayListings = listings;
              
              if (_listingType == 'My') {
                if (currentUser != null) {
                  displayListings = listings.where((l) => l.sellerId == currentUser.id).toList();
                } else {
                  displayListings = [];
                }
              }
                  
              // Filter by the selected tab based on actual subcategories
              displayListings = displayListings.where((l) {
                if (_selectedTab == 'Equipment') {
                  return l.category.toLowerCase().contains('equipment');
                } else if (_selectedTab == 'Inputs') {
                  return l.category.toLowerCase().contains('seed') || 
                         l.category.toLowerCase().contains('fertilizer');
                } else {
                  // Produce tab covers everything else
                  return !l.category.toLowerCase().contains('equipment') &&
                         !l.category.toLowerCase().contains('seed') &&
                         !l.category.toLowerCase().contains('fertilizer');
                }
              }).toList();

              if (displayListings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Color(0xFF8BA898),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF0FFF4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _listingType == 'My' ? 'You have not created any listings.' : 'Be the first to list a product in this category!',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF8BA898),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.55,
                ),
                itemCount: displayListings.length,
                itemBuilder: (context, index) {
                  final listing = displayListings[index];
                  return _ProductCard(listing: listing);
                },
              );
            },
          ),
          loading: () => LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => KisanShimmer(
                child: _ProductCard(
                  listing: MarketplaceListing(
                    id: '',
                    title: 'Loading...',
                    description: '',
                    price: 0,
                    unit: '',
                    sellerId: '',
                    sellerName: '',
                    location: '',
                    category: '',
                    isOrganic: false,
                    isVerified: false,
                    quantityAvailable: 0,
                    totalReviews: 0,
                    averageRating: 0.0,
                    imageUrl: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => const Center(
            child: Text(
              'Failed to load listings',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}

// Extension to add onTap to widgets
extension GestureExtensions<T extends Widget> on T {
  Widget onTap(void Function() onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}
