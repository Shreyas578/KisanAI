import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/order/state/order_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/offline_banner.dart';
import 'package:kisan_ai/shared/models/order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedTabIndex =
      0; // 0: All, 1: Pending, 2: Confirmed, 3: Shipped, 4: Delivered, 5: Cancelled

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: const Text('Orders History'),
          backgroundColor: AppColors.surface,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Purchases'),
              Tab(text: 'Sales'),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOrdersList(ref, 'buyer'),
                    _buildOrdersList(ref, 'seller'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(WidgetRef ref, String role) {
    // Get user ID from auth/provider
    final authState = ref.read(authProvider).valueOrNull;
    final String userId = authState?.user?.id ?? 'current_user_id';

    final userOrdersAsync = ref.watch(
      userOrdersProvider('${userId}_$role'),
    );

    return userOrdersAsync.when(
      data: (orders) => _buildOrdersContent(orders, ref),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading orders: $error',
          style: TextStyle(color: AppColors.dangerRed),
        ),
      ),
    );
  }

  Widget _buildOrdersContent(List<Order> orders, WidgetRef ref) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    // Apply filter based on selected tab
    List<Order> filteredOrders = _filterOrdersByStatus(
      orders,
      _selectedTabIndex,
    );

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  List<Order> _filterOrdersByStatus(List<Order> orders, int tabIndex) {
    if (tabIndex == 0) return orders; // All

    switch (tabIndex) {
      case 1: // Pending
        return orders.where((order) => order.status == 'pending').toList();
      case 2: // Confirmed
        return orders.where((order) => order.status == 'confirmed').toList();
      case 3: // Processing
        return orders.where((order) => order.status == 'processing').toList();
      case 4: // Shipped
        return orders.where((order) => order.status == 'shipped').toList();
      case 5: // Delivered
        return orders.where((order) => order.status == 'delivered').toList();
      case 6: // Cancelled
        return orders.where((order) => order.status == 'cancelled').toList();
      default:
        return [];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('No orders yet', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Your buying and selling activity will appear here',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, int count) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentGreen.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.accentGreen
                      : AppColors.textSecondary,
                ),
              ),
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGreen
                        : AppColors.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? AppColors.primaryBackground
                          : AppColors.accentGreen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: order.status == 'cancelled'
            ? AppColors.dangerRed.withOpacity(0.05)
            : order.status == 'delivered'
            ? AppColors.accentGreen.withOpacity(0.05)
            : order.paymentStatus == 'pending'
            ? AppColors.warningAmber.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.status == 'cancelled'
              ? AppColors.dangerRed
              : order.status == 'completed' || order.status == 'delivered'
              ? AppColors.accentGreen
              : order.paymentStatus == 'pending'
              ? AppColors.warningAmber
              : AppColors.borderSubtle,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: order.productImages.isNotEmpty
              ? order.productImages[0].startsWith('http')
                    ? Image.network(
                        order.productImages[0],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
                      )
                    : Image.asset(
                        order.productImages[0],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
                      )
              : Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 40)),
        ),
        title: Text(
          order.productName,
          style: AppTypography.titleMedium.copyWith(
            color: order.status == 'cancelled'
                ? AppColors.dangerRed
                : order.status == 'completed' || order.status == 'delivered'
                ? AppColors.accentGreen
                : order.paymentStatus == 'pending'
                ? AppColors.warningAmber
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order.quantity} ${order.unit}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Buyer: ${order.buyerName}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '📍 ${order.buyerLocation}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${order.orderDate.toString().split(' ')[0]}',
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
              '₱${order.totalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: order.status == 'cancelled'
                    ? AppColors.dangerRed
                    : order.status == 'completed' || order.status == 'delivered'
                    ? AppColors.accentGreen
                    : order.paymentStatus == 'paid'
                    ? AppColors.textPrimary
                    : AppColors.warningAmber,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(order.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(order.status),
                ),
              ),
            ),
            if (order.status == 'cancelled' &&
                order.cancellationReason.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reason: ${order.cancellationReason}',
                  style: TextStyle(fontSize: 10, color: AppColors.dangerRed),
                ),
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to order detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Viewing order details...'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        },
      ),
      if (order.transactionHash != null || order.ipfsHash != null)
        Container(
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (order.transactionHash != null)
                TextButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('https://sepolia.etherscan.io/tx/${order.transactionHash}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Etherscan link.')));
                    }
                  },
                  icon: Icon(Icons.link, color: AppColors.infoBlue, size: 18),
                  label: Text('Etherscan', style: TextStyle(color: AppColors.infoBlue)),
                ),
              if (order.ipfsHash != null)
                TextButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('https://gateway.pinata.cloud/ipfs/${order.ipfsHash}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open IPFS link.')));
                    }
                  },
                  icon: Icon(Icons.receipt_long, color: AppColors.accentGreen, size: 18),
                  label: Text('IPFS Receipt', style: TextStyle(color: AppColors.accentGreen)),
                ),
            ],
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
      case 'completed':
        return 'Completed';
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
      case 'completed':
        return AppColors.accentGreen;
      case 'cancelled':
        return AppColors.dangerRed;
      default:
        return AppColors.textSecondary;
    }
  }
}
