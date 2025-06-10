import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/home/repository/category_repository.dart';
import 'package:gzresturent/models/category.dart';


// StateNotifierProvider for CategoryController which manages a bool loading state
final categoryControllerProvider =
    StateNotifierProvider<CategoryController, bool>((ref) {
  return CategoryController(
    ref: ref,
    repository: ref.watch(categoryRepositoryProvider),
  );
});

// StreamProvider that exposes a stream of all categories from the controller
final allcategoryProvider = StreamProvider<List<Category>>((ref) {
  final controller = ref.watch(categoryControllerProvider.notifier);
  return controller.getAllCategories();
});

class CategoryController extends StateNotifier<bool> {
  final Ref ref;
  final CategoryRepository repository;

  CategoryController({
    required this.ref,
    required this.repository,
  }) : super(false); // initial state is not loading

  /// Add or update category with optional image upload
  /// 
  /// - `category`: the Category model to add or update
  /// - `imageFile`: an optional File containing the category image
  /// - `onSuccess`: callback on successful operation
  /// - `onFailure`: callback on failure with error message
  void addOrUpdateCategory({
    required Category category,
    required File? imageFile,
    required Function(String) onSuccess,
    required Function(String) onFailure,
  }) async {
    state = true;  // start loading

    final res = await repository.addOrUpdateCategory(
      category: category,
      imageFile: imageFile,
    );

    state = false; // stop loading

    res.fold(
      (failure) => onFailure(failure.message), // call failure callback with message
      (_) => onSuccess('Category saved successfully!'), // success callback
    );
  }

  /// Returns a stream of all categories from the repository
  Stream<List<Category>> getAllCategories() {
    return repository.getAllCategories();
  }
}
