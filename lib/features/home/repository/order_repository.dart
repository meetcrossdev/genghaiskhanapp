import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/ordermodal.dart';


final orderRepositoryProvider = Provider(
  (ref) => OrderRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

class OrderRepository {
  final FirebaseFirestore _firebaseFirestore;
  OrderRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _ordersCollection =>
      _firebaseFirestore.collection(FirebaseConstants.ordersCollection);

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
      }).whereType<OrderModel>().toList();
    });
  }

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
      }).whereType<OrderModel>().toList();
    });
  }
}
