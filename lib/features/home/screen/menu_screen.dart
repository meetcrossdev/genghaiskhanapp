import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/ad_ons_controller.dart';
import 'package:gzresturent/features/home/controller/menu_controller.dart';
import 'package:gzresturent/features/home/screen/home_screen.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:gzresturent/models/ads_on.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../controller/cart_controller.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<String?>((ref) => null);

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the current search query from provider
    final searchQuery = ref.watch(searchQueryProvider);

    // Fetch addon data (e.g., extra toppings or customization options)
    var addonData = ref.watch(addonsFetchProvider).value;

    // Watch menu data and react to its loading/data/error states
    return ref
        .watch(menuFetchProvider)
        .when(
          data: (data) {
            // Flatten all menu items from the fetched menus into a single list
            final allItems = data.expand((menu) => menu.items).toList();

            // Filter items based on the current search query
            List<MenuItem> filteredOrders =
                allItems.where((menu) {
                  final matchesSearch =
                      searchQuery.isEmpty ||
                      menu.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );
                  return matchesSearch;
                }).toList();

            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // App logo
                      Image.asset('assets/images/logo.png', height: 70.h),
                      SizedBox(height: 10),

                      // Main heading
                      Text(
                        "Main Menu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Instructional subtitle
                      Text(
                        "Please add the product from the list below to your cart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Search bar for filtering menu items
                      SearchBarWithFilters(
                        onSearch: (p0) {
                          // Update the search query state
                          ref.read(searchQueryProvider.notifier).state = p0;
                        },
                        controller: controller,
                      ),
                      SizedBox(height: 10),

                      // Display filtered menu items in a grid layout
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                // Adjust grid layout based on screen width
                                childAspectRatio:
                                    MediaQuery.of(context).size.width > 600
                                        ? 1.5.sp
                                        : 0.53.sp,
                              ),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final item = filteredOrders[index];

                            return GestureDetector(
                              onTap: () {
                                // Show food item details in a bottom sheet
                                showFoodDetailsBottomSheet(
                                  context,
                                  item,
                                  addonData,
                                  ref,
                                );
                              },
                              child: MenuItemWidget(
                                item: item,
                                onAddToCart: (quantity, note) {
                                  // Check if user is logged in
                                  if (FirebaseAuth.instance.currentUser ==
                                      null) {
                                    showSnackBar(
                                      context,
                                      'Please login to add item to cart',
                                    );
                                    return;
                                  }

                                  // Add item to cart via controller
                                  final cartController = ref.read(
                                    cartControllerProvider.notifier,
                                  );
                                  cartController.addToCart(
                                    cartItem: CartItemModel(
                                      userId:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                      productId: item.id,
                                      productName: item.name,
                                      productImage: item.imageUrl,
                                      price: item.price,
                                      quantity: quantity,
                                      notes: note,
                                    ),
                                    context: context,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },

          // Show loading indicator while menu data is being fetched
          loading:
              () => const Scaffold(
                body: Center(
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotatePulse,
                  ),
                ),
              ),

          // Show error message if menu fetch fails
          error: (err, stack) {
            log('error is $err'); // Log error to console
            return Scaffold(body: Center(child: Text('Error: $err')));
          },
        );
  }
}


//This code display the menuitem we see on the home menu 
class MenuItemWidget extends StatefulWidget {
  final MenuItem item;
  final Function(int quantity, String note) onAddToCart;

  const MenuItemWidget({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  _MenuItemWidgetState createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  int quantity = 1;
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(0.2),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        widget.item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120.h,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200, // Set to desired max width
                  child: Text(
                    widget.item.name,
                    style: TextStyle(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // optional: limit number of lines
                  ),
                ),
              ),

              // Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "\$${widget.item.price}",
                    style: TextStyle(color: Colors.red),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //quantity decrease 
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.minus_circle),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                      ),
                      Text(quantity.toString()),
                          //quantity incrase 
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.add_circled),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onAddToCart(quantity, noteController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.buttonColor,
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // SizedBox(height: 7.h),
            ],
          ),
        ),
      ),
    );
  }

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
                                  ref.read(userProvider.notifier).update((
                                    user,
                                  ) {
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Colors.grey.shade100, // ✅ Light background
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
//handle the checkbox for addons
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
//user can mention their notes here
  void showCustomDialog(
    BuildContext context,
    TextEditingController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Additional Notes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Type here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Apptheme.buttonColor,
              ),
              onPressed: () {
                // Save or process input
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

//full code for the search bar widget 

class SearchBarWithFilters extends StatelessWidget {
  final TextEditingController controller;

  final Function(String) onSearch;

  SearchBarWithFilters({
    super.key,
    required this.onSearch,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onSearch,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search ",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
    );
  }
}
