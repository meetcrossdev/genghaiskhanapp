import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/menu_items.dart';
import '../repository/menu_repository.dart';
import '../../../core/utility.dart';

final menuFetchProvider = StreamProvider((ref) {
  final menuController = ref.watch(menuControllerProvider.notifier);
  return menuController.fetchMenuItems();
});

final menuControllerProvider = StateNotifierProvider<MenuController, bool>(
  (ref) => MenuController(
    menuRepository: ref.watch(menuRepositoryProvider),
    ref: ref,
  ),
);

class MenuController extends StateNotifier<bool> {
  final MenuRepository _menuRepository;
  final Ref _ref;

  MenuController({
    required MenuRepository menuRepository,
    required Ref ref,
  })  : _menuRepository = menuRepository,
        _ref = ref,
        super(false);

  void addMenuItem(MenuModel menuItem, context) async {
    state = true;
    final res = await _menuRepository.addMenuItem(menuItem);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  void updateMenuItem(MenuModel menuItem, context) async {
    state = true;
    final res = await _menuRepository.updateMenuItem(menuItem);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  void deleteMenuItem(String id, context) async {
    state = true;
    final res = await _menuRepository.deleteMenuItem(id);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  Stream<List<MenuModel>> fetchMenuItems() {
    return _menuRepository.fetchMenuItems();
  }
}
