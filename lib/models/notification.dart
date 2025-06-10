import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PushNotification {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  PushNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory PushNotification.newPushNotification({
    required String title,
    required String description,
  }) {
    return PushNotification(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  PushNotification copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(), // 🔥 FIX
    );
  }
}
