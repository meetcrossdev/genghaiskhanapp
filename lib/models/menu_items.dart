import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MenuModel {
  final String name;
  final List<MenuItem> items;

  MenuModel({required this.name, required this.items});

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      name: json['name'] ?? 'Unknown Category',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class MenuItem {
  final String id; // 🔹 Added ID field
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final List<String> options;

  MenuItem({
    required this.id, // 🔹 ID is now required
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? FirebaseFirestore.instance.collection('menu').doc().id, // 🔹 Auto-generate if missing
      name: json['name'] ?? 'Unknown Item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      description: json['description'] ?? 'No description available',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // 🔹 Ensure ID is stored
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'options': options,
    };
  }
}


Future<void> uploadMenu() async {
  await Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

 List<MenuModel> menu = [
  MenuModel(
    name: "Starters",
    items: [
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "Shanghai Chili Wonton",
        description: "Wonton filled with chicken, shrimp, pork, napa cabbage and green onion. Served with chili garlic sauce.",
        price: 14.0,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_254-Edit.jpg",
        options: [],
      ),
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "Scallion Biscuit",
        description: "Savory, pan-fried Chinese flatbread seasoned with scallions.",
        price: 12.0,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_452-Edit.jpg",
        options: [],
      ),
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "House Spiced Chicken Wings",
        description: "Marinated wings, fried and coated with green onion and peppercorn salt.",
        price: 13.0,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_428-Edit.jpg",
        options: [],
      ),
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "Sweet Potato Fries",
        description: "Crispy golden sweet potato fries served with a trio of flavorful dips— sriracha aioli, our signature awesome sauce, and ketchup.",
        price: 6.5,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200409_genghis_Khan_476-Edit.jpg",
        options: [],
      ),
    ],
  ),
  MenuModel(
    name: "Regular & Vegetarian Entrées",
    items: [
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "Basil Chicken Pot",
        description: "Stir-fried chicken, ginger, scallion, fresh basil, garlic, soy sauce and wine simmered in a clay pot.",
        price: 19.75,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_095-Edit.jpg",
        options: [],
      ),
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "General Tso’s Chicken",
        description: "Breaded white meat chicken, marinated in milk, seasoned with secret spices, lightly breaded, fried, and tossed in a rich brown sauce.",
        price: 18.5,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200409_genghis_Khan_275-Edit.jpg",
        options: [],
      ),
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "Seafood Curry with Eggplant",
        description: "Shrimp, scallops, squid, fish, mussels, chicken, and eggplant in a creamy curry sauce.",
        price: 19.50,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_452-Edit.jpg",
        options: [],
      ),
    ],
  ),
  MenuModel(
    name: "Beverages",
    items: [
      MenuItem(
        id: firestore.collection('menu').doc().id,
        name: "House Egg Roll",
        description: "Crispy golden egg roll filled with seasoned vegetables and chicken.",
        price: 9.0,
        imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_095-Edit.jpg",
        options: [],
      ),
    ],
  ),
];


  for (var category in menu) {
    await firestore.collection("menu").doc(category.name).set(category.toJson());
  }

  print("Menu uploaded successfully!");
}
