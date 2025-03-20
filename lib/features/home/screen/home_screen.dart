import 'dart:developer';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/home/controller/menu_controller.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../models/cart.dart';
import '../../../models/menu_items.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, List<MenuItem>> categorizeMenuItems(List<MenuModel> data) {
    return {for (var category in data) category.name: category.items};
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(menuFetchProvider)
        .when(
          data: (data) {
            final allItems = data.expand((menu) => menu.items).toList();
            final categorizedItems = categorizeMenuItems(data);
            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    // const Text(
                    //   "Location",
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const Icon(Icons.location_on, color: Colors.red, size: 18),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       "172 Grand St, NY",
                    //       style: GoogleFonts.poppins(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ],
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        height: 40.h,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search Food, groceries, drink, etc.",
                            hintStyle: TextStyle(fontSize: 12.sp),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: const Icon(Icons.tune),
                            //  filled: true,
                            //  fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // Removes border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Carousel Banner
                      offerBanner(),

                      const SizedBox(height: 16),

                      // Categories List
                      SizedBox(
                        height: 80.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            categoryChip("Steak"),
                            categoryChip("Desserts"),
                            categoryChip("Breakfast"),
                            categoryChip("Fast Food"),
                            categoryChip("Sea Food"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...categorizedItems.entries.map((entry) {
                        return CategorySection(
                          categoryName: entry.key,
                          items: entry.value,
                          ref: ref,
                        );
                      }).toList(),

                      // Food Grid
                      // SizedBox(
                      //   height: 240.h,
                      //   child: ListView.builder(
                      //     shrinkWrap: true,

                      //     itemCount: allItems.length,
                      //     scrollDirection: Axis.horizontal,
                      //     itemBuilder: (context, index) {
                      //       var item = allItems[index];

                      //       return GestureDetector(
                      //         onTap: () {
                      //           showFoodDetailsBottomSheet(context);
                      //         },
                      //         child: foodCard(
                      //           "Flavorful Fried Rice Fiesta",
                      //           "Karina Anindya",
                      //         ),
                      //       );
                      //       //  foodCard("Delicious Breakfast", "Karina Anindya"),
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading:
              () => const Scaffold(
                body: Center(
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotatePulse,
                  ),
                ),
              ),
          error: (err, stack) {
            log('error is ${err}');
            return Scaffold(body: Center(child: Text('Error: $err')));
          },
        );
  }
}

class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<MenuItem> items;
  final WidgetRef ref;

  const CategorySection({
    required this.categoryName,
    required this.items,
    required this.ref,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            categoryName, // 🔹 Dynamic Category Name
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180, // Adjust height if needed
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var item = items[index];

              return GestureDetector(
                onTap: () {
                  showFoodDetailsBottomSheet(context, item, ref);
                },
                child: foodCard(
                  item.name,
                  item.price.toString(),
                  item.imageUrl,
                ), // 🔹 Dynamic Item Name
              );
            },
          ),
        ),
      ],
    );
  }
}

