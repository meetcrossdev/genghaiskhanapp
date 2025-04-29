import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/models/times_slot.dart';

import '../../../core/constant/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/provider/firebase_provider.dart';
import '../../../core/type_dfs.dart';
import '../../../models/reservation.dart';

final reservationRepositoryProvider = Provider(
  (ref) => ReservationRepository(firestore: ref.watch(firestoreProvider)),
);

class ReservationRepository {
  final FirebaseFirestore _firestore;

  ReservationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _reservationsCollection =>
      _firestore.collection(FirebaseConstants.reservationCollection);

  CollectionReference get _timeSlotsCollection =>
      _firestore.collection(FirebaseConstants.timeSlotsCollection);

  /// ✅ Add a new reservation
  FutureVoid addReservation(Reservation reservation) async {
    try {
      log('adding reservation ');
      await _reservationsCollection
          .doc(reservation.id)
          .set(reservation.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to add reservation"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// ✅ Fetch all reservations for a restaurant
  Stream<List<Reservation>> fetchReservations(String restaurantId) {
    return _reservationsCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Reservation.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  /// ✅ Fetch reservations for a specific user
  Stream<List<Reservation>> fetchUserReservations(String userId) {
    return _reservationsCollection
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Reservation.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  /// ✅ Update reservation status (Confirmed, Cancelled, etc.)
  FutureVoid updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    try {
      await _reservationsCollection.doc(reservationId).update({
        'status': status,
      });
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to update reservation status"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteReservation(String reservationId) async {
    try {
      await _reservationsCollection.doc(reservationId).delete();
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to delete reservation"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// ✅ Fetch all time slots
  Stream<List<TimeSlot>> fetchTimeSlots() {
    return _timeSlotsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                TimeSlot.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }
}
