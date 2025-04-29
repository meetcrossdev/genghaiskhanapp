import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/provider/storage_provider.dart';
import 'package:gzresturent/features/profile/repository/profile_repository.dart';
import '../../../core/utility.dart';
import '../../../models/menu_items.dart';
import '../../../models/user_models.dart';
import '../../auth/controller/auth_controller.dart';

final userFetchProvider = StreamProvider((ref) {
  final postController = ref.watch(userProfileControllerProvider.notifier);
  return postController.fetchUsers();
});

final userFavoritesProvider = StreamProvider.family<List<MenuItem>, String>((
  ref,
  uid,
) {
  final controller = ref.watch(userProfileControllerProvider.notifier);
  return controller.fetchUserFavorites(uid);
});

// final userFavoritesProvider = StreamProvider<List<MenuItem>>((ref) {
//   final user = ref.watch(userProvider);
//   if (user == null) return Stream.value([]); // Return an empty stream if no user

//   final profileController = ref.watch(userProfileControllerProvider.notifier);
//   return profileController.fetchUserFavorites(user.id);
// });

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
      (ref) => UserProfileController(
        userProfileRepository: ref.watch(userProfileRepositoryProvider),
        ref: ref,
        storageRepository: ref.watch(storageRepositoryProvider),
      ),
    );
// final userFavoritesProvider = StateProvider<List<MenuItem>>((ref) => []);

// final getUserPostProvider = StreamProvider.family(
//   (ref, String uid) =>
//       ref.read(userProfileControllerProvider.notifier).getUserPost(uid),
// );

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

  Stream<List<UserModel>> fetchUsers() {
    return _userProfileRepository.fetchUsers();
  }

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
