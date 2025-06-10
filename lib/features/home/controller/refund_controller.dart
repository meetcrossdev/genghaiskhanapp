import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/home/repository/refund_repostiory.dart';
import 'package:gzresturent/models/refund_request.dart';

// StateNotifierProvider to manage refund-related actions and loading state
final refundControllerProvider = StateNotifierProvider<RefundController, bool>(
  (ref) => RefundController(
    refundRepository: ref.watch(refundRepositoryProvider),
    ref: ref,
  ),
);

// StreamProvider.family to stream refund requests for a specific user by userId
final userRefundsProvider = StreamProvider.family<List<RefundRequest>, String>(
  (ref, userId) {
    return ref.watch(refundControllerProvider.notifier).fetchUserRefunds(userId);
  },
);

class RefundController extends StateNotifier<bool> {
  final RefundRepository _refundRepository;
  final Ref _ref;

  RefundController({
    required RefundRepository refundRepository,
    required Ref ref,
  })  : _refundRepository = refundRepository,
        _ref = ref,
        super(false); // Initial loading state is false

  /// Submit a new refund request
  Future<void> submitRefundRequest({
    required RefundRequest refund,
    required BuildContext context,
  }) async {
    state = true; // show loading
    final res = await _refundRepository.submitRefundRequest(refund);
    state = false; // hide loading

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) {
        showSnackBar(context, "Report submitted successfully");
        Navigator.of(context).pop();
      },
    );
  }

  /// Stream refund requests of a specific user
  Stream<List<RefundRequest>> fetchUserRefunds(String userId) {
    return _refundRepository.fetchUserRefunds(userId);
  }
}
