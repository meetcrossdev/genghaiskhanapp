import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/home/controller/menu_controller.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../controller/cart_controller.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(menuFetchProvider)
        .when(
          data: (data) {
            final allItems = data.expand((menu) => menu.items).toList();
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', height: 70.h),
                      SizedBox(height: 10),
                      Text(
                        "Main Menu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please add the product from the list below to your cart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.56.sp,
                              ),
                          itemCount: allItems.length,
                          itemBuilder: (context, index) {
                            final item = allItems[index];
                            return MenuItemWidget(
                              item: item,
                              onAddToCart: (quantity, note) {
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
                                    notes: note,
                                  ),
                                  context: context,
                                );
                              },
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.2),
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
                IconButton(
                  onPressed: () {
                    showCustomDialog(context, noteController);
                  },
                  icon: Icon(Icons.info, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.item.name,
                style: TextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(CupertinoIcons.add_circled),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                    Text(quantity.toString()),
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
              child: Text('Add to Cart', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

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
