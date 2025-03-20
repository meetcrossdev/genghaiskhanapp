class CartItemModel {
  final String userId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? notes;

  CartItemModel({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toMap(String? cartId) {
    return {
      'userId': cartId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'notes':notes,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      userId: map['userId'],
      productId: map['productId'],
      productName: map['productName'],
      productImage: map['productImage'],
      price: map['price'],
      quantity: map['quantity'],
      notes:map['notes'],
    );
  }
}
