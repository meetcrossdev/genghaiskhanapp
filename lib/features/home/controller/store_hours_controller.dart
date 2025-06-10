import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utility.dart';
import '../../../models/store_hours.dart';
import '../repository/store_hours_repository.dart';

// StateNotifierProvider for managing store hours and loading state
final storeHourControllerProvider =
    StateNotifierProvider<StoreHourController, bool>(
  (ref) => StoreHourController(
    storeHourRepository: ref.watch(storeHourRepositoryProvider),
    ref: ref,
  ),
);

// StreamProvider to listen to store's live status (open/closed)
final storeStatusProvider = StreamProvider<bool>((ref) {
  final controller = ref.watch(storeHourControllerProvider.notifier);
  return controller.fetchStoreStatus();
});

// StreamProvider.family to fetch store hours for a specific store by storeId
final storeHoursProvider = StreamProvider.family<List<StoreHour>, String>(
  (ref, storeId) {
    final controller = ref.watch(storeHourControllerProvider.notifier);
    return controller.fetchStoreHours(storeId);
  },
);

// StreamProvider for the list of holidays (dates)
final holidaysProvider = StreamProvider<List<DateTime>>((ref) {
  final controller = ref.watch(storeHourControllerProvider.notifier);
  return controller.fetchHolidays();
});

class StoreHourController extends StateNotifier<bool> {
  final StoreHourRepository _storeHourRepository;
  final Ref _ref;

  StoreHourController({
    required StoreHourRepository storeHourRepository,
    required Ref ref,
  })  : _storeHourRepository = storeHourRepository,
        _ref = ref,
        super(false); // false means not loading initially

  /// Update store hours for a given storeId
  Future<void> updateStoreHours({
    required String storeId,
    required List<StoreHour> hours,
    required BuildContext context,
  }) async {
    state = true; // set loading true

    final res = await _storeHourRepository.updateStoreHours(storeId, hours);

    state = false; // set loading false

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Store hours updated successfully"),
    );
  }

  /// Update store's live status (open/closed)
  Future<void> updateStoreStatus({
    required bool isLive,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.updateStoreLive(isLive);

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Store status updated successfully"),
    );
  }

  /// Fetch store hours stream for a given storeId
  Stream<List<StoreHour>> fetchStoreHours(String storeId) {
    return _storeHourRepository.fetchStoreHours(storeId);
  }

  /// Fetch store's live status stream
  Stream<bool> fetchStoreStatus() {
    return _storeHourRepository.fetchStoreStatus();
  }

  /// Add a holiday date to the system
  Future<void> addHoliday({
    required DateTime holidayDate,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.addHoliday(holidayDate);

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Holiday added successfully"),
    );
  }

  /// Remove a holiday date from the system
  Future<void> removeHoliday({
    required DateTime holidayDate,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.removeHoliday(holidayDate);

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Holiday removed successfully"),
    );
  }

  /// Fetch stream of holidays
  Stream<List<DateTime>> fetchHolidays() {
    return _storeHourRepository.fetchHolidays();
  }
}
