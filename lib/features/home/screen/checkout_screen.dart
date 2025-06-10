import 'dart:convert';
import 'dart:math';
import 'dart:developer' as log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:gzresturent/features/profile/screen/map_screen.dart';
import 'package:gzresturent/main.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:gzresturent/services/payment_services.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../models/ordermenu.dart';
import '../../../models/ordermodal.dart';
import '../controller/order_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  CheckoutScreen({super.key, required this.total, required this.cartitem});
  static const routeName = '/cart-detail-screen';
  double total;

  final List<CartItemModel> cartitem;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  TextEditingController nameController = TextEditingController(
    text: "Vanessa Jonson",
  );
  TextEditingController emailController = TextEditingController(
    text: "vanessajonson@gmail.com",
  );
  TextEditingController phoneController = TextEditingController(
    text: "+01234567890",
  );
  TextEditingController addressController = TextEditingController(
    text: "address(Optional)",
  );
  TextEditingController additionalNotesController = TextEditingController(
    text: "Additional Notes",
  );

  String selectedDelivery = "Take Away"; // Default selected option
  Map<String, dynamic>? intentPaymentData;
  double amountToBeCharge = 20;
  String currency = 'USD';
  double loyaltyPointsDiscount = 0;
  int loyaltyPointsRemaining = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfoForOrder();
  }

  // get the logged user credetionals
  getUserInfoForOrder() {
    var user = ref.read(userProvider);
    nameController = TextEditingController(text: user?.name);
    phoneController = TextEditingController(
      text: user!.phoneNo.isEmpty ? 'phone(optional)' : user.phoneNo,
    );
    emailController = TextEditingController(text: user.email);
    addressController = TextEditingController(
      text: user.address ?? 'Address(optional)',
    );
  }

  @override
  Widget build(BuildContext context) {
    var tax = ref.watch(taxStreamProvider).value;
    var loggedUser = ref.watch(userProvider);
    var currentAddress = loggedUser?.address;
    // function that place order
    void placeOrder(
      BuildContext context,
      String paymentIntentid,
      bool isSuccess,
    ) async {
      List<OrderItem> orderItems =
          widget.cartitem.map((cartItem) {
            return OrderItem(
              id: cartItem.productId,
              name: cartItem.productName,
              quantity: cartItem.quantity,
              price: cartItem.price,
              imageUrl: cartItem.productImage,
              notes: cartItem.notes,
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

      var total = 0.0;
      int loyaltyPoints = widget.total.toInt();

      selectedDelivery.toLowerCase() == 'delivery'
          ? total = widget.total + (widget.total * tax! / 100) + 9.75
          : total = widget.total + (widget.total * tax! / 100);

      final order = OrderModel(
        id: orderId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        items: orderItems,
        totalPrice: total,
        status: "Order Received",
        createdAt: Timestamp.fromDate(DateTime.now()),
        completedAt: null,
        deliveryAddress: user!.address ?? 'User Address go here',
        paymentMethod: '',
        additionalNotes: additionalNotesController.text,
        transactionId: paymentIntentid,
        orderSteps: orderSteps,
        trackid: trackId, // 🔥 Assigning the generated tracking ID
        paymentIntentId: paymentIntentid,
        paymentStatus: isSuccess ? 'Paid' : 'failed',
        orderType: selectedDelivery,
        tax: (widget.total * tax / 100).toString(),
      );
      if (loyaltyPointsDiscount > 0) {
        print('loyaltyPoints inside the place order ${loyaltyPointsRemaining}');
        var totalNewLoyaltyPoints = loyaltyPointsRemaining + loyaltyPoints;

        print('total new points are ${totalNewLoyaltyPoints}');
        ref
            .read(userProfileControllerProvider.notifier)
            .updateLoyaltyPoints(
              id: user!.id,
              points: totalNewLoyaltyPoints,
              context: context,
            );
      } else {
        var currentPoints = user!.loyaltyPoints;
        var totalPoints = currentPoints + loyaltyPoints;
        print('total points are ${totalPoints}');
        ref
            .read(userProfileControllerProvider.notifier)
            .updateLoyaltyPoints(
              id: user.id,
              points: totalPoints,
              context: context,
            );
      }

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
          //show quantituy stock
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
                    //UI for delivery section

                    deliverySelection(currentAddress),
                    const SizedBox(height: 20),
                    //order info of user
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
                            'Add Order Info',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp,
                            ),
                          ),
                          _buildTextField(nameController),
                          _buildTextField(emailController),
                          // _buildTextField(phoneController),
                          // _buildTextField(addressController),
                          _buildTextField(additionalNotesController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            //display tex
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "tax.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Apptheme.logoInsideColor,
                  ),
                ),
                Text(
                  "+${(widget.total * tax! / 100).toStringAsFixed(2)} \$",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            //display delivery price if selected
            if (selectedDelivery.toLowerCase() == 'delivery')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "delivery.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Apptheme.logoInsideColor,
                    ),
                  ),
                  Text(
                    " +9.75\$",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              //display total amount
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
                  selectedDelivery.toLowerCase() != 'delivery'
                      ? "${(widget.total + (widget.total * tax / 100)).toStringAsFixed(2)} \$"
                      : "${(widget.total + (widget.total * tax / 100) + 9.75).toStringAsFixed(2)} \$",
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
                  var total = 0.0;

                  if (selectedDelivery.toLowerCase() == 'delivery') {
                    if (currentAddress == null || currentAddress == '') {
                      showSnackBar(context, 'Please select address');
                      return;
                    }
                    if (loggedUser!.phoneNo.isEmpty) {
                      showSnackBar(
                        context,
                        'update phone number from profile menu',
                      );
                      return;
                    }
                  }

                  selectedDelivery.toLowerCase() == 'delivery'
                      ? total = widget.total + (widget.total * tax / 100) + 9.75
                      : total = widget.total + (widget.total * tax / 100);

                  final paymentService = PaymentService(
                    context,
                    // onPaymentSuccess: () => placeOrder(context),
                    onPaymentSuccess: (paymentIntentId, success) {
                      if (success) {
                        print("🎉 Payment succeeded! ID: $paymentIntentId");
                        placeOrder(context, paymentIntentId, success);
                        // Store the paymentIntentId in order, mark order as paid etc.
                      } else {
                        // print("⚠️ Payment failed or was cancelled.");
                        showSnackBar(
                          context,
                          '⚠️ Payment failed or was cancelled."',
                        );
                      }
                    },
                  );
                  paymentService.startPayment(
                    (total * 100).toString(),
                    "usd",
                  ); // $10.00
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
//delivery and order intitial details UI logic
  deliverySelection(String? address) {
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text(
          //       "Deliver to",
          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //     ),
          //     GestureDetector(
          //       onTap: () async {
          //         Navigator.of(context).pushNamed(MapLocation.routeName);
          //         // Add Address action
          //         // await createDoorDashDelivery(
          //         //   customerName: 'Test User',
          //         //   customerPhone: '+16505555555',
          //         //   dropoffAddress:
          //         //       '901 Market Street 6th Floor San Francisco, CA 94103',
          //         //   orderValue: 2999,
          //         // );
          //       },
          //       child: const Text(
          //         "Add Address",
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.amber,
          //         ),
          //       ),
          //     ),
          //     // TextButton(
          //     //   onPressed: () async {
          //     //     final response = await http.post(
          //     //       Uri.parse(
          //     //         'https://us-central1-genghis-khan-restaurant.cloudfunctions.net/trackDoorDashDelivery',
          //     //       ),
          //     //       headers: {'Content-Type': 'application/json'},
          //     //       body: jsonEncode({
          //     //         'externalDeliveryId': 'order-1745225735746',
          //     //       }),
          //     //     );

          //     //    log.log('Track status: ${response.body}');
          //     //   },
          //     //   child: Text('Check Status'),
          //     // ),
          //   ],
          // ),
          // SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     if (address == null)
          //       const Icon(Icons.info_outline, color: Colors.red),
          //     const SizedBox(width: 5),
          //     Expanded(
          //       child: Text(
          //         address ?? "No contact info added",
          //         style: TextStyle(color: Colors.red, fontSize: 14),
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Discounts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // No contact info warning
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.discount),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  //loyalty point usage 
                  var user = ref.read(userProvider);
                  //if points are less then 100
                  if (user!.loyaltyPoints < 100) {
                    showSnackBar(
                      context,
                      'A minimum of 100 points are needed to get the discount',
                    );
                    return;
                  }
                  //show loyalty points dialog and allow comsuption 
                  showLoyaltyPointDialog(context, user.loyaltyPoints, (
                    discount,
                    remainingPoints,
                  ) {
                    setState(() {
                      widget.total -= discount;
                      loyaltyPointsDiscount = discount;
                      loyaltyPointsRemaining = remainingPoints;
                    });
                    print(
                      'Discount: $discount, Remaining Points: $remainingPoints',
                    );
                  });
                },
                child: const Text(
                  "Use Loyalty Points",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Delivery Type title
          const Text(
            "Order Type",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Dine-in Selection
          // GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       selectedDelivery = "Delivery";
          //       // selectedDelivery = "Take Away";
          //     });
          //     // showSnackBar(context, 'This feature will be available soon');
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //     decoration: BoxDecoration(
          //       color:
          //           selectedDelivery == "Delivery"
          //               ? Colors.red.withOpacity(0.1)
          //               : Colors.transparent,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(
          //         color:
          //             selectedDelivery == "Delivery"
          //                 ? Colors.red
          //                 : Colors.grey.shade300,
          //         width: selectedDelivery == "Delivery" ? 2 : 1,
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Row(
          //           children: [
          //             Icon(
          //               selectedDelivery == "Delivery"
          //                   ? Icons.radio_button_checked
          //                   : Icons.radio_button_unchecked,
          //               color: Colors.red,
          //             ),
          //             const SizedBox(width: 10),
          //             const Text(
          //               "Delivery",
          //               style: TextStyle(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ],
          //         ),
          //         const Text(
          //           "9.75 \$",
          //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDelivery = "Dine-in";
                // selectedDelivery = "Take Away";
              });
              // showSnackBar(context, 'This feature will be available soon');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    selectedDelivery == "Dine-in"
                        ? Colors.red.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      selectedDelivery == "Dine-in"
                          ? Colors.red
                          : Colors.grey.shade300,
                  width: selectedDelivery == "Dine-in" ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedDelivery == "Dine-in"
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Dine-in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // const Text(
                  //   "10.00 \$",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
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
                  // const Text(
                  //   "Free",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
//loyalty point dialog ui code
  void showLoyaltyPointDialog(
    BuildContext context,
    int totalPoints,
    Function(double discount, int remainingPoints) onRedeem,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        double selectedPoints = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            double dollarPerPoint = 0.05;
            double dollars = selectedPoints * dollarPerPoint;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text("Redeem Loyalty Points"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Your Points: $totalPoints"),
                  SizedBox(height: 20),
                  Text("Redeem: ${selectedPoints.toInt()} points"),
                  Slider(
                    value: selectedPoints,
                    onChanged: (value) {
                      setState(() {
                        selectedPoints = value;
                      });
                    },
                    min: 0,
                    max: totalPoints.toDouble(),
                    divisions: totalPoints,
                    label: "${selectedPoints.toInt()}",
                  ),
                  SizedBox(height: 10),
                  Text("Equivalent: \$${dollars.toStringAsFixed(2)}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                // Handle redemption logic here
                    onRedeem(dollars, totalPoints - selectedPoints.toInt());

                    Navigator.pop(context);
                  },
                  child: Text("Redeem"),
                ),
              ],
            );
          },
        );
      },
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
