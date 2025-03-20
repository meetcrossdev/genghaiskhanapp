class OrderItem {
  final String id; // Item ID
  final String name; // Item name
  final int quantity; // Quantity ordered
  final double price; // Price per item
  final String imageUrl; // Item image

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
