class RefundRequest {
  final String id;
  final String paymentIntentId;
  final String userId;
  final String orderId;
  final int amount;
  final String reason;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final String orderTrackid;
  final String topic;
  final String? adminMessage;

  RefundRequest({
    required this.id,
    required this.paymentIntentId,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.orderTrackid,
    required this.topic,
    this.adminMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentIntentId': paymentIntentId,
      'userId': userId,
      'orderId': orderId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'orderTrackId': orderTrackid,
      'topic': topic,
      'adminMessage': adminMessage,
    };
  }

  factory RefundRequest.fromMap(Map<String, dynamic> map) {
    return RefundRequest(
      id: map['id'],
      paymentIntentId: map['paymentIntentId'],
      userId: map['userId'],
      orderId: map['orderId'],
      amount: map['amount'],
      reason: map['reason'],
      status: map['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      orderTrackid: map['orderTrackId'],
      topic: map['topic'],
      adminMessage: map['adminMessage'],
    );
  }
}
