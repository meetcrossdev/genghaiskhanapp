import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';
import 'package:gzresturent/models/ads_on.dart';


final addonsRepositoryProvider = Provider(
  (ref) => AddonsRepository(firebaseFirestore: ref.watch(firestoreProvider)),
);

class AddonsRepository {
  final FirebaseFirestore _firebaseFirestore;
  AddonsRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _addonsCollection =>
      _firebaseFirestore.collection(FirebaseConstants.adonsCollection);

  FutureVoid addAddon(AddonModel addon) async {
    try {
      final docRef = _addonsCollection.doc(addon.id);
      return right(await docRef.set(addon.toJson()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateAddon(AddonModel addon) async {
    try {
      final docRef = _addonsCollection.doc(addon.id);
      return right(await docRef.update(addon.toJson()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteAddon(String id) async {
    try {
      return right(await _addonsCollection.doc(id).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Firestore error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<AddonModel>> fetchAddons() {
    return _addonsCollection.snapshots().map((event) {
      return event.docs.map((doc) {
        try {
          return AddonModel.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          log('Error parsing addon: ${e.toString()}');
          return null;
        }
      }).whereType<AddonModel>().toList();
    });
  }
}
