import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';
import 'package:gzresturent/models/refund_request.dart';

final refundRepositoryProvider = Provider(
  (ref) => RefundRepository(firestore: ref.watch(firestoreProvider)),
);

class RefundRepository {
  final FirebaseFirestore _firestore;

  RefundRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _refundCollection =>
      _firestore.collection(FirebaseConstants.refundRequestsCollection);

  FutureVoid submitRefundRequest(RefundRequest refund) async {
    try {
      await _refundCollection.doc(refund.id).set(refund.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to submit refund request"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<RefundRequest>> fetchUserRefunds(String userId) {
    return _refundCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(
        (doc) => RefundRequest.fromMap(doc.data() as Map<String, dynamic>)
      ).toList();
    });
  }
}
