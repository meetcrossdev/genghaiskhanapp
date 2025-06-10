import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utility.dart';
import '../../../models/notification.dart';
import '../repository/notification_repository.dart';
// Provider for NotificationController, using StateNotifier to track loading state (bool).
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>(
      (ref) => NotificationController(
        notificationRepository: ref.watch(notificationRepositoryProvider), // Injecting the repository
        ref: ref, // Allows controller to interact with other providers
      ),
    );

// Provides a real-time stream of all push notifications.
// Listens to updates in the notificationController and rebuilds UI on changes.
final allNotificationsProvider = StreamProvider((ref) {
  final controller = ref.watch(notificationControllerProvider.notifier); // Get controller
  return controller.fetchAllNotifications(); // Return stream from repository
});

// NotificationController handles all business logic related to push notifications.
// Extends StateNotifier<bool> to track loading state.
class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository; // Handles Firestore ops
  final Ref _ref; // Allows access to other providers

  // Constructor initializes dependencies and sets loading state to false.
  NotificationController({
    required NotificationRepository notificationRepository,
    required Ref ref,
  }) : _notificationRepository = notificationRepository,
       _ref = ref,
       super(false); // Initial loading state is false

  // Creates a new push notification in Firestore.
  // Displays a snackbar message based on success or failure.
  Future<void> createNotification({
    required PushNotification notification,
    required BuildContext context,
  }) async {
    state = true; // Show loading
    final res = await _notificationRepository.createNotification(notification); // Call repository
    state = false; // Hide loading

    // Handle result: show error or success message
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Notification created"),
    );
  }

  // Fetches all notifications as a real-time stream.
  Stream<List<PushNotification>> fetchAllNotifications() {
    return _notificationRepository.fetchAllNotifications(); // Delegates to repo
  }

  // Updates an existing push notification.
  Future<void> updateNotification({
    required PushNotification notification,
    required BuildContext context,
  }) async {
    state = true; // Start loading
    final res = await _notificationRepository.updateNotification(notification); // Call repo
    state = false; // End loading

    // Show snackbar based on result
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Notification updated"),
    );
  }

  // Deletes a notification by ID.
  Future<void> deleteNotification({
    required String id,
    required BuildContext context,
  }) async {
    state = true; // Set loading state
    final res = await _notificationRepository.deleteNotification(id); // Call delete method
    state = false;

    // Show success or error message
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "Notification deleted"),
    );
  }
}
