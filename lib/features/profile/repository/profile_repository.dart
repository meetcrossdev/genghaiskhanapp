import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart' show Failure;
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/menu_items.dart';
import '../../../models/user_models.dart';

final userProfileRepositoryProvider = Provider(
  (ref) =>
      UserProfileRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

class UserProfileRepository {
  final FirebaseFirestore _firebaseFirestore;
  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  FutureVoid editProfile(UserModel userModel) async {
    try {
      return right(_users.doc(userModel.id).update(userModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUserLocation(String id, String address) async {
    try {
      return right(_users.doc(id).update({'address': address}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateStatus(String id, String status) async {
    try {
      return right(_users.doc(id).update({'status': status}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<UserModel?> fetchUserByUID(String uid) async {
    try {
      // Query the collection to get the user with the specified UID
      QuerySnapshot querySnapshot =
          await _users.where('id', isEqualTo: uid).get();

      // Check if the user with the given UID exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the user data
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Convert the Map to UserModel using the fromMap constructor
        return UserModel.fromMap(userData);
      } else {
        // User not found
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  FutureVoid updateDeviceToken(String newtoken, String uid) async {
    try {
      return right(
        // Update the user document with the modified favorite list
        await _users.doc(uid).update({'devicetoken': newtoken}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUserFavorite(String dishId, String uid) async {
    try {
      var userSnapshot = await _users.doc(uid).get();
      if (!userSnapshot.exists) {
        return left(Failure("User not found"));
      }
      // Fetch the current favorite list
      List<String> favoriteDishes = List<String>.from(
        userSnapshot['favoriteDishes'] ?? [],
      );

      if (favoriteDishes.contains(dishId)) {
        favoriteDishes.remove(dishId); // Remove from favorites
        log('removed');
      } else {
        favoriteDishes.add(dishId); // Add to favorites
        log('added');
      }

      return right(
        // Update the user document with the modified favorite list
        await _users.doc(uid).update({'favoriteDishes': favoriteDishes}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<UserModel>> fetchUsers() {
    var ss = _users.snapshots().map(
      (event) =>
          event.docs
              .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
    );

    return ss;
  }

  CollectionReference get _menuCollection =>
      _firebaseFirestore.collection(FirebaseConstants.menuCollection);

  // StreamEither<List<MenuItem>> getUserFavoritesStream(String uid) {
  //   return _users.doc(uid).snapshots().asyncMap((userSnapshot) async {
  //     if (!userSnapshot.exists || userSnapshot.data() == null) {
  //       return right([]); // Return empty list if user data doesn't exist
  //     }

  //     UserModel user = UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
  //     List<String> favoriteIds = user.favoriteDishes ?? [];

  //     if (favoriteIds.isEmpty) return right([]);

  //     try {
  //       var menuSnapshot = await _menuCollection.where('id', whereIn: favoriteIds).get();
  //       return right(menuSnapshot.docs.map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>)).toList());
  //     } catch (e) {
  //       return left(Failure("Error fetching favorites: $e"));
  //     }
  //   });
  // }

  StreamEither<List<MenuItem>> getUserFavoritesStream(String uid) {
    return _users.doc(uid).snapshots().asyncMap((userSnapshot) async {
      if (!userSnapshot.exists || userSnapshot.data() == null) {
        return right([]); // Return empty list if user data doesn't exist
      }

      UserModel user = UserModel.fromMap(
        userSnapshot.data() as Map<String, dynamic>,
      );
      List<String> favoriteIds = user.favoriteDishes ?? [];

      if (favoriteIds.isEmpty) return right([]);

      try {
        List<MenuItem> favoriteItems = [];

        // Fetch all menu categories
        var menuCategoriesSnapshot = await _menuCollection.get();

        for (var categoryDoc in menuCategoriesSnapshot.docs) {
          final data =
              categoryDoc.data()
                  as Map<String, dynamic>; // ✅ Explicitly cast to Map

          if (!data.containsKey('items'))
            continue; // Skip if 'items' field is missing

          List<dynamic> items =
              data['items'] as List<dynamic>? ?? []; // ✅ Ensure it's a List

          for (var item in items) {
            if (item is Map<String, dynamic> &&
                favoriteIds.contains(item['id'])) {
              favoriteItems.add(MenuItem.fromJson(item));
            }
          }
        }

        return right(favoriteItems);
      } catch (e) {
        return left(Failure("Error fetching favorites: $e"));
      }
    });
  }
}
