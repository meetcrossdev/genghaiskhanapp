import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/menu_items.dart';
import '../repository/menu_repository.dart';
import '../../../core/utility.dart';

// Provides a real-time stream of all menu items from the MenuController.
// Automatically listens to changes and rebuilds UI components accordingly.
final menuFetchProvider = StreamProvider((ref) {
  // Watches the MenuController instance
  final menuController = ref.watch(menuControllerProvider.notifier);
  // Returns the stream of menu items from the controller
  return menuController.fetchMenuItems();
});

// Provides the MenuController using StateNotifier to manage loading state (boolean).
// It depends on the MenuRepository for actual Firestore interaction.
final menuControllerProvider = StateNotifierProvider<MenuController, bool>(
  (ref) => MenuController(
    menuRepository: ref.watch(menuRepositoryProvider), // Injecting repository dependency
    ref: ref, // Ref used for reading/writing other providers
  ),
);

// The MenuController handles business logic related to menu items.
// Extends StateNotifier<bool> to manage loading state (true = loading, false = idle).
class MenuController extends StateNotifier<bool> {
  final MenuRepository _menuRepository; // Handles actual data layer (Firestore)
  final Ref _ref; // Used to read or interact with other providers

  // Constructor initializing repository and ref, sets initial loading state to false
  MenuController({
    required MenuRepository menuRepository,
    required Ref ref,
  })  : _menuRepository = menuRepository,
        _ref = ref,
        super(false); // Initial loading state is false

  // Adds a new menu item to Firestore and shows a snackbar if there’s an error
  void addMenuItem(MenuModel menuItem, context) async {
    state = true; // Set loading state to true
    final res = await _menuRepository.addMenuItem(menuItem); // Call repo to add item
    state = false; // Set loading state to false

    // Handle response using Either (fpdart): show error if failure
    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  // Updates an existing menu item
  void updateMenuItem(MenuModel menuItem, context) async {
    state = true;
    final res = await _menuRepository.updateMenuItem(menuItem); // Call repo to update
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  // Deletes a menu item by its ID
  void deleteMenuItem(String id, context) async {
    state = true;
    final res = await _menuRepository.deleteMenuItem(id); // Call repo to delete
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  // Fetches a real-time stream of all menu items from Firestore
  Stream<List<MenuModel>> fetchMenuItems() {
    return _menuRepository.fetchMenuItems(); // Delegates to the repository
  }
}
