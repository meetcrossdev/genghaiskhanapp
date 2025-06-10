import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';
import 'package:gzresturent/models/refund_request.dart';

// Provider to inject RefundRepository with Firestore dependency
final refundRepositoryProvider = Provider(
  (ref) => RefundRepository(firestore: ref.watch(firestoreProvider)),
);

class RefundRepository {
  final FirebaseFirestore _firestore;

  // Constructor injecting FirebaseFirestore instance
  RefundRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Reference to the refund requests collection in Firestore
  CollectionReference get _refundCollection =>
      _firestore.collection(FirebaseConstants.refundRequestsCollection);

  /// Submits a refund request by saving it to Firestore
  /// Returns a FutureVoid with success or failure wrapped in Either type
  FutureVoid submitRefundRequest(RefundRequest refund) async {
    try {
      // Use document ID from refund object as Firestore doc ID
      await _refundCollection.doc(refund.id).set(refund.toMap());
      return right(null); // success, no value to return
    } on FirebaseException catch (e) {
      // Return failure with Firebase-specific error message
      return left(Failure(e.message ?? "Failed to submit refund request"));
    } catch (e) {
      // Return failure with generic error message
      return left(Failure(e.toString()));
    }
  }

  /// Streams a list of refund requests for a specific user
  /// Returns real-time updates from Firestore as a List<RefundRequest>
  Stream<List<RefundRequest>> fetchUserRefunds(String userId) {
    return _refundCollection
        .where('userId', isEqualTo: userId) // Filter refunds by userId
        .snapshots() // Real-time updates from Firestore collection
        .map((snapshot) {
      // Map each Firestore document to RefundRequest model
      return snapshot.docs.map(
        (doc) => RefundRequest.fromMap(doc.data() as Map<String, dynamic>),
      ).toList();
    });
  }
}
