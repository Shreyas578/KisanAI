import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketplaceHomeScreen> createState() =>
      _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  bool _isLoading = true;
  List<MarketplaceListing> _featuredListings = [];
  List<String> _categories = [];
  Map<String, dynamic>? _mandiPrice;
  Map<String, dynamic>? _marketNews;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get farmer profile for state
      final profile = ref.read(farmerProfileProvider);
      final userState = profile?.state;

      // Get featured listings for user's state
      final featuredListingsFuture = ref.refresh(
        marketplaceListingsProvider({
          if (userState != null && userState.isNotEmpty) 'location': userState,
          'limit': 6,
        }).future,
      );

      // Get categories
      final categoriesFuture = ref.refresh(marketplaceCategoriesProvider.future);

      // Fetch Market Intelligence Snapshot (Mandi Price and News)
      final commodity = 'Wheat'; // Could be dynamic based on user profile
      final stateQuery = userState ?? 'Maharashtra';
      final priceUri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.priceEndpoint}/commodity?commodity=$commodity&state=$stateQuery&period=week');
      final newsUri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.newsEndpoint}?query=agriculture farming $stateQuery');
      
      final priceFuture = http.get(priceUri).timeout(ApiConfig.connectionTimeout).catchError((_) => http.Response('{}', 500));
      final newsFuture = http.get(newsUri).timeout(ApiConfig.connectionTimeout).catchError((_) => http.Response('{}', 500));

      final results = await Future.wait([
        featuredListingsFuture,
        categoriesFuture,
        priceFuture,
        newsFuture
      ]);

      if (mounted) {
        Map<String, dynamic>? priceData;
        Map<String, dynamic>? newsData;
        
        try {
          final pRes = results[2] as http.Response;
          if (pRes.statusCode == 200) {
            final parsed = json.decode(pRes.body)['data'];
            if (parsed != null && parsed['market_data'] != null) {
              final markets = parsed['market_data']['markets'] as List;
              if (markets.isNotEmpty) priceData = markets[0];
            }
          }
        } catch (_) {}

        try {
          final nRes = results[3] as http.Response;
          if (nRes.statusCode == 200) {
            final parsed = json.decode(nRes.body)['data'];
            if (parsed != null && parsed is List && parsed.isNotEmpty) {
              newsData = parsed[0];
            }
          }
        } catch (_) {}

        setState(() {
          _featuredListings = results[0] as List<MarketplaceListing>;
          _categories = results[1] as List<String>;
          _mandiPrice = priceData;
          _marketNews = newsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // In a real app, you might want to show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Marketplace',
                showSearch: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Text(
                      'Welcome to Kisan Marketplace',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buy and sell fresh produce directly from farmers',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickActionCard(
                            'Sell Produce',
                            Icons.add_circle_outline,
                            AppColors.accentGreen,
                            () => ref.read(appRouterProvider).go('/create-listing'),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickActionCard(
                            'My Listings',
                            Icons.list_alt,
                            AppColors.infoBlue,
                            () => ref.read(appRouterProvider).go('/my-listings'),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickActionCard(
                            'Orders',
                            Icons.shopping_cart,
                            AppColors.warningAmber,
                            () => {}, // TODO: Orders screen
                          ),
                          const SizedBox(width: 12),
                          _buildQuickActionCard(
                            'Messages',
                            Icons.chat_bubble_outline,
                            Colors.purple,
                            () => {}, // TODO: Messages screen
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Categories Section
                    Text(
                      'Categories',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const SizedBox(
                            height: 80,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentGreen,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return _buildCategoryCard(category);
                              },
                            ),
                          ),
                    const SizedBox(height: 24),
                    
                    // Market Intelligence Section (Mandi Price + News)
                    if (!_isLoading && (_mandiPrice != null || _marketNews != null)) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Market Insights',
                            style: AppTypography.titleMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              // Optional: Navigate to full Market Prices Screen
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Top Mandi Price Card
                      if (_mandiPrice != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.trending_up, color: AppColors.accentGreen, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Top Mandi Price',
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _mandiPrice!['name'] ?? 'Local Market',
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Wheat', // Fallback, could be dynamic
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${_mandiPrice!['modal'] ?? 0}/q',
                                    style: AppTypography.titleMedium.copyWith(color: AppColors.accentGreen),
                                  ),
                                  Text(
                                    'High: ₹${_mandiPrice!['max'] ?? 0}',
                                    style: AppTypography.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // Market News Snippet
                      if (_marketNews != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.infoBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.infoBlue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.article_outlined, color: AppColors.infoBlue, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _marketNews!['title'] ?? 'Agriculture News',
                                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _marketNews!['source']?['name'] ?? 'Local Source',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.infoBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Featured Listings
                    Text(
                      'Featured Listings',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentGreen,
                              ),
                            ),
                          )
                        : _featuredListings.isEmpty
                            ? const Center(
                                child: Text('No featured listings available'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _featuredListings.length,
                                itemBuilder: (context, index) {
                                  final listing = _featuredListings[index];
                                  return _buildFeaturedListingCard(listing);
                                },
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

  Widget _buildQuickActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    // Mock category data for display - in a real app, you'd have a proper category model
    final Map<String, Object> categoryData = {
      'Grains & Cereals': {'icon': Icons.rice_bowl, 'color': AppColors.accentGreen, 'count': 45},
      'Vegetables': {'icon': Icons.nature_people, 'color': AppColors.warningAmber, 'count': 67},
       'Fruits': {'icon': Icons.apple, 'color': AppColors.dangerRed, 'count': 32},
      'Cash Crops': {'icon': Icons.local_florist, 'color': AppColors.infoBlue, 'count': 28},
       'Spices': {'icon': Icons.grass, 'color': Colors.purple, 'count': 19},
      'Organic Produce': {'icon': Icons.eco, 'color': Colors.green, 'count': 23},
    }[category] ?? {
      'icon': Icons.category,
      'color': AppColors.textSecondary,
      'count': 0
    };

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
               color: (categoryData['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                 color: (categoryData['color'] as Color).withOpacity(0.2),
              ),
            ),
            child: Icon(
               categoryData['icon'] as IconData,
              size: 24,
               color: categoryData['color'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
               color: (categoryData['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${categoryData['count']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                 color: categoryData['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListingCard(MarketplaceListing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: listing.isOrganic
            ? AppColors.accentGreen.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: listing.isOrganic
              ? AppColors.accentGreen.withOpacity(0.2)
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(16)),
            child: listing.imageUrl.isNotEmpty
                ? Image.network(
                    listing.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
                  )
                : Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${listing.price}/${listing.unit}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: listing.isOrganic
                        ? AppColors.accentGreen
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.location,
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.sellerName,
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      listing.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${listing.totalReviews})',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(16)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColors.primaryBackground,
              ),
              onPressed: () {
                // Navigate to listing detail
                ref.read(appRouterProvider).go('/listing-detail/${listing.id}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
