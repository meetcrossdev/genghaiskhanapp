

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

final cartRepositoryProvider = Provider(
  (ref) => CartRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

// class CartRepository {
//   final FirebaseFirestore _firebaseFirestore;
//   CartRepository({required FirebaseFirestore firebaseFirestore})
//     : _firebaseFirestore = firebaseFirestore;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   CollectionReference get _cart => _firebaseFirestore
//       .collection('carts')
//       .doc(_auth.currentUser!.uid)
//       .collection('items');

//   FutureVoid addToCart(CartItemModel cartItem) async {
//     try {
//       return right(
//         _cart
//             .doc('${cartItem.userId}_${cartItem.productId}')
//             .set(
//               cartItem.toMap('${cartItem.userId}_${cartItem.productId}'),
//               SetOptions(merge: true),
//             ),
//       );
//     } on FirebaseException catch (e) {
//       return left(Failure(e.message ?? 'Failed to add item to cart.'));
//     } catch (e) {
//       return left(Failure(e.toString()));
//     }
//   }

//   FutureVoid removeFromCart(String userId, String productId) async {
//     try {
//       return right(_cart.doc('${userId}_$productId').delete());
//     } on FirebaseException catch (e) {
//       return left(Failure(e.message ?? 'Failed to remove item from cart.'));
//     } catch (e) {
//       return left(Failure(e.toString()));
//     }
//   }

//   FutureVoid updateCartItemQuantity(
//     String userId,
//     String productId,
//     int quantity,
//   ) async {
//     try {
//       return right(
//         _cart.doc('${userId}_$productId').update({'quantity': quantity}),
//       );
//     } on FirebaseException catch (e) {
//       return left(Failure(e.message ?? 'Failed to update quantity.'));
//     } catch (e) {
//       return left(Failure(e.toString()));
//     }
//   }

//   Stream<List<CartItemModel>> getUserCart(String userId) {
//     return _cart
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map(
//           (event) =>
//               event.docs
//                   .map(
//                     (e) =>
//                         CartItemModel.fromMap(e.data() as Map<String, dynamic>),
//                   )
//                   .toList(),
//         );
//   }

//   FutureVoid clearCart(String userId) async {
//     try {
//       final snapshot = await _cart.where('userId', isEqualTo: userId).get();
//       for (var doc in snapshot.docs) {
//         await doc.reference.delete();
//       }
//       return right(null);
//     } on FirebaseException catch (e) {
//       return left(Failure(e.message ?? 'Failed to clear cart.'));
//     } catch (e) {
//       return left(Failure(e.toString()));
//     }
//   }
// }



class CartRepository {
  final FirebaseFirestore _firebaseFirestore;
  CartRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get reference to the user's cart collection
  CollectionReference _cart(String userId) => _firebaseFirestore
      .collection('users')
      .doc(userId)
      .collection('cart');

  /// Add item to cart
  FutureVoid addToCart(CartItemModel cartItem) async {
    try {
      return right(
        _cart(cartItem.userId)
            .doc(cartItem.productName) // Product ID as doc ID
            .set(cartItem.toMap(cartItem.productId), SetOptions(merge: true)),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to add item to cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Remove item from cart
  FutureVoid removeFromCart(String userId, String productId) async {
    try {
      return right(_cart(userId).doc(productId).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to remove item from cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Update cart item quantity
  FutureVoid updateCartItemQuantity(
      String userId, String productName, int quantity) async {
    try {
      return right(_cart(userId).doc(productName).update({'quantity': quantity}));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to update quantity.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Get user's cart as a stream
  Stream<List<CartItemModel>> getUserCart(String userId) {
    return _cart(userId)
        .snapshots()
        .map((event) => event.docs
            .map((e) => CartItemModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  /// Clear all items from user's cart
  FutureVoid clearCart(String userId) async {
    try {
      final snapshot = await _cart(userId).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Failed to clear cart.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
