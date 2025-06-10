import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/menu_items.dart';




// Riverpod provider for MenuRepository
// It injects Firestore dependency for use inside the repository
final menuRepositoryProvider = Provider(
  (ref) => MenuRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

// Repository for handling all Firestore operations related to menu items
class MenuRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor to inject the Firestore instance
  MenuRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Reference to the 'menu' collection in Firestore
  CollectionReference get _menuCollection =>
      _firebaseFirestore.collection(FirebaseConstants.menuCollection);

  /// Adds a new menu item to Firestore
  /// The document ID is the menu item's name
  FutureVoid addMenuItem(MenuModel menuItem) async {
    try {
      return right(
        _menuCollection.doc(menuItem.name).set(menuItem.toJson()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Updates an existing menu item in Firestore
  /// It uses the menu item's name as the document ID
  FutureVoid updateMenuItem(MenuModel menuItem) async {
    try {
      return right(
        _menuCollection.doc(menuItem.name).update(menuItem.toJson()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Deletes a menu item from Firestore using its document ID
  FutureVoid deleteMenuItem(String id) async {
    try {
      return right(
        _menuCollection.doc(id).delete(),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Unknown Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Fetches all menu items from Firestore as a real-time stream
  /// Each document is converted into a `MenuModel`
  Stream<List<MenuModel>> fetchMenuItems() {
    return _menuCollection.snapshots().map((event) {
      return event.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          // Convert the Firestore document to a MenuModel object
          return MenuModel.fromJson(data);
        } catch (error) {
          // Log and skip documents that fail to parse
          print("Error parsing document: ${doc.id}, Error: $error");
          return null;
        }
      }).whereType<MenuModel>().toList(); // Filters out null values
    });
  }
}
