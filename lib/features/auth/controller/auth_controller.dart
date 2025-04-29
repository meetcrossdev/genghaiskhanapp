import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/nav_screen.dart';
import '../../../core/utility.dart';
import '../../../models/user_models.dart';
import '../repository/auth_repository.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateProvider = StreamProvider.autoDispose((ref) {
  final authcontroller = ref.watch(authControllerProvider.notifier);
  return authcontroller.authStateChange;
});

// final authStateProvider1 = StreamProvider.autoDispose.family((ref, String uid) {
//   final authcontroller = ref.watch(authControllerProvider.notifier);
//   return authcontroller.getUSerData(uid);
// });

final authcontrollerprovider = Provider((ref) {
  final authrepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authrepository, ref: ref);
});

final userdataAuthprovider = FutureProvider((ref) {
  final authcontroller = ref.read(authControllerProvider.notifier);
  return authcontroller.getuserdata();
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref,
      super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChnage;

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
      (l) {
        showSnackBar(context, l.message);
        Navigator.of(context).pop();
        return;
      },
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  void signInWithGoogle(BuildContext context, String devicetoken) async {
    state = true;
    final user = await _authRepository.googleSignIn(devicetoken);
    state = false;
    //use for error handling by using package fpdart and type_ds.dart
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

  void signInWithApple(BuildContext context, String devicetoken) async {
    state = true;
    final user = await _authRepository.appleSignIn(devicetoken);
    state = false;
    //use for error handling by using package fpdart and type_ds.dart
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
      // Call authentication repository function
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

      // Handle response using fold (Either)
      user.fold(
        (failure) {
          showSnackBar(context, failure.message);
          Navigator.of(context).pop();
          return;
        },
        (userModel) {
          // Update user provider with new user data
          _ref.read(userProvider.notifier).update((state) => userModel);
          showSnackBar(context, "Account Reqistered Successfully");
          Navigator.of(context).pushNamed(NavScreen.routeName);
        },
      );
    } catch (e) {
      showSnackBar(context, "Sign-up failed: ${e.toString()}");
    }
  }

  Stream<UserModel?> getUSerData(String uid) {
    return _authRepository.getUserData(uid);
  }

  Future<UserModel?> getSpecificUserData(String uid) {
    return _authRepository.getSpecificUserData(uid);
  }

  void signOut() async {
    _authRepository.signOut();
  }

  // Stream<UserModel> userdatabyid(String UserId) {
  //   return _authRepository.userdata(UserId);
  // }

  void setuserstate(bool isonline) {
    _authRepository.setuserstate(isonline);
  }

  Future<List<UserModel>> fetchalusers() async {
    var users = await _authRepository.fetchallUsers();
    return users;
  }

  Future<UserModel?> getuserdata() async {
    UserModel? user = await _authRepository.getCurrentUserdata();
    return user;
  }
}
