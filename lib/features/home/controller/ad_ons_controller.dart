import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gzresturent/features/home/repository/ad_ons_repository.dart';
import 'package:gzresturent/models/ads_on.dart';

import '../../../core/utility.dart';

final addonsFetchProvider = StreamProvider((ref) {
  final controller = ref.watch(addonsControllerProvider.notifier);
  return controller.fetchAddons();
});

final addonsControllerProvider = StateNotifierProvider<AddonsController, bool>(
  (ref) => AddonsController(
    addonsRepository: ref.watch(addonsRepositoryProvider),
    ref: ref,
  ),
);

class AddonsController extends StateNotifier<bool> {
  final AddonsRepository _addonsRepository;
  final Ref _ref;

  AddonsController({
    required AddonsRepository addonsRepository,
    required Ref ref,
  }) : _addonsRepository = addonsRepository,
       _ref = ref,
       super(false);

  void addAddon(AddonModel addon, BuildContext context) async {
    state = true;
    final res = await _addonsRepository.addAddon(addon);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Addon Added Successfully");
      Navigator.pop(context);
    });
  }

  void updateAddon(AddonModel addon, BuildContext context) async {
    state = true;
    final res = await _addonsRepository.updateAddon(addon);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Addon Updated Successfully");
      Navigator.pop(context);
    });
  }

  void deleteAddon(String id, BuildContext context) async {
    state = true;
    final res = await _addonsRepository.deleteAddon(id);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  Stream<List<AddonModel>> fetchAddons() {
    return _addonsRepository.fetchAddons();
  }
}
