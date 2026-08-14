import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart item model
class CartItem {
  final String id;
  final String productId;
  final String title;
  final String seller;
  final double price;
  final String unit;
  int quantity;
  final double? discount;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.seller,
    required this.price,
    required this.unit,
    required this.quantity,
    this.discount,
  });

  /// Calculate total price for this item
  double getTotalPrice() {
    double total = price * quantity;
    if (discount != null && discount! > 0) {
      total -= (total * discount! / 100);
    }
    return total;
  }

  /// Copy with modified fields
  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? seller,
    double? price,
    String? unit,
    int? quantity,
    double? discount,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      seller: seller ?? this.seller,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  String toString() => 'CartItem(id: $id, title: $title, qty: $quantity)';
}

/// Cart state model
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  CartState({this.items = const [], this.isLoading = false, this.error});

  /// Get total items count
  int getItemCount() => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get unique product count
  int getUniqueItemCount() => items.length;

  /// Calculate total price
  double getTotalPrice() =>
      items.fold(0, (sum, item) => sum + item.getTotalPrice());

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Copy with modified fields
  CartState copyWith({List<CartItem>? items, bool? isLoading, String? error}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Cart notifier for managing cart state
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  /// Add item to cart
  void addToCart({
    required String productId,
    required String title,
    required String seller,
    required double price,
    required String unit,
    int quantity = 1,
    double? discount,
  }) {
    final existingItemIndex = state.items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingItemIndex >= 0) {
      // Item exists, increase quantity
      final updatedItems = [...state.items];
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex]
          .copyWith(
            quantity: updatedItems[existingItemIndex].quantity + quantity,
          );
      state = state.copyWith(items: updatedItems);
    } else {
      // New item, add to cart
      final newItem = CartItem(
        id: '${productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        title: title,
        seller: seller,
        price: price,
        unit: unit,
        quantity: quantity,
        discount: discount,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  /// Remove item from cart
  void removeFromCart(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  /// Update item quantity
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Clear entire cart
  void clearCart() {
    state = CartState();
  }

  /// Get item by ID
  CartItem? getItem(String itemId) {
    try {
      return state.items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Check if item exists in cart
  bool hasItem(String productId) {
    return state.items.any((item) => item.productId == productId);
  }

  /// Get quantity of an item
  int getQuantity(String productId) {
    try {
      final item = state.items.firstWhere(
        (item) => item.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}

/// Provider for cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// Provider for cart item count
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.getItemCount();
});

/// Provider for unique item count
final uniqueCartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.getUniqueItemCount();
});

/// Provider for cart total price
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.getTotalPrice();
});

/// Provider for checking if item in cart
final isItemInCartProvider = Provider.family<bool, String>((ref, productId) {
  final cart = ref.watch(cartProvider);
  return cart.items.any((item) => item.productId == productId);
});

/// Provider for getting item quantity
final itemQuantityProvider = Provider.family<int, String>((ref, productId) {
  final cart = ref.watch(cartProvider);
  try {
    final item = cart.items.firstWhere((item) => item.productId == productId);
    return item.quantity;
  } catch (e) {
    return 0;
  }
});
