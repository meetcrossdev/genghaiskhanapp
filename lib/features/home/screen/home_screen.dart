import 'dart:developer';
import 'dart:ui';
import 'package:gzresturent/features/home/controller/category_controller.dart';
import 'package:gzresturent/features/home/screen/menu_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/ad_ons_controller.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/home/controller/menu_controller.dart';
import 'package:gzresturent/features/home/screen/categories_screen.dart';
import 'package:gzresturent/features/home/screen/notifications_screen.dart';
import 'package:gzresturent/features/home/screen/reservation_screen.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:gzresturent/models/ads_on.dart';
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
    // Watch the addon data from the provider
    var addonData = ref.watch(addonsFetchProvider).value;

    // Watch the menu fetch provider and build UI based on the current state
    return ref
        .watch(menuFetchProvider)
        .when(
          // If data is successfully loaded
          data: (data) {
            // Flatten all menu items into a single list
            final allItems = data.expand((menu) => menu.items).toList();

            // Categorize menu items for display
            final categorizedItems = categorizeMenuItems(data);

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    // Restaurant logo
                    Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ],
                ),
                centerTitle: true,

                // If user is logged in, show their loyalty points in a CircleAvatar
                leading:
                    ref.watch(userProvider) == null
                        ? Container() // Empty container if no user is logged in
                        : Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Center(
                              child: Text(
                                "${ref.watch(userProvider)!.loyaltyPoints.toString()} Gk Points",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                // Notification button
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      // Navigate to notification screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reservation button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Apptheme.buttonColor,
                          elevation: 1,
                          minimumSize: Size(double.infinity, 40.h),
                        ),
                        onPressed: () {
                          final today = DateTime.now().weekday;

                          // Prevent reservations on Monday and Sunday
                          if (today == DateTime.monday ||
                              today == DateTime.sunday) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "No reservation available for today.",
                                ),
                              ),
                            );
                            return;
                          }

                          // Navigate to the reservation screen
                          Navigator.of(
                            context,
                          ).pushNamed(ReservationScreen.routeName);
                        },
                        child: const Text(
                          'Make Reservation',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Promotional banner carousel
                      offerBanner(context),

                      const SizedBox(height: 16),

                      // Category chips row
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height > 600
                                ? 100.h
                                : 80.h,
                        child: ref
                            .watch(allcategoryProvider)
                            .when(
                              data: (categories) {
                                if (categories.isEmpty) {
                                  return const Center(
                                    child: Text('No categories found.'),
                                  );
                                }

                                // Horizontal list of category chips
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    return categoryChip(
                                      category.title,
                                      category.imageUrl,
                                      context,
                                    );
                                  },
                                );
                              },
                              loading:
                                  () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              error:
                                  (error, _) =>
                                      Center(child: Text('Error: $error')),
                            ),
                      ),

                      const SizedBox(height: 16),

                      // List of categorized menu sections
                      ...categorizedItems.entries.map((entry) {
                        return CategorySection(
                          categoryName: entry.key,
                          items: entry.value,
                          ref: ref,
                          data: addonData!, // Safe since data is already loaded
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },

          // Loading state
          loading:
              () => const Scaffold(
                body: Center(
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotatePulse,
                  ),
                ),
              ),

          // Error state
          error: (err, stack) {
            log('error is $err'); // Log the error for debugging
            return Scaffold(body: Center(child: Text('Error: $err')));
          },
        );
  }
}
//UI code for displaying the categories content
class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<MenuItem> items;
  final WidgetRef ref;
  final List<AddonModel> data;

  const CategorySection({
    required this.categoryName,
    required this.items,
    required this.ref,
    required this.data,
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
            categoryName == 'All-You-Care-To-Eat BBQ'
                ? '$categoryName \n(Only Available For Dine In)'
                : categoryName, // 🔹 Dynamic Category Name
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
                  showFoodDetailsBottomSheet(context, item, data, ref);
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
  List<AddonModel>? data,
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
                        if (ref.watch(userProvider) != null)
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: GestureDetector(
                              onTap: () async {
                                ref
                                    .read(
                                      userProfileControllerProvider.notifier,
                                    )
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
                    SizedBox(height: 10.h),

                    // Addons (Checkboxes)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Addons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 100.h,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: data!.length,
                          itemBuilder: (context, index) {
                            return _buildCheckboxOption(
                              data[index].title,
                              data[index].price,
                              selectedAddons,
                              setState,
                            );
                          },
                        ),
                      ),
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

Widget offerBanner(BuildContext context) {
  return FutureBuilder<DocumentSnapshot>(
    future:
        FirebaseFirestore.instance.collection('utility').doc('banner').get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width > 600 ? 150.h : 120.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (snapshot.hasError ||
          !snapshot.hasData ||
          !snapshot.data!.exists) {
        return const Text("Failed to load banner");
      }

      final imageUrl = snapshot.data!.get('imageUrl') as String;
      final buttonText = snapshot.data!.get('buttonText') as String;
      final title = snapshot.data!.get('title') as String;
      final description = snapshot.data!.get('description') as String;

      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.width > 600 ? 150.h : 125.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
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
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => MenuScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(buttonText, style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Category Chip Widget
Widget categoryChip(String label, String url, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CategoriesScreen(name: label)),
      );
    },
    child: Padding(
      padding: EdgeInsets.all(5.0.sp),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 30.r,
              backgroundImage: NetworkImage(url),
            ),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ],
        ),
      ),
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
