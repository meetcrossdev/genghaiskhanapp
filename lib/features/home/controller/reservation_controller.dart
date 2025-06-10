import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utility.dart';
import '../../../models/reservation.dart';
import '../../../models/times_slot.dart';
import '../repository/reservation_repository.dart';
// StateNotifierProvider for ReservationController, manages a bool loading state
final reservationControllerProvider =
    StateNotifierProvider<ReservationController, bool>(
  (ref) => ReservationController(
    reservationRepository: ref.watch(reservationRepositoryProvider),
    ref: ref,
  ),
);

// StreamProvider to fetch all available time slots
final allTimeFetchProvider = StreamProvider<List<TimeSlot>>((ref) {
  final controller = ref.watch(reservationControllerProvider.notifier);
  return controller.fetchUserTimeSlot();
});

// StreamProvider.family to fetch reservations for a specific restaurant by ID
final restaurantReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, restaurantId) {
  final controller = ref.watch(reservationControllerProvider.notifier);
  return controller.fetchReservations(restaurantId);
});

// StreamProvider.family to fetch reservations for a specific user by user ID
final userReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, userId) {
  final controller = ref.watch(reservationControllerProvider.notifier);
  return controller.fetchUserReservations(userId);
});

class ReservationController extends StateNotifier<bool> {
  final ReservationRepository _reservationRepository;
  final Ref _ref;

  // Constructor injects repository and Riverpod Ref, initial state is false (not loading)
  ReservationController({
    required ReservationRepository reservationRepository,
    required Ref ref,
  })  : _reservationRepository = reservationRepository,
        _ref = ref,
        super(false);

  /// Add a new reservation, toggles loading state and shows snackbar on success/error
  Future<void> addReservation({
    required Reservation reservation,
    required BuildContext context,
  }) async {
    state = true; // loading true

    final res = await _reservationRepository.addReservation(reservation);
    state = false; // loading false

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        showSnackBar(context, "Reservation added successfully");
        Navigator.of(context).pop(); // Close dialog/page if any
        Navigator.of(context).pop(); // Go back after adding
      },
    );
  }

  /// Update reservation status (e.g. Confirmed, Cancelled), with loading and snackbar feedback
  Future<void> updateReservationStatus({
    required String reservationId,
    required String status,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _reservationRepository.updateReservationStatus(
      reservationId,
      status,
    );

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Reservation status updated"),
    );
  }

  /// Delete a reservation by ID, with loading and snackbar feedback
  Future<void> deleteReservation({
    required String reservationId,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _reservationRepository.deleteReservation(reservationId);
    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        if (context.mounted) {
          showSnackBar(context, "Reservation deleted successfully");
        }
      },
    );
  }

  /// Stream reservations for a specific restaurant
  Stream<List<Reservation>> fetchReservations(String restaurantId) {
    return _reservationRepository.fetchReservations(restaurantId);
  }

  /// Stream reservations for a specific user
  Stream<List<Reservation>> fetchUserReservations(String userId) {
    return _reservationRepository.fetchUserReservations(userId);
  }

  /// Stream all available time slots
  Stream<List<TimeSlot>> fetchUserTimeSlot() {
    return _reservationRepository.fetchTimeSlots();
  }
}
