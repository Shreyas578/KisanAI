import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';
import 'package:kisan_ai/features/marketplace/screens/payment_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({Key? key, required this.listingId})
    : super(key: key);

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  bool _isInquirySent = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(
      marketplaceListingProvider(widget.listingId),
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: KisanAppBar(title: 'Listing Details'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: listingAsync.when(
                  data: (listing) => _buildListingContent(listing),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGreen,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error loading listing: $error',
                      style: TextStyle(color: AppColors.dangerRed),
                    ),
                  ),
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

  Widget _buildListingContent(MarketplaceListing listing) {
    final user = ref.watch(currentUserProvider);
    final isSeller = user?.id != null && user!.id == listing.sellerId;
    final canBuy = !isSeller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Images Slider Placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: listing.images.isNotEmpty
              ? PageView.builder(
                  itemCount: listing.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = listing.images[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 50)),
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 50)),
                            ),
                    );
                  },
                )
              : Center(child: Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 50))),
        ),
        SizedBox(height: 16),
        // Header with Title and Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: AppTypography.titleLarge),
                  SizedBox(height: 4),
                  Text(
                    'By ${listing.sellerName}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.dangerRed
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite
                              ? 'Added to favorites'
                              : 'Removed from favorites',
                        ),
                        backgroundColor: _isFavorite
                            ? AppColors.accentGreen
                            : AppColors.textSecondary,
                      ),
                    );
                  },
                  tooltip: _isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                ),
                SizedBox(height: 4),
                Text(
                  'Save',
                  style: AppTypography.labelMedium.copyWith(
                    color: _isFavorite
                        ? AppColors.dangerRed
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        // Price and Availability
        Row(
          children: [
            Expanded(
              child: Text(
                '₱${listing.price}/${listing.unit}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: listing.isOrganic
                      ? AppColors.accentGreen
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: listing.isOrganic
                    ? AppColors.accentGreen.withOpacity(0.1)
                    : AppColors.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: listing.isOrganic
                      ? AppColors.accentGreen
                      : AppColors.warningAmber,
                ),
              ),
              child: Text(
                listing.isOrganic ? 'Organic' : 'Conventional',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: listing.isOrganic
                      ? AppColors.accentGreen
                      : AppColors.warningAmber,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Available: ${listing.quantityAvailable} ${listing.unit}',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12),
        // Rating and Stats
        Row(
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 18, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  listing.averageRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                Text(
                  '(${listing.totalReviews})',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${listing.views} views',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.infoBlue,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${listing.inquiries} inquiries',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warningAmber,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        // Description
        Text('Product Description', style: AppTypography.titleMedium),
        SizedBox(height: 8),
        Text(listing.description, style: AppTypography.bodyLarge),
        SizedBox(height: 24),
        // Specifications (if any)
        if (listing.additionalInfo.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specifications', style: AppTypography.titleMedium),
              SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: listing.additionalInfo.entries
                    .map<Widget>(
                      (entry) => Chip(
                        label: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTypography.bodyMedium,
                        ),
                        backgroundColor: AppColors.surfaceElevated,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 24),
            ],
          ),
        // Seller Information
        Text('Seller Information', style: AppTypography.titleMedium),
        SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentGreen.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColors.accentGreen),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.sellerName, style: AppTypography.titleMedium),
                  Text(
                    '${listing.category} • ${listing.location}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Contact Information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Text('Contact Seller', style: AppTypography.titleMedium),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement calling functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling seller...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: Icon(Icons.phone),
                      label: Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.primaryBackground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to chat screen with seller
                        // TODO: Implement chat navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening chat with seller...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: Icon(Icons.chat),
                      label: Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.accentGreen),
                        foregroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        // Action Buttons or Insights
        if (isSeller)
          _buildSellerInsights(listing)
        else if (!_isInquirySent)
          Column(
            children: [
              if (canBuy) ...[
                KisanButton(
                  text: 'Buy Now',
                  isPrimary: true,
                  onPressed: () => _showBuyDialog(context, listing, user!.id),
                  width: double.infinity,
                ),
                SizedBox(height: 12),
              ],
              KisanButton(
                text: 'Send Inquiry',
                isPrimary: !canBuy,
                onPressed: () {
                  setState(() => _isInquirySent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inquiry sent to seller!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Reset after 2 seconds
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isInquirySent = false);
                    }
                  });
                },
                width: double.infinity,
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share link copied to clipboard!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentGreen),
                  foregroundColor: AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Share Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.accentGreen),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your inquiry has been sent to the seller.',
                    style: AppTypography.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSellerInsights(MarketplaceListing listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.accentGreen),
              SizedBox(width: 8),
              Text('Your Listing Insights', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventory Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    listing.quantityAvailable > 0 ? 'Active' : 'Sold Out',
                    style: TextStyle(
                      color: listing.quantityAvailable > 0 ? AppColors.accentGreen : AppColors.dangerRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Available Stock', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.quantityAvailable} ${listing.unit}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
            child: const Text('Edit Listing'),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(BuildContext context, MarketplaceListing listing, String buyerId) {
    if (listing.quantityAvailable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is out of stock.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Select Quantity', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How many ${listing.unit}s of ${listing.title} do you want to buy?',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: quantity < listing.quantityAvailable
                          ? () => setState(() => quantity++)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${(listing.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to Payment Screen
                  final orderId = const Uuid().v4();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        orderId: orderId,
                        buyerId: buyerId,
                        sellerId: listing.sellerId,
                        listingId: listing.id,
                        amount: listing.price * quantity,
                        productName: listing.title,
                        quantity: quantity,
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Payment', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
