import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gzresturent/core/constant/firebase_constants.dart';
import 'package:gzresturent/core/provider/firebase_provider.dart';
import 'package:gzresturent/models/user_models.dart';

import '../../../core/failure.dart';
import '../../../core/provider/storage_provider.dart';
import '../../../core/type_dfs.dart';
import '../../../core/utility.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final StorageRepository _storageRepository;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required StorageRepository storageRepository,
  }) : _auth = auth,
       _firestore = firestore,
       _googleSignIn = googleSignIn,
       _storageRepository = storageRepository;

  CollectionReference get users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  void setuserstate(bool isonline) async {
    await users.doc(_auth.currentUser!.uid).update({'online': isonline});
  }

  Future<UserModel?> getCurrentUserdata() async {
    var userdata =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(_auth.currentUser?.uid)
            .get();
    UserModel? user;
    if (userdata.data() != null) {
      user = UserModel.fromMap(userdata.data()!);
    }
    return user;
  }

  Stream<UserModel> userdata(String userid) {
    return _firestore
        .collection('users')
        .doc(userid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  FutureEither<UserModel?> googleSignIn(String devicetoken) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(Failure("Google sign-in was canceled."));
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      UserModel? userModel;
      final token = await FirebaseMessaging.instance.getToken();
      if (Platform.isIOS) {
        String? apns = await FirebaseMessaging.instance.getAPNSToken();
        print('APNs Token: $apns');
      }

      final userId = userCredential.user!.uid;

      // Check if it's a new user
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic:
              userCredential.user!.photoURL ??
              'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2',
          email: userCredential.user!.email!,
          phoneNo: userCredential.user!.phoneNumber ?? '',
          favoriteDishes: [], // Default empty list

          deviceToken: token,
          address: null, // Address not available initially
          role: "customer", // Default role is "customer"
          loyaltyPoints: 0, // New user starts with 0 points
          orderHistory: [], // No order history initially
          dob: '',
        );

        // Save new user to Firestore
        await users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        final token = await FirebaseMessaging.instance.getToken();
        final userId = userCredential.user!.uid;
        if (Platform.isIOS) {
          String? apns = await FirebaseMessaging.instance.getAPNSToken();
          print('APNs Token: $apns');
        }
        // Existing user: update device token and fetch user data
        await users.doc(userCredential.user!.uid).update({
          'deviceToken': token,
          'online': true,
        });

        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Firebase authentication error"));
    } catch (e) {
      print(e);
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel?>> signUpWithEmailAndPassword(
    String email,
    String name,
    String phone,
    File imageFile,
    String password,
    BuildContext context,
    String devicetoken,
    String dob,
  ) async {
    String? profileImage;

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Upload profile picture to Firebase Storage
      // final res = await _storageRepository.storeFile(
      //   path: 'users/profile',
      //   id: userCredential.user!.uid,
      //   file: imageFile,
      // );

      // res.fold((l) {
      //   showSnackBar(context, l.message);
      //   return;
      // }, (r) => profileImage = r);

      // Create a new user model
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        profilePic:
            profileImage ??
            'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2',
        email: userCredential.user!.email!,
        phoneNo: phone,
        favoriteDishes: [], // Default empty list

        deviceToken: devicetoken,
        address: null, // Address can be set later
        role: "customer", // Default role is "customer"
        loyaltyPoints: 0, // New user starts with 0 loyalty points
        orderHistory: [], // Empty order history for new users
        dob: dob,
      );

      // Save user to Firestore
      await users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Firebase authentication error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel?> loginWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
    String devicetoken, // Add device token to update it upon login
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await users.doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        return left(Failure("User data not found in database."));
      }

      // Convert Firestore data into UserModel
      UserModel userModel = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      if (Platform.isIOS) {
        String? apns = await FirebaseMessaging.instance.getAPNSToken();
        print('APNs Token: $apns');
      }
      final token = await FirebaseMessaging.instance.getToken();

      // Update device token & online status
      await users.doc(userCredential.user!.uid).update({
        'deviceToken': token,
        'online': true,
      });

      // Show success message
      showSnackBar(context, 'Login successful');

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Authentication failed"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<User?> get authStateChnage => _auth.authStateChanges();

  Stream<UserModel?> getUserData(String uid) {
    return users.doc(uid).snapshots().map((event) {
      final data = event.data();
      if (data == null) {
        // Document does not exist or data is null
        return null;
      }

      // Safely cast the data to Map<String, dynamic> and create a UserModel
      return UserModel.fromMap(data as Map<String, dynamic>);
    });
  }

  Future<UserModel?> getSpecificUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      final data = documentSnapshot.data();
      if (data == null) {
        // Document does not exist or data is null
        return null;
      }
      // log(data.toString());
      // Safely cast the data to Map<String, dynamic> and create a UserModel
      return UserModel.fromMap(data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  Future<List<UserModel>> fetchallUsers() async {
    try {
      final querySnapshot = await users.get();

      // Map each document to a UserModel and return the list
      var alluser =
          querySnapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return alluser;
    } catch (e) {
      // Handle errors such as Firestore exceptions or conversion errors
      print('Error fetching users: $e');
      return [];
    }
  }

  FutureEither<UserModel?> appleSignIn(String devicetoken) async {
    try {
      // final rawNonce = _generateNonce();
      // final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final token = await FirebaseMessaging.instance.getToken();

      UserModel? userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          id: userCredential.user!.uid,
          name:
              '${appleCredential.givenName ?? 'No'} ${appleCredential.familyName ?? 'Name'}',
          profilePic:
              'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', // Default pic
          email: userCredential.user!.email ?? '',
          phoneNo: '',
          favoriteDishes: [],
          deviceToken: devicetoken,
          address: null,
          role: "customer",
          loyaltyPoints: 0,
          orderHistory: [],
          dob: '',
        );

        await users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        await users.doc(userCredential.user!.uid).update({
          'deviceToken': token,
          'online': true,
        });

        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Apple sign-in error"));
    } catch (e, st) {
      print('Apple Sign-in error: $e');
      print('Stack trace: $st');
      return left(Failure(e.toString()));
    }
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
