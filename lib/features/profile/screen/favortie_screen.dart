import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../models/cart.dart';
import '../../auth/controller/auth_controller.dart';
// A ConsumerStatefulWidget that displays a list of user's favorite items
class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});

  // Route name for navigation
  static const routeName = '/favorite-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the userFavoritesProvider with the current user's UID
    return ref
        .watch(userFavoritesProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
          // When data is successfully fetched
          data: (data) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Favourites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  // Expandable section containing the favorite items grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          // Grid view for displaying favorite food items
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
                            shrinkWrap: true, // Let GridView take minimal height
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 items per row
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      0.47.sp, // Controls item height-to-width ratio
                                ),
                            itemCount: data.length, // Total favorite items
                            itemBuilder: (context, index) {
                              // Render each favorite item using a reusable FoodCard widget
                              return FoodCard(menuItem: data[index], ref: ref);
                            },
                          ),

                          SizedBox(height: 20),

                          // Suggestive message when user wants to explore more
                          Text(
                            "Looking for something else?",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),

                          // Highlight suggestion to explore categories
                          Text.rich(
                            TextSpan(
                              text: "try searching to explore more  ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Categories",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 100), // Extra spacing at the bottom
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },

          // Display loading animation while fetching favorites
          loading: () => const Scaffold(
            body: Center(
              child: LoadingIndicator(
                indicatorType: Indicator.ballClipRotatePulse,
              ),
            ),
          ),

          // Display error message if fetching fails
          error: (err, stack) {
            log('error is ${err}');
            return Scaffold(body: Center(child: Text('Error: $err')));
          },
        );
  }
}


class FoodCard extends StatefulWidget {
  const FoodCard({super.key, required this.menuItem, required this.ref});
  final MenuItem menuItem;
  final WidgetRef ref;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  // Holds the current quantity selected for the item
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Main card container with rounded corners and subtle shadow
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Provide height space for the image section
              SizedBox(height: 175.h),

              // Display the food image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.menuItem.imageUrl,
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Favorite button positioned at the top right corner
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    // Update user favorites in backend
                    widget.ref
                        .read(userProfileControllerProvider.notifier)
                        .updateUserFavorite(
                          widget.menuItem.id,
                          FirebaseAuth.instance.currentUser!.uid,
                          context,
                        );

                    // Update userProvider locally to reflect favorite change
                    widget.ref.read(userProvider.notifier).update((user) {
                      if (user == null) return null;

                      List<String> updatedFavorites = List<String>.from(
                        user.favoriteDishes,
                      );

                      if (updatedFavorites.contains(widget.menuItem.id)) {
                        updatedFavorites.remove(widget.menuItem.id);
                      } else {
                        updatedFavorites.add(widget.menuItem.id);
                      }

                      return user.copyWith(favoriteDishes: updatedFavorites);
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                ),
              ),

              // Quantity selector at the bottom-right corner of the image
              Positioned(
                bottom: 1,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    color: Apptheme.buttonColor,
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  child: Row(
                    children: [
                      // Decrease quantity button
                      InkWell(
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                        child: QuantityButton(icon: Icons.remove),
                      ),
                      SizedBox(width: 5),

                      // Show current quantity
                      Text(
                        _quantity.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),

                      // Increase quantity button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        child: QuantityButton(icon: Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Display item name and verified icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.menuItem.name,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.verified, color: Colors.green, size: 18),
              ],
            ),
          ),

          Spacer(), // Pushes the price and add-to-cart button to the bottom

          // Price and "Add To Cart" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show price
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Text(
                  '${widget.menuItem.price} \$',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Add the item with selected quantity to the cart
              TextButton(
                onPressed: () {
                  final cartController = widget.ref.read(
                    cartControllerProvider.notifier,
                  );
                  cartController.addToCart(
                    cartItem: CartItemModel(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      productId: widget.menuItem.id,
                      productName: widget.menuItem.name,
                      productImage: widget.menuItem.imageUrl,
                      price: widget.menuItem.price,
                      quantity: _quantity,
                    ),
                    context: context,
                  );
                },
                child: Text(
                  'Add To Cart',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final IconData icon;
  QuantityButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 14,
      child: Icon(icon, color: Apptheme.logoOutsideColor, size: 18),
    );
  }
}