List<String> selectedAddons = [];
void showFoodDetailsBottomSheet(
  BuildContext context,
  MenuItem item,
  WidgetRef ref,
) {
  final TextEditingController controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      int quantity = 1;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              // padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image & Favorite Icon
                    Stack(
                      children: [
                        SizedBox(height: 210.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.imageUrl,
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: GestureDetector(
                            onTap: () async {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .updateUserFavorite(
                                    item.id,
                                    FirebaseAuth.instance.currentUser!.uid,
                                    context,
                                  );

                              // Manually trigger a state update for userProvider
                              ref.read(userProvider.notifier).update((user) {
                                if (user == null) return null;

                                List<String> updatedFavorites =
                                    List<String>.from(user.favoriteDishes);

                                if (updatedFavorites.contains(item.id)) {
                                  updatedFavorites.remove(item.id);
                                } else {
                                  updatedFavorites.add(item.id);
                                }

                                return user.copyWith(
                                  favoriteDishes: updatedFavorites,
                                );
                              });

                              setState(() {}); // Refresh bottom sheet UI
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                ref
                                        .watch(userProvider)!
                                        .favoriteDishes
                                        .contains(item.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2.h,
                          right: 10.w,
                          left: 10.w,
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15.sp),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.sp),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item.price} \$",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,

                        decoration: InputDecoration(
                          hintText: 'Additional Notes',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // ✅ Rounded corners
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ), // ✅ Highlight on focus
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100, // ✅ Light background
                        ),
                      ),
                    ),

                    // Borhani Options (Radio Buttons)
                    // Padding(
                    //   padding: EdgeInsets.all(10.0.sp),
                    //   child: _buildOptionSection(context, "Borhani", [
                    //     _buildRadioOption("1 ltr", 120.0),
                    //     _buildRadioOption("half", 60.0),
                    //   ], isOptional: true),
                    // ),

                    // Addons (Checkboxes)
                    Padding(
                      padding: EdgeInsets.all(10.0.sp),
                      child: _buildOptionSection(context, "Addons", [
                        _buildCheckboxOption(
                          "Coke",
                          5.00,
                          selectedAddons,
                          setState,
                        ),
                        _buildCheckboxOption(
                          "Water",
                          15.00,
                          selectedAddons,
                          setState,
                        ),
                      ], isOptional: true),
                    ),

                    // Total Price
                    Padding(
                      padding: EdgeInsets.all(10.0.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "${item.price} \$",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity Selector & Add to Cart Button
                    Padding(
                      padding: EdgeInsets.all(10.0.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity Selector
                          Container(
                            decoration: BoxDecoration(
                              color: Apptheme.logoInsideColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    color: Apptheme.logoOutsideColor,
                                  ),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Apptheme.logoOutsideColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Add to Cart Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Apptheme.buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                showSnackBar(
                                  context,
                                  'Please login to add item to cart',
                                );
                                return;
                              }
                              final cartController = ref.read(
                                cartControllerProvider.notifier,
                              );
                              cartController.addToCart(
                                cartItem: CartItemModel(
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  productId: item.id,
                                  productName: item.name,
                                  productImage: item.imageUrl,
                                  price: item.price,
                                  quantity: quantity,
                                  notes: controller.text,
                                ),
                                context: context,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// Helper Widget for Radio Options
Widget _buildRadioOption(String title, double price) {
  return ListTile(
    leading: Radio(value: title, groupValue: "", onChanged: (value) {}),
    title: Text(title),
    trailing: Text("+${price.toStringAsFixed(2)} \$"),
  );
}

// Widget _buildCheckboxOption(
//   String title,
//   double price,
//   List<String> selectedAddons,
//   void Function(void Function()) setState,
// ) {
//   return CheckboxListTile(
//     title: Text(title),
//     subtitle: Text("\$${price.toStringAsFixed(2)}"),
//     value: selectedAddons.contains(title),
//     onChanged: (bool? value) {
//       setState(() {
//         if (value == true) {
//           selectedAddons.add(title);
//         } else {
//           selectedAddons.remove(title);
//         }
//       });
//     },
//   );
// }

// Helper Widget for Checkbox Options
Widget _buildCheckboxOption(
  String title,
  double price,
  List<String> selectedAddons,
  void Function(void Function()) setState,
) {
  return ListTile(
    leading: Checkbox(
      value: selectedAddons.contains(title),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedAddons.add(title);
          } else {
            selectedAddons.remove(title);
          }
        });
      },
    ),
    title: Text(title),
    trailing: Text("${price.toStringAsFixed(2)} \$"),
  );
}

// Helper Widget for Section Titles
Widget _buildOptionSection(
  BuildContext context,
  String title,
  List<Widget> options, {
  bool isOptional = false,
}) {
  return Material(
    borderRadius: BorderRadius.circular(15),
    elevation: 5,
    child: Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        //color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (isOptional)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Optional",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Column(children: options),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

// Offer Banner Widget
Widget offerBanner() {
  return Container(
    width: double.infinity,
    height: 120.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: const DecorationImage(
        image: NetworkImage(
          "https://st4.depositphotos.com/3300441/24943/i/450/depositphotos_249433898-stock-photo-assorted-chinese-dishes.jpg",
        ),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Recipe",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Order \$20+ & get a discount!",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text("Order Now", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    ),
  );
}

// Category Chip Widget
Widget categoryChip(String label) {
  return Padding(
    padding: EdgeInsets.all(5.0.sp),
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 30.r,
          backgroundImage: NetworkImage(
            'https://static.vecteezy.com/system/resources/thumbnails/036/397/536/small/ai-generated-chinese-food-spicy-food-isolated-on-transparent-background-png.png',
          ),
        ),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
        ),
      ],
    ),
  );
}

// Food Card Widget
Widget foodCard(String title, String author, String image) {
  return SizedBox(
    height: 240,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(image, height: 240.h, width: 250.w, fit: BoxFit.cover),
          Positioned(
            top: 10, // Adjust positioning as needed
            left: 10, // Adjust positioning as needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                30,
              ), // Rounded corners for pill shape
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ), // High blur effect
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ), // Inner padding
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.2,
                    ), // Transparent black for glass effect
                    borderRadius: BorderRadius.circular(30), // Match pill shape
                  ),
                  child: Text(
                    'Breakfast',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "at \$${author}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
