import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/core/type_dfs.dart';



final storageRepositoryProvider = Provider(
  (ref) => StorageRepository(
    firebaseStorage: ref.watch(storageProvider),
  ),
);

class StorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask;
      uploadTask = ref.putFile(file!);

      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<String>> storeFiles({
    required String path,
    required String ids,
    required List<File?> files,
  }) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < files.length; i++) {
        String id = ids[i];
        File? file = files[i];

        final ref = _firebaseStorage.ref().child(path).child(id);
        UploadTask uploadTask = ref.putFile(file!);

        final snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return right(downloadUrls);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
