import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/constant/themenotfier.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/home/screen/checkout_screen.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CheckoutScreens extends ConsumerStatefulWidget {
  const CheckoutScreens({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CheckoutScreensState();
}

class _CheckoutScreensState extends ConsumerState<CheckoutScreens> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    var user = ref.watch(userProvider);
    var tax = ref.watch(taxStreamProvider);
    if (user == null) {
      return Container();
    }
    var totalAmount = ref.watch(cartTotalProvider(user.id));

    return ref
        .watch(cartProvider(user.id))
        .when(
          data: (data) {
            if (data.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  leading: Container(),

                  elevation: 0,
                  title: const Text(
                    "Your order",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                ),
                body: Center(child: Text('No item in cart')),
              );
            }
            return Scaffold(
              appBar: AppBar(
                leading: Container(),

                elevation: 0,
                title: const Text(
                  "Your order",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Please check your order",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Order List
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Item Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.productImage,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Item Name & Quantity Controls
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          // Quantity Buttons
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              var quantity = item.quantity;
                                              log(
                                                'product id is ${item.productId}',
                                              );
                                              setState(() {
                                                if (quantity > 1) {
                                                  quantity--;
                                                  ref
                                                      .read(
                                                        cartControllerProvider
                                                            .notifier,
                                                      )
                                                      .updateCartItemQuantity(
                                                        userId:
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                        productName:
                                                            item.productName,
                                                        quantity: quantity,
                                                        context: context,
                                                      );
                                                }
                                              });
                                            },
                                          ),
                                          Container(
                                            width: 30,
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${item.quantity}",
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          //quantity button increase
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              var quantity = item.quantity;
                                              log(
                                                'product id is ${item.productId}',
                                              );
                                              setState(() {
                                                quantity++;
                                                ref
                                                    .read(
                                                      cartControllerProvider
                                                          .notifier,
                                                    )
                                                    .updateCartItemQuantity(
                                                      userId:
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                      productName:
                                                          item.productName,
                                                      quantity: quantity,
                                                      context: context,
                                                    );
                                              });
                                            },
                                          ),
                                          Spacer(),
                                          item.notes != null
                                              ? IconButton(
                                                onPressed: () {
                                                  if (item.notes != null) {
                                                    showAdditionalNotesDialog(
                                                      context,
                                                      item.notes!,
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.chat),
                                              )
                                              : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Price & Remove Button
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${item.price * item.quantity}",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .removeFromCart(
                                                userId:
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                productId: item.productName,
                                                context: context,
                                              );
                                          // orders.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Total Amount
                    const Divider(),
                    tax.when(
                      data: (tax) {
                        final finalTotal =
                            totalAmount + (totalAmount * tax / 100);
                        //    totalAmount = finalTotal;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Tax.",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "%${tax} ",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total amount:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "\$${finalTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (err, _) => Text(
                            "\$${totalAmount.toStringAsFixed(2)}", // fallback to base amount
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),

                    // Buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          CheckoutScreen.routeName,
                          arguments: {
                            'cartItems': data, // List<CartItemModel>
                            'total': totalAmount, // double
                          },
                        );

                        //  uploadMenu();
                      },
                      child: const Text(
                        "Place an order",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
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

  //dialog to display additional notes to user

  void showAdditionalNotesDialog(BuildContext context, String additionalNotes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Additional Notes"),
          content: Text(
            additionalNotes.isNotEmpty
                ? additionalNotes
                : "No additional notes provided.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle()),
            ),
          ],
        );
      },
    );
  }
}
