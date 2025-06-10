import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/utility.dart';

import '../../../models/cart.dart';
import '../repository/cart_repository.dart';

// StreamProvider for fetching a user's cart items by userId
final cartProvider = StreamProvider.family<List<CartItemModel>, String>(
  (ref, userId) => ref.watch(cartControllerProvider.notifier).getUserCart(userId),
);

// StreamProvider for getting the tax value from Firestore settings
final taxStreamProvider = StreamProvider<double>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('tax')
      .snapshots()
      .map((doc) => (doc.data()?['value'] ?? 0.0).toDouble());
});

// Provider to calculate total cart price for a given userId
final cartTotalProvider = Provider.family<double, String>((ref, userId) {
  final cartItems = ref.watch(cartProvider(userId)).maybeWhen(
        data: (items) => items,
        orElse: () => [],
      );

  // Sum up total price = price * quantity
  double total = cartItems.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );
  return total;
});

// StateNotifierProvider for CartController with a loading state (bool)
final cartControllerProvider = StateNotifierProvider<CartController, bool>(
  (ref) => CartController(
    cartRepository: ref.watch(cartRepositoryProvider),
    ref: ref,
  ),
);

class CartController extends StateNotifier<bool> {
  final CartRepository _cartRepository;
  final Ref _ref;

  CartController({required CartRepository cartRepository, required Ref ref})
      : _cartRepository = cartRepository,
        _ref = ref,
        super(false); // initial state: not loading

  /// Add an item to the cart
  void addToCart({
    required CartItemModel cartItem,
    required BuildContext context,
  }) async {
    state = true; // loading
    final res = await _cartRepository.addToCart(cartItem);
    state = false; // done

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, 'Item added to cart successfully'),
    );
  }

  /// Remove an item from the cart by userId and productId
  void removeFromCart({
    required String userId,
    required String productId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.removeFromCart(userId, productId);
    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, 'Item removed from cart'),
    );
  }

  /// Update quantity of a cart item
  void updateCartItemQuantity({
    required String userId,
    required String productName,
    required int quantity,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.updateCartItemQuantity(
      userId,
      productName,
      quantity,
    );
    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => {},
    );
  }

  /// Stream of cart items for a user
  Stream<List<CartItemModel>> getUserCart(String userId) {
    return _cartRepository.getUserCart(userId);
  }

  /// Clear all items from the user's cart
  void clearCart({
    required String userId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.clearCart(userId);
    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => {},
    );
  }
}
