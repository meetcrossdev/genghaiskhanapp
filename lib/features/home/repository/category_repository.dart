import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/failure.dart';
import 'package:gzresturent/models/category.dart';

import '../../../core/provider/storage_provider.dart';

// A provider that creates and supplies an instance of CategoryRepository
// It injects dependencies: FirebaseFirestore and StorageRepository
final categoryRepositoryProvider = Provider((ref) {
  final storage = ref.watch(storageRepositoryProvider);
  return CategoryRepository(
    firestore: FirebaseFirestore.instance,
    storageRepository: storage,
  );
});

// CategoryRepository handles all category-related Firestore and Storage operations
class CategoryRepository {
  final FirebaseFirestore firestore;
  final StorageRepository storageRepository;

  CategoryRepository({
    required this.firestore,
    required this.storageRepository,
  });

  // Adds or updates a category in Firestore
  // If a new image file is provided, it uploads the image and updates the URL
  Future<Either<Failure, void>> addOrUpdateCategory({
    required Category category,
    required File? imageFile,
  }) async {
    try {
      // Use existing image URL unless a new image is uploaded
      String imageUrl = category.imageUrl;

      // If there's a new image file, upload it to storage
      if (imageFile != null) {
        final imageResult = await storageRepository.storeFile(
          path: 'categories',
          id: category.id,
          file: imageFile,
        );

        // On success, update imageUrl; on failure, throw error to be caught below
        imageResult.fold(
          (l) => throw l,
          (r) => imageUrl = r,
        );
      }

      // Create a new category object with the possibly updated image URL
      final updatedCategory = category.copyWith(imageUrl: imageUrl);

      // Save or overwrite the category document in Firestore
      await firestore.collection('categories').doc(category.id).set(updatedCategory.toJson());

      // Return success (Right of Either)
      return right(null);
    } catch (e) {
      // On error, return failure (Left of Either)
      return left(Failure(e.toString()));
    }
  }

  // Returns a real-time stream of all categories from Firestore
  Stream<List<Category>> getAllCategories() {
    return firestore.collection('categories').snapshots().map((snapshot) {
      // Convert each document into a Category model
      return snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
    });
  }
}
