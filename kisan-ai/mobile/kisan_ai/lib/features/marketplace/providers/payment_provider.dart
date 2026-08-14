import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Payment Model
class Payment {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final String status;
  final String? transactionHash;
  final int? blockNumber;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionHash,
    this.blockNumber,
    required this.createdAt,
    this.confirmedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USDC',
      status: json['status'] ?? 'pending',
      transactionHash: json['transactionHash'],
      blockNumber: json['blockNumber'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
    );
  }
}

/// Wallet Model
class Wallet {
  final String address;
  final String type; // 'metamask', 'wallet_connect', etc
  final bool isVerified;
  final DateTime connectedAt;

  Wallet({
    required this.address,
    required this.type,
    required this.isVerified,
    required this.connectedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      address: json['walletAddress'] ?? '',
      type: json['walletType'] ?? 'metamask',
      isVerified: json['isVerified'] ?? false,
      connectedAt: DateTime.parse(
        json['connectedAt'] ?? DateTime.now().toString(),
      ),
    );
  }
}

/// Payment Service
class PaymentService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Initialize payment for an order
  Future<Payment> initializePayment({
    required String orderId,
    required String buyerId,
    required String sellerId,
    required double amount,
    required String currency,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/initialize');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'orderId': orderId,
              'buyerId': buyerId,
              'sellerId': sellerId,
              'amount': amount,
              'currency': currency,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Payment initialization timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data']);
      } else {
        throw Exception('Failed to initialize payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment initialization error: $e');
    }
  }

  /// Process blockchain payment
  /// Backend handles all gas fees - farmer just provides wallet
  Future<Payment> processPayment({
    required String paymentId,
    required String buyerWalletAddress,
    required String sellerWalletAddress,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/process');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'paymentId': paymentId,
              'buyerWalletAddress': buyerWalletAddress,
              'sellerWalletAddress': sellerWalletAddress,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception('Payment processing timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data']);
      } else {
        throw Exception('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment processing error: $e');
    }
  }

  /// Get payment status
  Future<Payment> getPaymentStatus(String paymentId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/$paymentId');
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Get payment status timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data['data']);
      } else {
        throw Exception('Failed to get payment status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get payment status error: $e');
    }
  }

  /// Verify transaction on blockchain
  Future<Map<String, dynamic>> verifyTransaction(String txHash) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/verify/$txHash');
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Verify transaction timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to verify transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verify transaction error: $e');
    }
  }

  /// Request refund
  Future<Map<String, dynamic>> requestRefund({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/refund');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'paymentId': paymentId, 'reason': reason}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Refund request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to request refund: ${response.body}');
      }
    } catch (e) {
      throw Exception('Refund request error: $e');
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String walletAddress) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/payments/wallet/balance/$walletAddress',
      );
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Get wallet balance timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return double.parse(data['data']['balance']?.toString() ?? '0');
      } else {
        throw Exception('Failed to get wallet balance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get wallet balance error: $e');
    }
  }

  /// Estimate gas fees
  Future<Map<String, dynamic>> estimateGas(double amount) async {
    try {
      final uri = Uri.parse('$baseUrl/api/payments/estimate-gas');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'amount': amount}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Estimate gas timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to estimate gas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Estimate gas error: $e');
    }
  }

  /// Store wallet address locally
  Future<void> saveWalletAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_wallet_address', address);
  }

  /// Retrieve saved wallet address
  Future<String?> getStoredWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_wallet_address');
  }

  /// Clear stored wallet address
  Future<void> clearStoredWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_wallet_address');
  }
}

/// Payment Service Provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

/// Initialize Payment State
class InitializePaymentState {
  final bool isLoading;
  final Payment? payment;
  final String? error;

  InitializePaymentState({this.isLoading = false, this.payment, this.error});

  InitializePaymentState copyWith({
    bool? isLoading,
    Payment? payment,
    String? error,
  }) {
    return InitializePaymentState(
      isLoading: isLoading ?? this.isLoading,
      payment: payment ?? this.payment,
      error: error ?? this.error,
    );
  }
}

/// Initialize Payment Notifier
class InitializePaymentNotifier extends StateNotifier<InitializePaymentState> {
  final PaymentService _paymentService;

  InitializePaymentNotifier(this._paymentService)
    : super(InitializePaymentState());

  Future<void> initializePayment({
    required String orderId,
    required String buyerId,
    required String sellerId,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payment = await _paymentService.initializePayment(
        orderId: orderId,
        buyerId: buyerId,
        sellerId: sellerId,
        amount: amount,
        currency: currency,
      );
      state = state.copyWith(isLoading: false, payment: payment);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Initialize Payment Provider
final initializePaymentProvider =
    StateNotifierProvider<InitializePaymentNotifier, InitializePaymentState>((
      ref,
    ) {
      final paymentService = ref.watch(paymentServiceProvider);
      return InitializePaymentNotifier(paymentService);
    });

/// Process Payment State
class ProcessPaymentState {
  final bool isLoading;
  final Payment? payment;
  final String? error;
  final double? gasEstimate;

  ProcessPaymentState({
    this.isLoading = false,
    this.payment,
    this.error,
    this.gasEstimate,
  });

  ProcessPaymentState copyWith({
    bool? isLoading,
    Payment? payment,
    String? error,
    double? gasEstimate,
  }) {
    return ProcessPaymentState(
      isLoading: isLoading ?? this.isLoading,
      payment: payment ?? this.payment,
      error: error ?? this.error,
      gasEstimate: gasEstimate ?? this.gasEstimate,
    );
  }
}

/// Process Payment Notifier
class ProcessPaymentNotifier extends StateNotifier<ProcessPaymentState> {
  final PaymentService _paymentService;

  ProcessPaymentNotifier(this._paymentService) : super(ProcessPaymentState());

  Future<void> processPayment({
    required String paymentId,
    required String buyerWalletAddress,
    required String sellerWalletAddress,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payment = await _paymentService.processPayment(
        paymentId: paymentId,
        buyerWalletAddress: buyerWalletAddress,
        sellerWalletAddress: sellerWalletAddress,
      );
      state = state.copyWith(isLoading: false, payment: payment);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> estimateGas(double amount) async {
    try {
      final estimate = await _paymentService.estimateGas(amount);
      final gasEstimateEth = double.parse(
        estimate['estimatedCostInEth']?.toString() ?? '0',
      );
      state = state.copyWith(gasEstimate: gasEstimateEth);
    } catch (e) {
      state = state.copyWith(error: 'Failed to estimate gas: $e');
    }
  }
}

/// Process Payment Provider
final processPaymentProvider =
    StateNotifierProvider<ProcessPaymentNotifier, ProcessPaymentState>((ref) {
      final paymentService = ref.watch(paymentServiceProvider);
      return ProcessPaymentNotifier(paymentService);
    });

/// Payment Status Provider
final paymentStatusProvider = FutureProvider.family<Payment, String>((
  ref,
  paymentId,
) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentStatus(paymentId);
});

/// Wallet Balance Provider
final walletBalanceProvider = FutureProvider.family<double, String>((
  ref,
  walletAddress,
) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getWalletBalance(walletAddress);
});
