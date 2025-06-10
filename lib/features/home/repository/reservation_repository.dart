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

// Provider to expose ReservationRepository via Riverpod
final reservationRepositoryProvider = Provider(
  (ref) => ReservationRepository(firestore: ref.watch(firestoreProvider)),
);

class ReservationRepository {
  final FirebaseFirestore _firestore;

  // Constructor injects the Firestore instance
  ReservationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Reference to 'reservations' collection in Firestore
  CollectionReference get _reservationsCollection =>
      _firestore.collection(FirebaseConstants.reservationCollection);

  // Reference to 'timeSlots' collection in Firestore
  CollectionReference get _timeSlotsCollection =>
      _firestore.collection(FirebaseConstants.timeSlotsCollection);

  /// Adds a new reservation document to Firestore with the reservation ID as doc ID
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

  /// Streams all reservations for a specific restaurant ID
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

  /// Streams all reservations for a specific user (customer ID)
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

  /// Updates the status field of a reservation (e.g., Confirmed, Cancelled)
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

  /// Deletes a reservation document by its ID
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

  /// Streams all available time slots (for reservations)
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
