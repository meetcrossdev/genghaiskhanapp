import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/notification_controller.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
 @override
Widget build(BuildContext context) {
  // Watch the notifications stream using Riverpod
  final notificationsStream = ref.watch(allNotificationsProvider);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      centerTitle: true,
    ),
    // Handle async notification data using `.when`
    body: notificationsStream.when(
      data: (notifications) {
        // If there are no notifications, show an empty state
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No New Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Display notifications in a scrollable list with spacing between items
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = notifications[index];

            // Each notification is shown in a card-styled ListTile
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: const Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                  size: 30,
                ),
                title: Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      notification.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // Show how long ago the notification was created
                    Text(
                      timeAgo(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      // Show loading indicator while notifications are being fetched
      loading: () => const Center(child: CircularProgressIndicator()),
      // Show error message if an error occurs while fetching notifications
      error: (error, stack) => Center(child: Text('Error: $error')),
    ),
  );
}

// Helper method to format DateTime into "time ago" text
String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  // Fallback: show full date if older than a week
  return '${date.day}/${date.month}/${date.year}';
}

}
