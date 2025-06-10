import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';
import 'package:gzresturent/models/ads_on.dart';


// Provider for AddonsRepository, injecting FirebaseFirestore via Riverpod
final addonsRepositoryProvider = Provider(
  (ref) => AddonsRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

// Repository class to manage addon-related Firestore operations
class AddonsRepository {
  final FirebaseFirestore _firebaseFirestore;

  // Constructor injecting the Firestore instance
  AddonsRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Reference to the Firestore 'addons' collection
  CollectionReference get _addonsCollection =>
      _firebaseFirestore.collection(FirebaseConstants.adonsCollection);

  // Adds a new addon document to Firestore
  FutureVoid addAddon(AddonModel addon) async {
    try {
      final docRef = _addonsCollection.doc(addon.id); // Create document reference with provided ID
      return right(await docRef.set(addon.toJson())); // Save addon data
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      // Handle any other unexpected errors
      return left(Failure(e.toString()));
    }
  }

  // Updates an existing addon document in Firestore
  FutureVoid updateAddon(AddonModel addon) async {
    try {
      final docRef = _addonsCollection.doc(addon.id); // Reference to existing addon
      return right(await docRef.update(addon.toJson())); // Update the document
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Deletes an addon document by its ID
  FutureVoid deleteAddon(String id) async {
    try {
      return right(await _addonsCollection.doc(id).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Fetches a stream of all addons and maps each document to an AddonModel
  Stream<List<AddonModel>> fetchAddons() {
    return _addonsCollection.snapshots().map((event) {
      return event.docs.map((doc) {
        try {
          // Safely convert each document to an AddonModel
          return AddonModel.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          // Log and ignore parsing errors
          log('Error parsing addon: ${e.toString()}');
          return null;
        }
      }).whereType<AddonModel>().toList(); // Filters out nulls
    });
  }
}
