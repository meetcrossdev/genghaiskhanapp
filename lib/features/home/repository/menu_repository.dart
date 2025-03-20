import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';

import '../../../models/menu_items.dart';

final menuRepositoryProvider = Provider(
  (ref) => MenuRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

class MenuRepository {
  final FirebaseFirestore _firebaseFirestore;
  MenuRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _menuCollection =>
      _firebaseFirestore.collection(FirebaseConstants.menuCollection);

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

  Stream<List<MenuModel>> fetchMenuItems() {
    return _menuCollection.snapshots().map((event) {
      return event.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
        //  print("Fetched Data: $data"); // Debugging log
          return MenuModel.fromJson(data);
        } catch (error) {
          print("Error parsing document: ${doc.id}, Error: $error");
          return null; // Handle errors gracefully
        }
      }).whereType<MenuModel>().toList(); // Removes null values
    });
  }
}
