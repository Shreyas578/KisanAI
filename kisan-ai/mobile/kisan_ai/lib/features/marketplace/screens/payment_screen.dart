import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/features/order/services/order_service.dart';
import 'package:kisan_ai/shared/models/order_model.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String productName;
  final int quantity;
  final String listingId;

  const PaymentScreen({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.productName,
    required this.quantity,
    required this.listingId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late TextEditingController _upiIdController;
  bool _agreeToTerms = false;
  
  @override
  void initState() {
    super.initState();
    _upiIdController = TextEditingController();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  void _initializePayment() {
    if (_upiIdController.text.isEmpty || !_upiIdController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID (e.g., name@okbank)'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            orderId: widget.orderId,
            buyerId: widget.buyerId,
            sellerId: widget.sellerId,
            listingId: widget.listingId,
            amount: widget.amount,
            productName: widget.productName,
            quantity: widget.quantity,
            upiId: _upiIdController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KisanAppBar(title: 'Secure UPI Payment'),
                const SizedBox(height: 24),

                // Payment Summary
                _buildPaymentSummary(),
                const SizedBox(height: 24),

                // UPI Address Input
                _buildUPIInput(),
                const SizedBox(height: 24),

                // Blockchain Info (Backend)
                _buildBlockchainInfo(),
                const SizedBox(height: 24),

                // Terms Agreement
                _buildTermsCheckbox(),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: KisanButton(
                    text: 'Pay ₹${widget.amount.toStringAsFixed(2)}',
                    isPrimary: true,
                    onPressed: _agreeToTerms && _upiIdController.text.isNotEmpty
                        ? _initializePayment
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Product', widget.productName),
          const SizedBox(height: 12),
          _buildSummaryRow('Quantity', '${widget.quantity} units'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Price per Unit',
            '₹${(widget.amount / widget.quantity).toStringAsFixed(2)}',
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            'Total Amount',
            '₹${widget.amount.toStringAsFixed(2)}',
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLarge = false,
    bool isGreen = false,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isLarge
                  ? AppTypography.titleLarge
                  : isBold
                      ? AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : AppTypography.bodyMedium,
            ),
            Text(
              value,
              style: isLarge
                  ? AppTypography.titleLarge.copyWith(
                      color: isGreen
                          ? AppColors.accentGreen
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    )
                  : isBold
                      ? AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : AppTypography.bodyMedium,
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUPIInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPI Details',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your UPI ID to simulate payment',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _upiIdController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'example@upi',
            prefixIcon: const Icon(Icons.payment),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildBlockchainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(Icons.security, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Web3 Audited Transaction',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'After this UPI payment completes, Kisan AI will automatically generate an IPFS receipt and record the transaction on the Sepolia Blockchain using our secure backend wallet. No crypto required from you!',
            style: AppTypography.bodySmall.copyWith(color: Colors.blue.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: AppColors.accentGreen,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Text(
              'I agree to process this simulated payment.',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Payment Confirmation Screen
class PaymentConfirmationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final double amount;
  final String productName;
  final int quantity;
  final String upiId;

  const PaymentConfirmationScreen({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.amount,
    required this.productName,
    required this.quantity,
    required this.upiId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends ConsumerState<PaymentConfirmationScreen> {
  bool _isLoading = true;
  String? _error;
  Order? _completedOrder;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      final apiClient = await ref.read(marketplaceApiClientProvider.future);
      final orderService = OrderService(apiClient);

      final newOrder = Order(
        id: const Uuid().v4(),
        buyerId: widget.buyerId,
        sellerId: widget.sellerId,
        listingId: widget.listingId,
        productName: widget.productName,
        quantity: widget.quantity.toDouble(),
        unit: 'unit', // Simplified for demo
        pricePerUnit: widget.amount / widget.quantity,
        totalAmount: widget.amount,
        currency: 'INR',
        orderDate: DateTime.now(),
        status: 'placed',
        paymentStatus: 'paid',
        paymentMethod: 'upi',
        deliveryAddress: 'Default Address',
        trackingNumber: '',
        statusHistory: ['placed'],
      );

      final result = await orderService.createOrder(newOrder);

      if (mounted) {
        setState(() {
          _completedOrder = result;
          _isLoading = false;
        });
        
        // Invalidate the marketplace listings so the UI reflects the deducted stock
        ref.invalidate(marketplaceListingsProvider);
        ref.invalidate(userMarketplaceListingsProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.accentGreen),
              const SizedBox(height: 16),
              Text(
                'Processing UPI Payment...',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please do not close this screen',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.dangerRed),
                const SizedBox(height: 16),
                Text('Payment Failed', style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.accentGreen,
              ),
              const SizedBox(height: 16),
              Text('Payment Successful!', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Your order has been confirmed',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfirmationRow(
                      'Order ID',
                      _completedOrder?.id ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationRow(
                      'Amount Paid',
                      '₹${widget.amount}',
                    ),
                    const SizedBox(height: 12),
                    if (_completedOrder?.transactionHash != null)
                      _buildConfirmationRow(
                        'Blockchain TX',
                        _completedOrder!.transactionHash!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
