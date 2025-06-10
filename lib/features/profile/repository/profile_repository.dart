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
// Provides an instance of UserProfileRepository with Firestore dependency injected.
final userProfileRepositoryProvider = Provider(
  (ref) =>
      UserProfileRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

// Repository class responsible for managing user profile data in Firestore.
class UserProfileRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor to initialize Firestore instance.
  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Reference to the users collection in Firestore.
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  // Updates the user's profile information with the given UserModel data.
  FutureVoid editProfile(UserModel userModel) async {
    try {
      return right(_users.doc(userModel.id).update(userModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Updates the user's address/location.
  FutureVoid updateUserLocation(String id, String address) async {
    try {
      return right(_users.doc(id).update({'address': address}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Updates the user's status (e.g., active, inactive).
  FutureVoid updateStatus(String id, String status) async {
    try {
      return right(_users.doc(id).update({'status': status}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Updates the user's loyalty points.
  FutureVoid updateLoyaltyPoints(String id, int points) async {
    try {
      return right(_users.doc(id).update({'loyaltyPoints': points}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Fetches user data by UID and returns a UserModel instance or null if not found.
  Future<UserModel?> fetchUserByUID(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await _users.where('id', isEqualTo: uid).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return UserModel.fromMap(userData);
      } else {
        return null; // User not found
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Updates the device token (used for push notifications) for the specified user.
  FutureVoid updateDeviceToken(String newtoken, String uid) async {
    try {
      return right(
        await _users.doc(uid).update({'devicetoken': newtoken}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Adds/removes a dish from the user's favorites list.
  FutureVoid updateUserFavorite(String dishId, String uid) async {
    try {
      var userSnapshot = await _users.doc(uid).get();
      if (!userSnapshot.exists) {
        return left(Failure("User not found"));
      }

      List<String> favoriteDishes = List<String>.from(
        userSnapshot['favoriteDishes'] ?? [],
      );

      if (favoriteDishes.contains(dishId)) {
        favoriteDishes.remove(dishId); // Remove if already in favorites
        log('removed');
      } else {
        favoriteDishes.add(dishId); // Add if not in favorites
        log('added');
      }

      return right(
        await _users.doc(uid).update({'favoriteDishes': favoriteDishes}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Returns a real-time stream of all users in the system.
  Stream<List<UserModel>> fetchUsers() {
    return _users.snapshots().map(
      (event) => event.docs
          .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  // Reference to the menu collection which holds menu categories and items.
  CollectionReference get _menuCollection =>
      _firebaseFirestore.collection(FirebaseConstants.menuCollection);

  // Returns a real-time stream of a user's favorite menu items.
  StreamEither<List<MenuItem>> getUserFavoritesStream(String uid) {
    return _users.doc(uid).snapshots().asyncMap((userSnapshot) async {
      if (!userSnapshot.exists || userSnapshot.data() == null) {
        return right([]); // Return empty if user doesn't exist
      }

      UserModel user = UserModel.fromMap(
        userSnapshot.data() as Map<String, dynamic>,
      );
      List<String> favoriteIds = user.favoriteDishes ?? [];

      if (favoriteIds.isEmpty) return right([]); // No favorites to fetch

      try {
        List<MenuItem> favoriteItems = [];

        // Fetch all menu categories from the menu collection
        var menuCategoriesSnapshot = await _menuCollection.get();

        for (var categoryDoc in menuCategoriesSnapshot.docs) {
          final data = categoryDoc.data() as Map<String, dynamic>;

          if (!data.containsKey('items')) continue; // Skip if no 'items' key

          List<dynamic> items = data['items'] as List<dynamic>? ?? [];

          for (var item in items) {
            // If item is a map and is in user's favorites, add to the list
            if (item is Map<String, dynamic> &&
                favoriteIds.contains(item['id'])) {
              favoriteItems.add(MenuItem.fromJson(item));
            }
          }
        }

        return right(favoriteItems); // Return the list of favorite items
      } catch (e) {
        return left(Failure("Error fetching favorites: $e"));
      }
    });
  }
}
