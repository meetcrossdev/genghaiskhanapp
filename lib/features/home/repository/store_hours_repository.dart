import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/constant/firebase_constants.dart' show FirebaseConstants;
import '../../../core/failure.dart';
import '../../../core/provider/firebase_provider.dart';
import '../../../core/type_dfs.dart';
import '../../../models/store_hours.dart';

// Default store ID used in various methods
const String storeId = "default_store";

// Provider to inject StoreHourRepository with Firestore dependency
final storeHourRepositoryProvider = Provider(
  (ref) => StoreHourRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

class StoreHourRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor injecting FirebaseFirestore instance
  StoreHourRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Reference to the store hours collection in Firestore
  CollectionReference get _storeHours =>
      _firebaseFirestore.collection(FirebaseConstants.storeHoursCollection);

  /// Updates the store hours for the given store ID.
  /// Converts List<StoreHour> to List<Map> and writes it to Firestore.
  /// Returns FutureVoid with success or failure result.
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

  /// Updates the store live status (open/closed).
  /// Saves a boolean under the 'store-status' document.
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

  /// Fetches the store hours for the given store ID as a stream.
  /// Returns empty list if no data exists.
  Stream<List<StoreHour>> fetchStoreHours(String storeId) {
    return _storeHours.doc(storeId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> hoursList = data['hours'] ?? [];
      // Map Firestore data back to List<StoreHour>
      return hoursList.map((e) => StoreHour.fromMap(e)).toList();
    });
  }

  /// Fetches the live store status (isLive boolean) as a stream.
  /// Listens to the 'store-status' document in Firestore.
  Stream<bool> fetchStoreStatus() {
    return FirebaseFirestore.instance
        .collection('hours')
        .doc('store-status')
        .snapshots()
        .map((snapshot) => snapshot.data()?['isLive'] as bool? ?? false);
  }

  /// Adds a holiday date to the store's holiday list in Firestore.
  /// Uses FieldValue.arrayUnion to add without overwriting existing dates.
  FutureVoid addHoliday(DateTime holidayDate) async {
    try {
      String formattedDate = holidayDate.toIso8601String();
      return right(
        await _storeHours.doc(storeId).set({
          'holidays': FieldValue.arrayUnion([formattedDate]),
        }, SetOptions(merge: true)), // Merge with existing document
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to add holiday"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Removes a holiday date from the store's holiday list in Firestore.
  /// Uses FieldValue.arrayRemove to remove the date.
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

  /// Fetches the list of holiday dates as a stream of List<DateTime>.
  /// Returns an empty list if no data or document exists.
  Stream<List<DateTime>> fetchHolidays() {
    return _storeHours.doc(storeId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> holidaysList = data['holidays'] ?? [];
      // Parse string dates back into DateTime objects
      return holidaysList.map((e) => DateTime.parse(e as String)).toList();
    });
  }
}
