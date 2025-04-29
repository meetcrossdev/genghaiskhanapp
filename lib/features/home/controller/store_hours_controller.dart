import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utility.dart';
import '../../../models/store_hours.dart';
import '../repository/store_hours_repository.dart';


final storeHourControllerProvider =
    StateNotifierProvider<StoreHourController, bool>(
      (ref) => StoreHourController(
        storeHourRepository: ref.watch(storeHourRepositoryProvider),
        ref: ref,
      ),
    );

final storeStatusProvider = StreamProvider<bool>((ref) {
  final controller = ref.watch(storeHourControllerProvider.notifier);
  return controller.fetchStoreStatus();
});

final storeHoursProvider = StreamProvider.family<List<StoreHour>, String>((
  ref,
  storeId,
) {
  final controller = ref.watch(storeHourControllerProvider.notifier);
  return controller.fetchStoreHours(storeId);
});


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
  }) : _storeHourRepository = storeHourRepository,
       _ref = ref,
       super(false);

  Future<void> updateStoreHours({
    required String storeId,
    required List<StoreHour> hours,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.updateStoreHours(storeId, hours);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Store hours updated successfully"),
    );
  }

  Future<void> updateStoreStatus({
    required bool isLive,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.updateStoreLive(isLive);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Store hours updated successfully"),
    );
  }

  Stream<List<StoreHour>> fetchStoreHours(String storeId) {
    return _storeHourRepository.fetchStoreHours(storeId);
  }

  Stream<bool> fetchStoreStatus() {
    return _storeHourRepository.fetchStoreStatus();
  }

  // ✅ Add Holiday
  Future<void> addHoliday({
    required DateTime holidayDate,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.addHoliday(holidayDate);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Holiday added successfully"),
    );
  }

  // ✅ Remove Holiday
  Future<void> removeHoliday({
    required DateTime holidayDate,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _storeHourRepository.removeHoliday(holidayDate);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Holiday removed successfully"),
    );
  }

  // ✅ Fetch Holidays Stream
  Stream<List<DateTime>> fetchHolidays() {
    return _storeHourRepository.fetchHolidays();
  }
}
