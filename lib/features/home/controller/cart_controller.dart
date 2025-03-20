import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/utility.dart';

import '../../../models/cart.dart';
import '../repository/cart_repository.dart';


final cartProvider = StreamProvider.family<List<CartItemModel>, String>(
  (ref, userId) => ref.watch(cartControllerProvider.notifier).getUserCart(userId),
);

final cartTotalProvider = Provider.family<double, String>((ref, userId) {
  final cartItems = ref.watch(cartProvider(userId)).maybeWhen(
    data: (items) => items,
    orElse: () => [],
  );

  double total = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  return total;
});


final cartControllerProvider =
    StateNotifierProvider<CartController, bool>(
  (ref) => CartController(
    cartRepository: ref.watch(cartRepositoryProvider),
    ref: ref,
  ),
);

class CartController extends StateNotifier<bool> {
  final CartRepository _cartRepository;
  final Ref _ref;
  CartController({
    required CartRepository cartRepository,
    required Ref ref,
  })  : _cartRepository = cartRepository,
        _ref = ref,
        super(false);

  void addToCart({
    required CartItemModel cartItem,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.addToCart(cartItem);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Item added to cart successfully'),
    );
  }

  void removeFromCart({
    required String userId,
    required String productId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.removeFromCart(userId, productId);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Item removed from cart'),
    );
  }

  void updateCartItemQuantity({
    required String userId,
    required String productName,
    required int quantity,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.updateCartItemQuantity(userId, productName, quantity);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Quantity updated successfully'),
    );
  }

  Stream<List<CartItemModel>> getUserCart(String userId) {
    return _cartRepository.getUserCart(userId);
  }

  void clearCart({
    required String userId,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _cartRepository.clearCart(userId);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => {},
    );
  }
}
