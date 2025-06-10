import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/nav_screen.dart';
import '../../../core/utility.dart';
import '../../../models/user_models.dart';
import '../repository/auth_repository.dart';
// A global state provider to hold the current user data (nullable)
final userProvider = StateProvider<UserModel?>((ref) => null);

// StateNotifierProvider for managing authentication state
// It provides an instance of AuthController and listens to boolean state (like loading)
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

// StreamProvider to expose auth state changes (e.g., login/logout) from Firebase
final authStateProvider = StreamProvider.autoDispose((ref) {
  final authcontroller = ref.watch(authControllerProvider.notifier);
  return authcontroller.authStateChange;
});

// A simple Provider to create a separate instance of AuthController (if needed)
final authcontrollerprovider = Provider((ref) {
  final authrepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authrepository, ref: ref);
});

// FutureProvider to fetch current logged-in user data once
final userdataAuthprovider = FutureProvider((ref) {
  final authcontroller = ref.read(authControllerProvider.notifier);
  return authcontroller.getuserdata();
});

// AuthController handles authentication logic and extends StateNotifier<bool>
// The `bool` state is used to indicate loading states (e.g., signing in)
class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // Initially, not loading

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChange => _authRepository.authStateChnage;

  // Log in user with email and password
  loginWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    final result = await _authRepository.loginWithEmailAndPassword(
      email,
      password,
      context,
      '',
    );
    result.fold(
      // If login fails, show error message
      (l) {
        showSnackBar(context, l.message);
        Navigator.of(context).pop();
        return;
      },
      // On success, update userProvider and pop navigation stack
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  // Sign in with Google and handle UI loading + error
  void signInWithGoogle(BuildContext context, String devicetoken) async {
    state = true; // start loading
    final user = await _authRepository.googleSignIn(devicetoken);
    state = false; // stop loading

    // Handle result using Either from fpdart
    user.fold(
      (failure) {
        showSnackBar(context, failure.message);
        Navigator.of(context).pop();
        return;
      },
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        Navigator.of(context).pop();
      },
    );
  }

  // Sign in with Apple (same structure as Google)
  void signInWithApple(BuildContext context, String devicetoken) async {
    state = true;
    final user = await _authRepository.appleSignIn(devicetoken);
    state = false;

    user.fold(
      (failure) {
        showSnackBar(context, failure.message);
        print('auth error is ${failure.message}');
        Navigator.of(context).pop();
        return;
      },
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        Navigator.of(context).pop();
      },
    );
  }

  // Register a user with email, including name, phone, image, etc.
  void signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String phone,
    required File imageFile,
    required String password,
    required BuildContext context,
    required String devicetoken,
    required String dob,
  }) async {
    try {
      var user = await _authRepository.signUpWithEmailAndPassword(
        email,
        name,
        phone,
        imageFile,
        password,
        context,
        devicetoken,
        dob,
      );

      user.fold(
        // If failure, show message and pop
        (failure) {
          showSnackBar(context, failure.message);
          Navigator.of(context).pop();
          return;
        },
        // On success, update provider and navigate to main screen
        (userModel) {
          _ref.read(userProvider.notifier).update((state) => userModel);
          showSnackBar(context, "Account Registered Successfully");
          Navigator.of(context).pushNamed(NavScreen.routeName);
        },
      );
    } catch (e) {
      showSnackBar(context, "Sign-up failed: ${e.toString()}");
    }
  }

  // Stream to get real-time updates for a specific user's data by UID
  Stream<UserModel?> getUSerData(String uid) {
    return _authRepository.getUserData(uid);
  }

  // One-time fetch of a specific user’s data by UID
  Future<UserModel?> getSpecificUserData(String uid) {
    return _authRepository.getSpecificUserData(uid);
  }

  // Sign out the currently logged-in user
  void signOut() async {
    _authRepository.signOut();
  }

  // Update user’s online/offline state
  void setuserstate(bool isonline) {
    _authRepository.setuserstate(isonline);
  }

  // Fetch all users from backend (e.g., Firestore)
  Future<List<UserModel>> fetchalusers() async {
    var users = await _authRepository.fetchallUsers();
    return users;
  }

  // Get current logged-in user data (used in FutureProvider)
  Future<UserModel?> getuserdata() async {
    UserModel? user = await _authRepository.getCurrentUserdata();
    return user;
  }
}
