

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/cart.dart';

// Provider to create and expose CartRepository with Firestore dependency via Riverpod
final cartRepositoryProvider = Provider(
  (ref) => CartRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

// Repository class responsible for handling cart operations in Firestore
class CartRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor with required FirebaseFirestore injection
  CartRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // FirebaseAuth instance to access current user if needed
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Private method to get the cart collection reference for a specific user
  CollectionReference _cart(String userId) => _firebaseFirestore
      .collection('users')
      .doc(userId)
      .collection('cart');

  /// Adds an item to the user's cart
  /// If the item already exists, it merges with the existing one (helpful for quantity updates)
  FutureVoid addToCart(CartItemModel cartItem) async {
    try {
      return right(
        _cart(cartItem.userId)
            .doc(cartItem.productName) // Using product name as the document ID
            .set(
              cartItem.toMap(cartItem.productId),
              SetOptions(merge: true), // Merge fields if the doc already exists
            ),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to add item to cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Removes a cart item using user ID and product ID (document ID)
  FutureVoid removeFromCart(String userId, String productId) async {
    try {
      return right(_cart(userId).doc(productId).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to remove item from cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Updates the quantity of an existing item in the cart
  FutureVoid updateCartItemQuantity(
    String userId,
    String productName,
    int quantity,
  ) async {
    try {
      return right(
        _cart(userId).doc(productName).update({'quantity': quantity}),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to update quantity.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Returns a stream of cart items for the specified user
  /// Useful for real-time updates on cart contents
  Stream<List<CartItemModel>> getUserCart(String userId) {
    return _cart(userId)
        .snapshots()
        .map((event) => event.docs
            .map((e) =>
                CartItemModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  /// Clears all items from the user's cart
  /// Deletes each document in the user's cart subcollection
  FutureVoid clearCart(String userId) async {
    try {
      final snapshot = await _cart(userId).get(); // Get all cart documents
      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // Delete each cart item
      }
      return right(null); // Indicate success
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to clear cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
