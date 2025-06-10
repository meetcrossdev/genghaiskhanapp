import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/provider/storage_provider.dart';
import 'package:gzresturent/features/profile/repository/profile_repository.dart';
import '../../../core/utility.dart';
import '../../../models/menu_items.dart';
import '../../../models/user_models.dart';
import '../../auth/controller/auth_controller.dart';

// Provides a stream of all users fetched by the UserProfileController.
final userFetchProvider = StreamProvider((ref) {
  final postController = ref.watch(userProfileControllerProvider.notifier);
  return postController.fetchUsers();
});

// Provides a stream of favorite menu items for a specific user by UID.
final userFavoritesProvider = StreamProvider.family<List<MenuItem>, String>((
  ref,
  uid,
) {
  final controller = ref.watch(userProfileControllerProvider.notifier);
  return controller.fetchUserFavorites(uid);
});

// Provides the UserProfileController as a state notifier.
// The boolean state can be used for loading indicators (e.g., true = loading).
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
      (ref) => UserProfileController(
        userProfileRepository: ref.watch(userProfileRepositoryProvider),
        ref: ref,
        storageRepository: ref.watch(storageRepositoryProvider),
      ),
    );

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _userProfileRepository = userProfileRepository,
       _ref = ref,
       _storageRepository = storageRepository,
       super(false);

  // Toggles a dish as favorite for the user and updates the UI accordingly

  void updateUserFavorite(String id, String uid, BuildContext context) async {
    UserModel user = _ref.read(userProvider)!;

    // Create a copy of the original list and add the new item
    List<String> updatedFavorite = List.from(user.favoriteDishes)..add(id);

    // Update the user object with the modified favorite list
    user = user.copyWith(favoriteDishes: updatedFavorite);

    final res = await _userProfileRepository.updateUserFavorite(id, uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      //  showSnackBar(context, 'Food is marked as favortie');
    });
  }
 // Updates user profile data (excluding profile picture here)
  void editProfile({
    //required File? profileFile,
    required BuildContext context,
    required String name,
    required String email,
    required String phoneno,
    required String dob,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    // if (profileFile != null) {
    //   final res = await _storageRepository.storeFile(
    //     path: 'users/profile',
    //     id: user.id,
    //     file: profileFile,
    //   );
    //   res.fold(
    //     (l) => showSnackBar(context, l.message),
    //     (r) => user = user.copyWith(profilePic: r),
    //   );
    // }

    user = user.copyWith(name: name, phoneNo: phoneno, dob: dob);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      showSnackBar(context, 'User Updated Successfully');
      Navigator.of(context).pop();
    });
  }
 // Fetches a stream of all users from Firestore
  Stream<List<UserModel>> fetchUsers() {
    return _userProfileRepository.fetchUsers();
  }
  // Updates a user's status (e.g., active, offline)
  Future<void> updateStatus({
    required String id,
    required String status,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _userProfileRepository.updateStatus(id, status);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }
  // Updates a user's loyalty points
  Future<void> updateLoyaltyPoints({
    required String id,
    required int points,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _userProfileRepository.updateLoyaltyPoints(id, points);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }
// Updates a user's saved address/location
  Future<void> updateLocation({
    required String id,
    required String location,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _userProfileRepository.updateUserLocation(id, location);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Location update successful');
    });
  }
// Updates the device token for push notifications
  void updatedevicetoken({
    required String devicetoken,
    required String uid,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _userProfileRepository.updateDeviceToken(
      devicetoken,
      uid,
    );
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

 // Fetches user's favorite dishes and returns a stream of MenuItem list
  Stream<List<MenuItem>> fetchUserFavorites(String uid) {
    return _userProfileRepository
        .getUserFavoritesStream(uid)
        .map(
          (either) => either.fold((failure) {
            debugPrint("Error fetching favorites: ${failure.message}");
            return [];
          }, (favorites) => favorites),
        );
  }
}
