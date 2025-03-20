// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNo;
  final String profilePic;
  final List<String>
  favoriteDishes; // Updated to store favorite restaurant dishes

  final String? deviceToken;
  final String? address; // New: User's delivery address
  final String role; // New: User role (customer, admin, chef, etc.)
  final int loyaltyPoints; // New: Points for discounts/rewards
  final List<String> orderHistory; // New: Stores past orders

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.profilePic,
    required this.favoriteDishes,

    required this.deviceToken,
    required this.address,
    required this.role,
    required this.loyaltyPoints,
    required this.orderHistory,
  });

  /// Convert JSON to UserModel
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNo: json['phoneNo'] as String,
      profilePic: json['profilePic'] as String,
      favoriteDishes: List<String>.from(json['favoriteDishes'] ?? []),

      deviceToken: json['deviceToken'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String? ?? "customer", // Default role is 'customer'
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0, // Default 0 points
      orderHistory: List<String>.from(json['orderHistory'] ?? []),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'profilePic': profilePic,
      'favoriteDishes': favoriteDishes,

      'deviceToken': deviceToken,
      'address': address,
      'role': role,
      'loyaltyPoints': loyaltyPoints,
      'orderHistory': orderHistory,
    };
  }

  /// Convert JSON string to UserModel
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromMap(json.decode(jsonString));
  }

  /// Convert UserModel to JSON string
  String toJsonString() {
    return json.encode(toMap());
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phoneNo: $phoneNo, profilePic: $profilePic, favoriteDishes: $favoriteDishes, deviceToken: $deviceToken, address: $address, role: $role, loyaltyPoints: $loyaltyPoints, orderHistory: $orderHistory)';
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNo,
    String? profilePic,
    //? favoriteDishes,
    String? deviceToken,
    String? address,
    String? role,
    int? loyaltyPoints,
    List<String>? orderHistory,
    List<String>? favoriteDishes,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profilePic: profilePic ?? this.profilePic,
      favoriteDishes: favoriteDishes ?? this.favoriteDishes,
      deviceToken: deviceToken ?? this.deviceToken,
      address: address ?? this.address,
      role: role ?? this.role,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }
}
