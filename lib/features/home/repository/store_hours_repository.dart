import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/constant/firebase_constants.dart' show FirebaseConstants;
import '../../../core/failure.dart';
import '../../../core/provider/firebase_provider.dart';
import '../../../core/type_dfs.dart';
import '../../../models/store_hours.dart';

const String storeId = "default_store";
final storeHourRepositoryProvider = Provider(
  (ref) => StoreHourRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

class StoreHourRepository {
  final FirebaseFirestore _firebaseFirestore;

  StoreHourRepository({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _storeHours =>
      _firebaseFirestore.collection(FirebaseConstants.storeHoursCollection);

  FutureVoid updateStoreHours(String storeId, List<StoreHour> hours) async {
    try {
      List<Map<String, dynamic>> hoursMap =
          hours.map((hour) => hour.toMap()).toList();
      return right(await _storeHours.doc(storeId).set({'hours': hoursMap}));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to update store hours"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateStoreLive(bool isLive) async {
    try {
      return right(
        await _storeHours.doc('store-status').set({'isLive': isLive}),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to update store status"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<StoreHour>> fetchStoreHours(String storeId) {
    return _storeHours.doc(storeId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> hoursList = data['hours'] ?? [];
      return hoursList.map((e) => StoreHour.fromMap(e)).toList();
    });
  }

  Stream<bool> fetchStoreStatus() {
    return FirebaseFirestore.instance
        .collection('hours')
        .doc('store-status')
        .snapshots()
        .map((snapshot) => snapshot.data()?['isLive'] as bool? ?? false);
  }

  // ✅ Add Holiday Date to Firestore
  FutureVoid addHoliday(DateTime holidayDate) async {
    try {
      String formattedDate = holidayDate.toIso8601String();
      return right(
        await _storeHours.doc(storeId).set({
          'holidays': FieldValue.arrayUnion([formattedDate]),
        }, SetOptions(merge: true)),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to add holiday"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ✅ Remove Holiday Date from Firestore
  FutureVoid removeHoliday(DateTime holidayDate) async {
    try {
      String formattedDate = holidayDate.toIso8601String();
      return right(
        await _storeHours.doc(storeId).update({
          'holidays': FieldValue.arrayRemove([formattedDate]),
        }),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to remove holiday"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // ✅ Fetch Holiday Hours Stream
  Stream<List<DateTime>> fetchHolidays() {
    return _storeHours.doc(storeId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> holidaysList = data['holidays'] ?? [];
      return holidaysList.map((e) => DateTime.parse(e as String)).toList();
    });
  }
}
