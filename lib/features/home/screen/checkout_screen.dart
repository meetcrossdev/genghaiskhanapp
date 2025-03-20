import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:uuid/uuid.dart';

import '../../../models/ordermenu.dart';
import '../../../models/ordermodal.dart';
import '../controller/order_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.total,
    required this.cartitem,
  });
  static const routeName = '/cart-detail-screen';
  final double total;
  final List<CartItemModel> cartitem;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController nameController = TextEditingController(
    text: "Vanessa Jonson",
  );
  final TextEditingController emailController = TextEditingController(
    text: "vanessajonson@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "+01234567890",
  );
  final TextEditingController addressController = TextEditingController(
    text: "Boston",
  );
  final TextEditingController deliveryTimeController = TextEditingController(
    text: "Additional Notes",
  );

  String selectedDelivery = "Home Delivery"; // Default selected option

  @override
  Widget build(BuildContext context) {
    void placeOrder(BuildContext context) async {
      List<OrderItem> orderItems =
          widget.cartitem.map((cartItem) {
            return OrderItem(
              id: cartItem.productId,
              name: cartItem.productName,
              quantity: cartItem.quantity,
              price: cartItem.price,
              imageUrl: cartItem.productImage,
            );
          }).toList();

      var user = ref.read(userProvider);
      final orderId = const Uuid().v4(); // Generate a unique order ID

      // 🔹 Generate a random 5-digit number for tracking ID
      int randomNumber =
          Random().nextInt(90000) + 10000; // Ensures a 5-digit number

      // 🔹 Get the current date in YYYYMMDD format
      String formattedDate = DateTime.now()
          .toUtc()
          .toIso8601String()
          .substring(0, 10)
          .replaceAll('-', '');

      // 🔹 Generate the tracking ID
      String trackId =
          "GKR$randomNumber$formattedDate"; // Example: GKR1234520250319

      List<OrderStep> orderSteps = [
        OrderStep(
          step: "Order Received",
          timestamp: Timestamp.fromDate(DateTime.now()),
        ),
        OrderStep(step: "Order In Making", timestamp: null),
        OrderStep(step: "Order Ready", timestamp: null),
        OrderStep(step: "On the way", timestamp: null),
        OrderStep(step: "Delivered", timestamp: null),
      ];

      final order = OrderModel(
        id: orderId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        items: orderItems,
        totalPrice: widget.total,
        status: "Order Received",
        createdAt: Timestamp.fromDate(DateTime.now()),
        completedAt: null,
        deliveryAddress: user!.address ?? 'User Address go here',
        paymentMethod: '',
        additionalNotes: '',
        transactionId: 'Trans_id',
        orderSteps: orderSteps,
        trackid: trackId, // 🔥 Assigning the generated tracking ID
      );

      ref.read(orderControllerProvider.notifier).placeOrder(order, context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WS",
          style: TextStyle(
            color: Colors.red,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.person),
          Stack(
            children: [
              Icon(Icons.shopping_cart),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 8,
                  child: Text(
                    "+${widget.cartitem.length}",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "Placing an order",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Fantasy",
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Please fill in your details",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    deliverySelection(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Delivery Info',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp,
                            ),
                          ),
                          _buildTextField(nameController),
                          _buildTextField(emailController),
                          _buildTextField(phoneController),
                          _buildTextField(addressController),
                          _buildTextField(deliveryTimeController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Apptheme.logoInsideColor,
                  ),
                ),
                Text(
                  "${widget.total} \$",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  placeOrder(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40.h),
                  backgroundColor: Apptheme.buttonColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 80,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Place Order",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  deliverySelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Deliver to + Add Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Deliver to",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Add Address action
                },
                child: const Text(
                  "Add Address",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // No contact info warning
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 5),
              const Text(
                "No contact info added",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Delivery Type title
          const Text(
            "Delivery Type",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Home Delivery Selection
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDelivery = "Home Delivery";
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    selectedDelivery == "Home Delivery"
                        ? Colors.red.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      selectedDelivery == "Home Delivery"
                          ? Colors.red
                          : Colors.grey.shade300,
                  width: selectedDelivery == "Home Delivery" ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedDelivery == "Home Delivery"
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Home Delivery",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "10.00 \$",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Take Away Selection
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDelivery = "Take Away";
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    selectedDelivery == "Take Away"
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      selectedDelivery == "Take Away"
                          ? Colors.blue
                          : Colors.grey.shade300,
                  width: selectedDelivery == "Take Away" ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedDelivery == "Take Away"
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Take Away",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Free",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,

        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
