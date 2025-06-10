import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/constant/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/provider/firebase_provider.dart';
import '../../../core/type_dfs.dart';
import '../../../models/notification.dart';
// Provider to expose NotificationRepository to the rest of the app using Riverpod
final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(firestore: ref.watch(firestoreProvider)),
);

// Repository class responsible for all Firestore operations related to push notifications
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Getter to access the specific collection used for storing notifications
  CollectionReference get _notificationCollection =>
      _firestore.collection(FirebaseConstants.pushNotificationCollection);

  // Method to create a new notification document in Firestore
  FutureVoid createNotification(PushNotification notification) async {
    try {
      await _notificationCollection
          .doc(notification.id) // Use the notification's ID as the document ID
          .set(notification.toJson()); // Convert the model to JSON and save
      return right(null); // Return success using Either
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      return left(Failure(e.message ?? "Failed to create notification"));
    } catch (e) {
      // Handle any other generic errors
      return left(Failure(e.toString()));
    }
  }

  // Returns a stream of all notifications in real time, ordered by creation time (newest first)
  Stream<List<PushNotification>> fetchAllNotifications() {
    return _notificationCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return PushNotification.fromJson(data); // Convert Firestore data to model
                } catch (e) {
                  // Log and skip documents that fail to parse
                  print("Error parsing notification: ${doc.id}, Error: $e");
                  return null;
                }
              })
              .whereType<PushNotification>() // Filter out nulls
              .toList();
        });
  }

  // Updates an existing notification document in Firestore
  FutureVoid updateNotification(PushNotification notification) async {
    try {
      await _notificationCollection
          .doc(notification.id)
          .update(notification.toJson()); // Apply updates
      return right(null); // Success
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to update notification"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Deletes a notification document by its ID
  FutureVoid deleteNotification(String id) async {
    try {
      await _notificationCollection.doc(id).delete(); // Delete document
      return right(null); // Success
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to delete notification"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
