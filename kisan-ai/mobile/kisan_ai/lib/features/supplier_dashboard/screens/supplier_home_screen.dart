import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class SupplierHomeScreen extends ConsumerStatefulWidget {
  const SupplierHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends ConsumerState<SupplierHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _inventoryItems = [];
  double _monthlySales = 0;
  int _activeListings = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _loadSupplierData();
  }

  Future<void> _loadSupplierData() async {
    // Simulate loading supplier dashboard data
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _monthlySales = 245000 + (Random().nextDouble() * 15000);
      _activeListings = 8 + (Random().nextInt(7));
      _averageRating = 4.2 + (Random().nextDouble() * 0.8);
      _recentOrders = [
        {
          'id': 'order_001',
          'productName': 'Premium Basmati Rice',
          'quantity': 5,
          'unit': 'quintal',
          'pricePerUnit': 4200,
          'totalAmount': 21000,
          'buyerName': 'FreshMart Retail',
          'buyerLocation': 'Delhi, India',
          'orderDate': '2024-01-15',
          'status': 'delivered',
          'paymentStatus': 'paid',
          'productImage': 'assets/rice1.jpg',
        },
        {
          'id': 'order_002',
          'productName': 'Cotton Bales',
          'quantity': 3,
          'unit': 'quintal',
          'pricePerUnit': 5500,
          'totalAmount': 16500,
          'buyerName': 'Textile Mills Ltd.',
          'buyerLocation': 'Ahmedabad, India',
          'orderDate': '2024-01-14',
          'status': 'shipped',
          'paymentStatus': 'paid',
          'productImage': 'assets/cotton1.jpg',
        },
        {
          'id': 'order_003',
          'productName': 'Organic Vegetables',
          'quantity': 10,
          'unit': 'quintal',
          'pricePerUnit': 1200,
          'totalAmount': 12000,
          'buyerName': 'GreenGrocer Chain',
          'buyerLocation': 'Mumbai, India',
          'orderDate': '2024-01-13',
          'status': 'processing',
          'paymentStatus': 'pending',
          'productImage': 'assets/vegetables1.jpg',
        },
        {
          'id': 'order_004',
          'productName': 'Sugarcane',
          'quantity': 20,
          'unit': 'quintal',
          'pricePerUnit': 320,
          'totalAmount': 6400,
          'buyerName': 'Sugar Factory Co.',
          'buyerLocation': 'Uttar Pradesh, India',
          'orderDate': '2024-01-12',
          'status': 'pending',
          'paymentStatus': 'pending',
          'productImage': 'assets/sugarcane1.jpg',
        },
      ];
      _inventoryItems = [
        {
          'id': 'inv_001',
          'name': 'Premium Basmati Rice',
          'category': 'Grains & Cereals',
          'quantity': 45,
          'unit': 'quintal',
          'price': 4200,
          'isOrganic': true,
          'productImage': 'assets/rice1.jpg',
          'lowStock': false,
        },
        {
          'id': 'inv_002',
          'name': 'Cotton Bales',
          'category': 'Cash Crops',
          'quantity': 12,
          'unit': 'quintal',
          'price': 5500,
          'isOrganic': true,
          'productImage': 'assets/cotton1.jpg',
          'lowStock': false,
        },
        {
          'id': 'inv_003',
          'name': 'Organic Vegetables',
          'category': 'Vegetables',
          'quantity': 8,
          'unit': 'quintal',
          'price': 1200,
          'isOrganic': true,
          'productImage': 'assets/vegetables1.jpg',
          'lowStock': true,
        },
        {
          'id': 'inv_004',
          'name': 'Sugarcane',
          'category': 'Cash Crops',
          'quantity': 65,
          'unit': 'quintal',
          'price': 320,
          'isOrganic': false,
          'productImage': 'assets/sugarcane1.jpg',
          'lowStock': false,
        },
        {
          'id': 'inv_005',
          'name': 'Hybrid Seeds - Maize',
          'category': 'Seeds & Fertilizers',
          'quantity': 120,
          'unit': 'packet',
          'price': 850,
          'isOrganic': false,
          'productImage': 'assets/seeds1.jpg',
          'lowStock': false,
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
              child: KisanAppBar(
                title: 'Supplier Dashboard',
                showSearch: false,
              ),
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
                          ResponsiveGridList(
                            desiredItemWidth: 160,
                            minSpacing: 16,
                            children: [
                              _buildStatCard(
                                'Monthly Sales',
                                '₹${_formatNumber(_monthlySales)}',
                                Icons.trending_up,
                                AppColors.accentGreen,
                              ),
                              _buildStatCard(
                                'Active Listings',
                                '$_activeListings',
                                Icons.inventory,
                                AppColors.infoBlue,
                              ),
                              _buildStatCard(
                                'Customer Rating',
                                '${_averageRating.toStringAsFixed(1)}★',
                                Icons.star,
                                Colors.amber,
                              ),
                              _buildStatCard(
                                'Inventory Items',
                                '${_inventoryItems.length}',
                                Icons.layers,
                                AppColors.warningAmber,
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Recent Orders',
                              style: AppTypography.titleMedium,
                            ),
                          ),
                          SizedBox(height: 12),
                          _recentOrders.isEmpty
                              ? Center(
                                  child: Text(
                                    'No recent orders',
                                    style: AppTypography.bodyLarge,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentOrders.length,
                                  itemBuilder: (context, index) =>
                                      _buildOrderCard(_recentOrders[index]),
                                ),
                          SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Inventory Management',
                              style: AppTypography.titleMedium,
                            ),
                          ),
                          SizedBox(height: 12),
                          _inventoryItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No inventory items',
                                    style: AppTypography.bodyLarge,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _inventoryItems.length,
                                  itemBuilder: (context, index) =>
                                      _buildInventoryCard(
                                        _inventoryItems[index],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new inventory item')),
          );
        },
        label: Text('Add Inventory'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
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
                : order['paymentStatus'] == 'pending'
                ? AppColors.warningAmber
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order['quantity']} ${order['unit']}',
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: 4),
            Text(
              'Buyer: ${order['buyerName']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '📍 ${order['buyerLocation']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
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
              '₹${order['totalAmount'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: order['status'] == 'cancelled'
                    ? AppColors.dangerRed
                    : order['status'] == 'delivered'
                    ? AppColors.accentGreen
                    : order['paymentStatus'] == 'paid'
                    ? AppColors.textPrimary
                    : AppColors.warningAmber,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order['status']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getStatusLabel(order['status']),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(order['status']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item['lowStock']
            ? AppColors.warningAmber.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item['lowStock']
              ? AppColors.warningAmber
              : AppColors.borderSubtle,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item['productImage'] as String,
                width: 50,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            if (item['lowStock'])
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Text(
          item['name'] as String,
          style: AppTypography.titleMedium.copyWith(
            color: item['lowStock']
                ? AppColors.warningAmber
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item['category']}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Stock: ${item['quantity']} ${item['unit']}',
              style: TextStyle(
                fontSize: 12,
                color: item['lowStock']
                    ? AppColors.warningAmber
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Price: ₹${item['price']}/${item['unit']}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: item['isOrganic']
                    ? AppColors.accentGreen
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.accentGreen),
              onPressed: () {
                // TODO: Edit inventory item
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit item'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
            ),
            SizedBox(height: 4),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: item['lowStock']
                    ? AppColors.warningAmber
                    : AppColors.dangerRed,
              ),
              onPressed: () {
                // TODO: Delete inventory item
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete item'),
                    backgroundColor: item['lowStock']
                        ? AppColors.warningAmber
                        : AppColors.dangerRed,
                  ),
                );
              },
            ),
          ],
        ),
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

// Helper class for responsive grid layout
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
