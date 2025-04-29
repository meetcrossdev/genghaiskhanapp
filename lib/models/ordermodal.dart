import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gzresturent/models/ordermenu.dart';

class OrderModel {
  final String id; // Unique Order ID
  final String userId; // ID of the user who placed the order
  final List<OrderItem> items; // List of ordered items
  final double totalPrice; // Total price of the order
  final String
  status; // Order status (pending, preparing, completed, cancelled)
  final String paymentMethod; // Cash, Card, Online Payment
  final String? transactionId; // Transaction ID (if online payment)
  final String deliveryAddress; // Address for delivery
  final Timestamp createdAt; // Timestamp when the order was placed
  final Timestamp? completedAt; // Timestamp when the order was completed
  final String? additionalNotes;
  // New Field: Order Status Progress
  final List<OrderStep> orderSteps; // Tracks each order stage
  final String trackid;
  final String? paymentIntentId;
  final String? paymentStatus;
  final String? tax;
  final String? orderType;
  final String? deliveryTrackingUrl;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.deliveryAddress,
    required this.createdAt,
    this.completedAt,
    this.additionalNotes,
    required this.orderSteps, // New field
    required this.trackid,
    this.paymentIntentId,
    this.paymentStatus,
    this.tax,
    this.orderType,
    this.deliveryTrackingUrl,
  });

  // Convert Firestore data to OrderModel
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['userId'],
      items:
          (map['items'] as List<dynamic>)
              .map((item) => OrderItem.fromMap(item))
              .toList(),
      totalPrice: map['totalPrice'].toDouble(),
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      deliveryAddress: map['deliveryAddress'],
      createdAt: map['createdAt'],
      completedAt: map['completedAt'],
      additionalNotes: map['additionalNotes'],
      trackid: map['trackid'],
      paymentIntentId: map['paymentIntentId'],
      paymentStatus: map['paymentStatus'],
      tax: map['tax'],
      orderType: map['orderType'],
      deliveryTrackingUrl: map['deliveryTrackingUrl'],
      orderSteps:
          (map['orderSteps'] as List<dynamic>)
              .map((step) => OrderStep.fromMap(step))
              .toList(),
    );
  }

  // Convert OrderModel to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'additionalNotes': additionalNotes,
      'trackid': trackid,
      'orderSteps': orderSteps.map((step) => step.toMap()).toList(),
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus,
      'tax': tax,
      'deliveryTrackingUrl': deliveryTrackingUrl,
      'orderType': orderType,
    };
  }
}

class OrderStep {
  final String step; // Example: "Order Received", "Order In Making"
  final Timestamp? timestamp; // Timestamp when the step was completed

  OrderStep({required this.step, this.timestamp});

  // Convert Firestore data to OrderStep
  factory OrderStep.fromMap(Map<String, dynamic> map) {
    return OrderStep(step: map['step'], timestamp: map['timestamp']);
  }

  // Convert OrderStep to Firestore data
  Map<String, dynamic> toMap() {
    return {'step': step, 'timestamp': timestamp};
  }
}
