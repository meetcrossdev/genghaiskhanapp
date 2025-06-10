import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/home/controller/menu_controller.dart';
import 'package:gzresturent/features/home/screen/menu_screen.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:loading_indicator/loading_indicator.dart';
// Stateful widget using Riverpod's ConsumerStatefulWidget to access providers
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key, required this.name});
  
  // Category name passed to this screen
  final String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar showing the selected category name
      appBar: AppBar(title: Text(widget.name)),

      // Body with padding
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Heading text for menu section
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Menu Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
            ),

            // Watch menuFetchProvider (async state) to get menu data
            ref.watch(menuFetchProvider).when(
              // Handle successful data load
              data: (data) {
                // Find the category matching the passed name (case-insensitive)
                final selectedCategoryModel = data.firstWhere(
                  (menu) =>
                      menu.name.toLowerCase() == widget.name.toLowerCase(),
                  orElse: () => MenuModel(name: 'Empty', items: []),
                );

                // Extract items from the selected category
                final filteredItems = selectedCategoryModel.items;

                // Display items in a responsive grid layout
                return Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      // Adjust child aspect ratio based on screen width
                      childAspectRatio:
                          MediaQuery.of(context).size.width > 600
                              ? 1.5.sp
                              : 0.56.sp,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      // Render each menu item using a custom widget
                      return MenuItemWidget(
                        item: item,
                        // Handle 'Add to Cart' button action
                        onAddToCart: (quantity, note) {
                          // Check if the user is logged in
                          if (FirebaseAuth.instance.currentUser == null) {
                            showSnackBar(
                              context,
                              'Please login to add item to cart',
                            );
                            return;
                          }

                          // Get cart controller and add item to cart
                          final cartController = ref.read(
                            cartControllerProvider.notifier,
                          );
                          cartController.addToCart(
                            cartItem: CartItemModel(
                              userId: FirebaseAuth.instance.currentUser!.uid,
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
                      );
                    },
                  ),
                );
              },

              // Show loading indicator while data is being fetched
              loading: () => const Scaffold(
                body: Center(
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotatePulse,
                  ),
                ),
              ),

              // Show error message if data fetch fails
              error: (err, stack) {
                log('error is ${err}');
                return Scaffold(
                  body: Center(child: Text('Error: $err')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
