import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/marketplace/models/cart_models.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('🛒 Your Cart'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, ref, cartState, totalPrice),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the marketplace',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          KisanButton(
            text: 'Continue Shopping',
            onPressed: () {
              Navigator.of(context).pop();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    dynamic cartState,
    double totalPrice,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];
              return ListTile(
                title: Text(item.title ?? 'Product'),
                subtitle: Text('₹${item.price ?? 0}'),
                trailing: Text('Qty: ${item.quantity}'),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTypography.labelLarge),
                  Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KisanButton(
                text: 'Proceed to Checkout',
                onPressed: () {
                  // TODO: Implement checkout
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
