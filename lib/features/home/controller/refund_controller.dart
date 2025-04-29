import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/home/repository/refund_repostiory.dart';
import 'package:gzresturent/models/refund_request.dart';

final refundControllerProvider =
    StateNotifierProvider<RefundController, bool>(
  (ref) => RefundController(
    refundRepository: ref.watch(refundRepositoryProvider),
    ref: ref,
  ),
);

final userRefundsProvider =
    StreamProvider.family<List<RefundRequest>, String>((ref, userId) {
  return ref
      .watch(refundControllerProvider.notifier)
      .fetchUserRefunds(userId);
});

class RefundController extends StateNotifier<bool> {
  final RefundRepository _refundRepository;
  final Ref _ref;

  RefundController({
    required RefundRepository refundRepository,
    required Ref ref,
  })  : _refundRepository = refundRepository,
        _ref = ref,
        super(false);

  Future<void> submitRefundRequest({
    required RefundRequest refund,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _refundRepository.submitRefundRequest(refund);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Refund request submitted"),
    );
  }

  Stream<List<RefundRequest>> fetchUserRefunds(String userId) {
    return _refundRepository.fetchUserRefunds(userId);
  }
}
