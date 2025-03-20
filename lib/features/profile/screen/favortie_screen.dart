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

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});
  static const routeName = '/favorite-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(userFavoritesProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          // FoodCard(),
                          GridView.builder(
                            physics:
                                NeverScrollableScrollPhysics(), // Prevents internal scrolling
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columns
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      0.47.sp, // Adjust for better fit
                                ),
                            itemCount: data.length, // Show exactly 2 items
                            itemBuilder: (context, index) {
                              return FoodCard(menuItem: data[index], ref: ref);
                            },
                          ),

                          SizedBox(height: 20),
                          Text(
                            "Looking for something else?",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
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
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
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

class FoodCard extends StatefulWidget {
  const FoodCard({super.key, required this.menuItem, required this.ref});
  final MenuItem menuItem;
  final WidgetRef ref;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  int _quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
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
              SizedBox(height: 175.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.menuItem.imageUrl,
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    widget.ref
                        .read(userProfileControllerProvider.notifier)
                        .updateUserFavorite(
                          widget.menuItem.id,
                          FirebaseAuth.instance.currentUser!.uid,
                          context,
                        );

                    // Manually trigger a state update for userProvider
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
                      Text(
                        _quantity.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
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
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Text(
                  '${widget.menuItem.price} \$',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
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
