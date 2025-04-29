import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utility.dart';
import '../../../models/reservation.dart';
import '../../../models/times_slot.dart';
import '../repository/reservation_repository.dart';

final reservationControllerProvider =
    StateNotifierProvider<ReservationController, bool>(
      (ref) => ReservationController(
        reservationRepository: ref.watch(reservationRepositoryProvider),
        ref: ref,
      ),
    );

final allTimeFetchProvider = StreamProvider<List<TimeSlot>>((ref) {
  final controller = ref.watch(reservationControllerProvider.notifier);
  return controller.fetchUserTimeSlot();
});

/// ✅ Fetch reservations for a specific restaurant
final restaurantReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, restaurantId) {
      final controller = ref.watch(reservationControllerProvider.notifier);
      return controller.fetchReservations(restaurantId);
    });

/// ✅ Fetch reservations for a specific user
final userReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, userId) {
      final controller = ref.watch(reservationControllerProvider.notifier);
      return controller.fetchUserReservations(userId);
    });

class ReservationController extends StateNotifier<bool> {
  final ReservationRepository _reservationRepository;
  final Ref _ref;

  ReservationController({
    required ReservationRepository reservationRepository,
    required Ref ref,
  }) : _reservationRepository = reservationRepository,
       _ref = ref,
       super(false);

  /// ✅ Add a new reservation
  Future<void> addReservation({
    required Reservation reservation,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _reservationRepository.addReservation(reservation);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Reservation added successfully"),
    );
  }

  /// ✅ Update reservation status
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
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Reservation status updated"),
    );
  }

  Future<void> deleteReservation({
    required String reservationId,

    required BuildContext context,
  }) async {
    state = true;

    final res = await _reservationRepository.deleteReservation(reservationId);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (context.mounted) {
        showSnackBar(context, "Reservation status updated");
      }
    });
  }

  /// ✅ Fetch reservations for restaurant
  Stream<List<Reservation>> fetchReservations(String restaurantId) {
    return _reservationRepository.fetchReservations(restaurantId);
  }

  /// ✅ Fetch reservations for user
  Stream<List<Reservation>> fetchUserReservations(String userId) {
    return _reservationRepository.fetchUserReservations(userId);
  }

  Stream<List<TimeSlot>> fetchUserTimeSlot() {
    return _reservationRepository.fetchTimeSlots();
  }
}
