import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/ordermodal.dart';


// Provider to expose OrderRepository via Riverpod
final orderRepositoryProvider = Provider(
  (ref) => OrderRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

// Repository for handling Firestore operations related to orders
class OrderRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor to inject Firestore dependency
  OrderRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Reference to the 'orders' collection in Firestore
  CollectionReference get _ordersCollection =>
      _firebaseFirestore.collection(FirebaseConstants.ordersCollection);

  /// Places a new order by creating a document in the 'orders' collection
  /// Uses the order's ID as the Firestore document ID
  FutureVoid placeOrder(OrderModel order) async {
    try {
      return right(
        _ordersCollection.doc(order.id).set(order.toMap()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Updates the status of an existing order
  /// If the status is 'delivered', also sets the `completedAt` timestamp
  FutureVoid updateOrderStatus(String orderId, String status) async {
    try {
      return right(
        _ordersCollection.doc(orderId).update({
          'status': status,
          'completedAt': status == 'delivered' ? Timestamp.now() : null,
        }),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Fetches orders for a specific user in real time as a stream
  /// Filters documents where 'userId' matches
  Stream<List<OrderModel>> fetchUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return OrderModel.fromMap(data);
        } catch (error) {
          print("Error parsing order: ${doc.id}, Error: $error");
          return null;
        }
      }).whereType<OrderModel>().toList(); // Filters out null values
    });
  }

  /// Fetches all orders in real time as a stream (for admin use)
  Stream<List<OrderModel>> fetchAllOrders() {
    return _ordersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return OrderModel.fromMap(data);
        } catch (error) {
          print("Error parsing order: ${doc.id}, Error: $error");
          return null;
        }
      }).whereType<OrderModel>().toList(); // Filters out null values
    });
  }
}
