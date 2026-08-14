import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/offline_banner.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _wishlistItems = [];
  double _totalSpent = 0;
  int _ordersCount = 0;
  double _averageRating = 0;
  List<Map<String, dynamic>> _recommendedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadBuyerData();
  }

  Future<void> _loadBuyerData() async {
    // Simulate loading buyer dashboard data
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _totalSpent = 87500 + (Random().nextDouble() * 32500);
      _ordersCount = 12 + (Random().nextInt(18));
      _averageRating = 4.3 + (Random().nextDouble() * 0.6);
      _recentOrders = [
        {
          'id': 'order_001',
          'productName': 'Organic Basmati Rice',
          'quantity': 2,
          'unit': 'quintal',
          'pricePerUnit': 4200,
          'totalAmount': 8400,
          'sellerName': 'GreenFields Farm',
          'sellerLocation': 'Punjab, India',
          'orderDate': '2024-01-15',
          'status': 'delivered',
          'paymentStatus': 'paid',
          'productImage': 'assets/rice1.jpg',
          'rating': 5,
        },
        {
          'id': 'order_002',
          'productName': 'Fresh Tomatoes',
          'quantity': 5,
          'unit': 'quintal',
          'pricePerUnit': 800,
          'totalAmount': 4000,
          'sellerName': 'FreshHarvest Ltd.',
          'sellerLocation': 'Maharashtra, India',
          'orderDate': '2024-01-14',
          'status': 'delivered',
          'paymentStatus': 'paid',
          'productImage': 'assets/tomato1.jpg',
          'rating': 4,
        },
        {
          'id': 'order_003',
          'productName': 'Cotton Fabric',
          'quantity': 10,
          'unit': 'meter',
          'pricePerUnit': 350,
          'totalAmount': 3500,
          'sellerName': 'Textile Mills Ltd.',
          'sellerLocation': 'Gujarat, India',
          'orderDate': '2024-01-13',
          'status': 'processing',
          'paymentStatus': 'paid',
          'productImage': 'assets/cotton_fabric1.jpg',
        },
        {
          'id': 'order_004',
          'productName': 'Sugarcane Juice',
          'quantity': 20,
          'unit': 'liter',
          'pricePerUnit': 40,
          'totalAmount': 800,
          'sellerName': 'NaturalJuice Co.',
          'sellerLocation': 'Uttar Pradesh, India',
          'orderDate': '2024-01-12',
          'status': 'pending',
          'paymentStatus': 'pending',
          'productImage': 'assets/juice1.jpg',
        },
      ];
      _wishlistItems = [
        {
          'id': 'wl_001',
          'name': 'Premium Honey',
          'price': 1200,
          'unit': 'kg',
          'imageUrl': 'assets/honey1.jpg',
          'seller': 'BeeKeepers United',
        },
        {
          'id': 'wl_002',
          'name': 'Organic Spices Kit',
          'price': 850,
          'unit': 'set',
          'imageUrl': 'assets/spices1.jpg',
          'seller': 'SpiceGrowers Co-op',
        },
        {
          'id': 'wl_003',
          'name': 'Fresh Mangoes',
          'price': 1500,
          'unit': 'quintal',
          'imageUrl': 'assets/mango1.jpg',
          'seller': 'SunKiss Orchards',
        },
      ];
      _recommendedProducts = [
        {
          'id': 'rec_001',
          'name': 'Drip Irrigation Kit',
          'price': 4500,
          'rating': 4.7,
          'reviews': 124,
          'imageUrl': 'assets/irrigation1.jpg',
          'discount': 15,
          'originalPrice': 5294,
        },
        {
          'id': 'rec_002',
          'name': 'Organic Fertilizer',
          'price': 800,
          'rating': 4.5,
          'reviews': 89,
          'imageUrl': 'assets/fertilizer1.jpg',
          'discount': 10,
          'originalPrice': 889,
        },
        {
          'id': 'rec_003',
          'name': 'Seed Storage Container',
          'price': 1200,
          'rating': 4.8,
          'reviews': 67,
          'imageUrl': 'assets/storage1.jpg',
          'discount': 0,
          'originalPrice': 1200,
        },
      ];
      _isLoading = false;
    });
  }

  String _formatNumber(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
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
              child: KisanAppBar(title: 'Buyer Dashboard'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      )
                    : Column(
                        children: [
                          // Overview Cards
                          ResponsiveGridList(
                            desiredItemWidth: 160,
                            children: [
                              _buildOverviewCard(
                                'Total Spent',
                                _formatNumber(_totalSpent),
                                '₱',
                                Icons.credit_card,
                                AppColors.accentGreen,
                              ),
                              _buildOverviewCard(
                                'Orders Placed',
                                _ordersCount.toString(),
                                '',
                                Icons.shopping_bag,
                                AppColors.infoBlue,
                              ),
                              _buildOverviewCard(
                                'Avg. Rating',
                                '${_averageRating.toStringAsFixed(1)}',
                                '★',
                                Icons.star,
                                Colors.amber,
                              ),
                              _buildOverviewCard(
                                'Budget Utilization',
                                '65%',
                                '',
                                Icons.account_balance_wallet,
                                AppColors.warningAmber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Budget Management
                          _buildSectionHeader('Budget Management'),
                          const SizedBox(height: 12),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentGreen,
                                  ),
                                )
                              : _buildBudgetSection(),
                          const SizedBox(height: 24),
                          // Recent Orders
                          _buildSectionHeader('Recent Orders'),
                          const SizedBox(height: 12),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentGreen,
                                  ),
                                )
                              : _recentOrders.isEmpty
                              ? _buildEmptyState(
                                  'No recent orders',
                                  'Your order history will appear here.',
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _recentOrders[index];
                                    return _buildOrderCard(order);
                                  },
                                ),
                          const SizedBox(height: 24),
                          // Saved Searches
                          _buildSectionHeader('Saved Searches'),
                          const SizedBox(height: 12),
                          _wishlistItems.isEmpty
                              ? _buildEmptyState(
                                  'No saved searches',
                                  'Save your favorite searches to find products faster.',
                                )
                              : Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: _wishlistItems
                                      .map((item) => _buildWishlistItem(item))
                                      .toList(),
                                ),
                          const SizedBox(height: 24),
                          // Recommended Products
                          _buildSectionHeader('Recommended for You'),
                          const SizedBox(height: 12),
                          _recommendedProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No recommendations available',
                                    style: AppTypography.bodyLarge,
                                  ),
                                )
                              : SizedBox(
                                  height: 140,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: _recommendedProducts
                                        .map(
                                          (product) =>
                                              _buildRecommendationCard(product),
                                        )
                                        .toList(),
                                  ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGreen,
        onPressed: () {
          // TODO: Quick add to cart or search
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quick add feature coming soon!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    String prefix,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              '$prefix$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleMedium),
        TextButton(
          onPressed: () {
            // TODO: Navigate to full list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View all'),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          },
          child: Text(
            'View All',
            style: TextStyle(color: AppColors.accentGreen, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.outlined_flag, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      children: [
        // Monthly Budget Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Budget', style: AppTypography.titleMedium),
                  TextButton(
                    onPressed: () {
                      // TODO: Edit budget
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit budget'),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Budget progress
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.65, // 65% utilization
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.warningAmber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '₱87,500 / ₹1,35,000',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent this month',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₱87,500',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₱47,500',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Budget alerts
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget Alerts', style: AppTypography.titleMedium),
                  Icon(
                    Icons.notifications_active,
                    color: AppColors.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBudgetAlert(
                'Price drop alert',
                'Saved 15% on fertilizer purchase',
                true,
              ),
              const SizedBox(height: 8),
              _buildBudgetAlert(
                'Over budget warning',
                'Exceeded seed budget by 8%',
                false,
              ),
              const SizedBox(height: 8),
              _buildBudgetAlert(
                'Saving suggestion',
                'Consider bulk purchase for better rates',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetAlert(String title, String description, bool isPositive) {
    return Row(
      children: [
        Icon(
          isPositive ? Icons.check_circle : Icons.warning_amber,
          color: isPositive ? AppColors.accentGreen : AppColors.warningAmber,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive
                      ? AppColors.accentGreen
                      : AppColors.warningAmber,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: order['status'] == 'cancelled'
            ? AppColors.dangerRed.withOpacity(0.05)
            : order['status'] == 'delivered'
            ? AppColors.accentGreen.withOpacity(0.05)
            : order['paymentStatus'] == 'pending'
            ? AppColors.warningAmber.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order['status'] == 'cancelled'
              ? AppColors.dangerRed
              : order['status'] == 'delivered'
              ? AppColors.accentGreen
              : order['paymentStatus'] == 'pending'
              ? AppColors.warningAmber
              : AppColors.borderSubtle,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            order['productImage'] as String,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          order['productName'] as String,
          style: AppTypography.titleMedium.copyWith(
            color: order['status'] == 'cancelled'
                ? AppColors.dangerRed
                : order['status'] == 'delivered'
                ? AppColors.accentGreen
                : order['paymentStatus'] == 'paid'
                ? AppColors.textPrimary
                : AppColors.warningAmber,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order['quantity']} ${order['unit']}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Seller: ${order['sellerName']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '📍 ${order['sellerLocation']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${order['orderDate']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₱${order['totalAmount'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: order['status'] == 'cancelled'
                    ? AppColors.dangerRed
                    : order['status'] == 'delivered'
                    ? AppColors.accentGreen
                    : order['paymentStatus'] == 'paid'
                    ? AppColors.textPrimary
                    : order['paymentStatus'] == 'pending'
                    ? AppColors.warningAmber
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order['status']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(order['status']),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(order['status']),
                ),
              ),
            ),
            if (order['rating'] != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '★${order['rating']}',
                  style: TextStyle(fontSize: 10, color: Colors.amber),
                ),
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to order detail
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viewing order details...'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(item['imageUrl'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${item['price']}/${item['unit']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['seller'] as String,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: AppColors.accentGreen,
                  ),
                  onPressed: () {
                    // Add to cart
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.dangerRed),
                  onPressed: () {
                    // Remove from wishlist
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from wishlist'),
                        backgroundColor: AppColors.dangerRed,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> product) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Image with discount badge
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(product['imageUrl'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (product['discount'] > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product['discount']}% OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₱${product['price']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: product['discount'] > 0
                            ? AppColors.dangerRed
                            : AppColors.accentGreen,
                      ),
                    ),
                    if (product['discount'] > 0)
                      Text(
                        ' ₱${product['originalPrice']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${product['rating']}',
                      style: TextStyle(fontSize: 10, color: Colors.amber),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product['reviews']})',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add to Cart Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ElevatedButton(
              onPressed: () {
                // Add to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.primaryBackground,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningAmber;
      case 'confirmed':
        return AppColors.infoBlue;
      case 'processing':
        return AppColors.infoBlue;
      case 'shipped':
        return AppColors.accentGreen;
      case 'delivered':
        return AppColors.accentGreen;
      case 'cancelled':
        return AppColors.dangerRed;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Helper class for responsive grid layout (same as in supplier dashboard)
class ResponsiveGridList extends StatelessWidget {
  final double desiredItemWidth;
  final double minSpacing;
  final int? rowCount;
  final List<Widget> children;

  const ResponsiveGridList({
    Key? key,
    required this.desiredItemWidth,
    this.minSpacing = 16,
    this.rowCount,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = (screenWidth / desiredItemWidth).floor().clamp(
      1,
      rowCount ?? 100,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: minSpacing,
      crossAxisSpacing: minSpacing,
      children: children,
    );
  }
}
