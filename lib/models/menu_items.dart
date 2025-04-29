import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gzresturent/models/ads_on.dart';

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
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool availability;
  final int stock;
  final List<String> ingredients;
  final int calories;
  final double rating;
  final bool isRecommended;
  final bool isSpicy;
  final double? discount;
  final List<AddonModel>? addons;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.availability,
    required this.stock,
    required this.ingredients,
    required this.calories,
    required this.rating,
    required this.isRecommended,
    required this.isSpicy,
    this.discount,
    this.addons,
  });

  // Convert to JSON (for Firestore or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'availability': availability,
      'stock': stock,
      'ingredients': ingredients,
      'calories': calories,
      'rating': rating,
      'isRecommended': isRecommended,
      'isSpicy': isSpicy,
      'discount': discount,
      'addons': addons?.map((addon) => addon.toJson()).toList(),
    };
  }

  // Convert from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String? ?? 'unknown_id',
      name: json['name'] as String? ?? 'Unknown Item',
      description: json['description'] as String? ?? 'No description available',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'Uncategorized',
      availability: json['availability'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
      ingredients: (json['ingredients'] as List?)?.cast<String>() ?? [],
      calories: json['calories'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isRecommended: json['isRecommended'] as bool? ?? false,
      isSpicy: json['isSpicy'] as bool? ?? false,
      discount: (json['discount'] as num?)?.toDouble(),
      addons:
          (json['addons'] as List?)
              ?.map((e) => AddonModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? availability,
    int? stock,
    List<String>? ingredients,
    int? calories,
    double? rating,
    bool? isRecommended,
    bool? isSpicy,
    double? discount,
    List<AddonModel>? addons,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      availability: availability ?? this.availability,
      stock: stock ?? this.stock,
      ingredients: ingredients ?? this.ingredients,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      isRecommended: isRecommended ?? this.isRecommended,
      isSpicy: isSpicy ?? this.isSpicy,
      discount: discount ?? this.discount,
      addons: addons ?? this.addons,
    );
  }
}




// Future<void> uploadMenu() async {
//   await Firebase.initializeApp();
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//  List<MenuModel> menu = [
//   MenuModel(
//     name: "Starters",
//     items: [
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "Shanghai Chili Wonton",
//         description: "Wonton filled with chicken, shrimp, pork, napa cabbage and green onion. Served with chili garlic sauce.",
//         price: 14.0,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_254-Edit.jpg",
//         options: [],
//       ),
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "Scallion Biscuit",
//         description: "Savory, pan-fried Chinese flatbread seasoned with scallions.",
//         price: 12.0,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_452-Edit.jpg",
//         options: [],
//       ),
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "House Spiced Chicken Wings",
//         description: "Marinated wings, fried and coated with green onion and peppercorn salt.",
//         price: 13.0,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_428-Edit.jpg",
//         options: [],
//       ),
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "Sweet Potato Fries",
//         description: "Crispy golden sweet potato fries served with a trio of flavorful dips— sriracha aioli, our signature awesome sauce, and ketchup.",
//         price: 6.5,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200409_genghis_Khan_476-Edit.jpg",
//         options: [],
//       ),
//     ],
//   ),
//   MenuModel(
//     name: "Regular & Vegetarian Entrées",
//     items: [
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "Basil Chicken Pot",
//         description: "Stir-fried chicken, ginger, scallion, fresh basil, garlic, soy sauce and wine simmered in a clay pot.",
//         price: 19.75,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_095-Edit.jpg",
//         options: [],
//       ),
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "General Tso’s Chicken",
//         description: "Breaded white meat chicken, marinated in milk, seasoned with secret spices, lightly breaded, fried, and tossed in a rich brown sauce.",
//         price: 18.5,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200409_genghis_Khan_275-Edit.jpg",
//         options: [],
//       ),
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "Seafood Curry with Eggplant",
//         description: "Shrimp, scallops, squid, fish, mussels, chicken, and eggplant in a creamy curry sauce.",
//         price: 19.50,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_452-Edit.jpg",
//         options: [],
//       ),
//     ],
//   ),
//   MenuModel(
//     name: "Beverages",
//     items: [
//       MenuItem(
//         id: firestore.collection('menu').doc().id,
//         name: "House Egg Roll",
//         description: "Crispy golden egg roll filled with seasoned vegetables and chicken.",
//         price: 9.0,
//         imageUrl: "https://gkbbq.com/wp-content/uploads/2020/08/200415_Genghis_Khan_095-Edit.jpg",
//         options: [],
//       ),
//     ],
//   ),
// ];


//   for (var category in menu) {
//     await firestore.collection("menu").doc(category.name).set(category.toJson());
//   }

//   print("Menu uploaded successfully!");
// }
