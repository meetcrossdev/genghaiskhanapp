import 'package:uuid/uuid.dart';

class AddonModel {
  final String id;
  final String title;
  final double price;
  final bool isAvailable;

  AddonModel({
    required this.id,
    required this.title,
    required this.price,
    required this.isAvailable,
  });

  factory AddonModel.newAddon({
    required String title,
    required double price,
  }) {
    return AddonModel(
      id: const Uuid().v4(),
      title: title,
      price: price,
      isAvailable: true,
    );
  }

  AddonModel copyWith({
    String? id,
    String? title,
    double? price,
    bool? isAvailable,
  }) {
    return AddonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
