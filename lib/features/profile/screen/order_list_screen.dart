import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/profile/screen/delivery_track.dart';
import 'package:gzresturent/features/profile/screen/refund_request_screen.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../../models/ordermodal.dart';
import '../../home/controller/order_controller.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});
  static const routeName = '/order-list-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final PageController _pageController =
      PageController(); // PageView controller
  int _selectedIndex = 0; // 0 for Ongoing, 1 for History

  var orderstep = 'Order Received';
  var orderId = '';
  var paymentIntentid = '';
  var maxAmount = '';
  var currentuserid = '';
  var orderTrackid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Apptheme.buttonColor,
      //     ),
      //     onPressed: () {
      //       if (orderstep == 'Order Received') {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder:
      //                 (_) => RefundRequestScreen(
      //                   orderId: orderId,
      //                   paymentIntentId: paymentIntentid,
      //                   maxAmount: double.parse(maxAmount),
      //                   userId: currentuserid,
      //                   orderTrackid: orderTrackid,
      //                 ),
      //           ),
      //         );
      //       } else {
      //         print('refund not possible');
      //       }
      //     },
      //     child: Text('Refund', style: TextStyle(color: Colors.white)),
      //   ),
      // ),
      appBar: AppBar(
        title: Text(
          "My Order",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Custom TabBar
          _buildCustomTabBar(),
          SizedBox(height: 20),
          // PageView for Sliding Effect
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [_buildOngoingOrders(), _buildOrderHistory()],
            ),
          ),
        ],
      ),
    );
  }

  // Custom TabBar using Buttons
  Widget _buildCustomTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Apptheme.buttonColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _buildTabButton("Ongoing", _selectedIndex == 0, 0),
          _buildTabButton("History", _selectedIndex == 1, 1),
        ],
      ),
    );
  }

  // Tab Button
  Widget _buildTabButton(String title, bool isSelected, int pageIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = pageIndex;
          });
          _pageController.animateToPage(
            pageIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Apptheme.buttonColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Apptheme.buttonColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Ongoing Orders UI
  Widget _buildOngoingOrders() {
    return ref
        .watch(userOrdersProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
          data: (data) {
            final ongoingOrders =
                data
                    .where(
                      (order) =>
                          order.status.toLowerCase() == "order received" ||
                          order.status.toLowerCase() == "pending",
                    )
                    .toList();

            if (ongoingOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/1278/1278648.png',
                      width: 150.w,
                    ), // Replace with your asset
                    SizedBox(height: 16),
                    Text(
                      "No Order History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You haven't made any purchase yet",
                      style: TextStyle(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Apptheme.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        "Explore Menu",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Filter only ongoing orders (status: "Order Received" or "On the way")
              final ongoingOrders =
                  data
                      .where(
                        (order) =>
                            order.status.toLowerCase() == "order received" ||
                            order.status.toLowerCase() == "pending",
                      )
                      .toList();

              orderstep =
                  ongoingOrders.first.orderSteps[1].timestamp == null
                      ? 'Order Received'
                      : 'Order in Making';
              orderId = ongoingOrders.first.id;
              paymentIntentid = ongoingOrders.first.transactionId!;
              maxAmount = ongoingOrders.first.totalPrice.toString();
              currentuserid = ongoingOrders.first.userId;
              orderTrackid = ongoingOrders.first.trackid;

              return OrderTrackingScreen(
                ongoingOrder: ongoingOrders.first,
                trackId: ongoingOrders.first.deliveryTrackingUrl,
              );
            }
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

  // Order History UI
  Widget _buildOrderHistory() {
    return ref
        .watch(userOrdersProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
          data: (data) {
            final onCompletedOrder =
                data
                    .where(
                      (order) =>
                          order.status.toLowerCase() == "delivered" ||
                          order.status.toLowerCase() == "done",
                    )
                    .toList();

            if (onCompletedOrder.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/1278/1278648.png',
                      width: 150.w,
                    ), // Replace with your asset
                    SizedBox(height: 16),
                    Text(
                      "No Order History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You haven't made any purchase yet",
                      style: TextStyle(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Apptheme.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        "Explore Menu",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Filter only ongoing orders (status: "Order Received" or "On the way")
              final ongoingOrders =
                  data
                      .where(
                        (order) =>
                            order.status.toLowerCase() == "delivered" ||
                            order.status.toLowerCase() == "done",
                      )
                      .toList();

              return ListView.builder(
                itemCount: ongoingOrders.length,
                itemBuilder: (context, index) {
                  return OrderHistoryCard(
                    orderId: ongoingOrders[index].id,
                    status: ongoingOrders[index].status,
                    totalPrice: ongoingOrders[index].totalPrice,
                    createdAt: ongoingOrders[index].createdAt.toDate(),
                    tranctionId: ongoingOrders[index].transactionId!,
                    userId: ongoingOrders[index].userId,
                    trackId: ongoingOrders[index].trackid,
                    onTap: () {},
                  );
                },
              );
            }
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

class OrderHistoryCard extends StatelessWidget {
  final String orderId;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final VoidCallback onTap;
  final String tranctionId;
  final String userId;
  final String trackId;

  const OrderHistoryCard({
    Key? key,
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.onTap,
    required this.tranctionId,
    required this.userId,
    required this.trackId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID
              Text(
                "Order ID: $trackId",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),

              // Order Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: \$${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.buttonColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RefundRequestScreen(
                                orderId: orderId,
                                paymentIntentId: tranctionId,
                                maxAmount: totalPrice,
                                userId: userId,
                                orderTrackid: trackId,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      "Complaint",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      case "pending":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel ongoingOrder;
  final String? trackId;

  const OrderTrackingScreen({
    super.key,
    required this.ongoingOrder,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> orderSteps =
        ongoingOrder.orderSteps.map((step) {
          return {'step': step.step, 'timestamp': step.timestamp};
        }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Order Id: ${ongoingOrder.trackid}",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          // Dynamically display order steps
          ...orderSteps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> step = entry.value;

            bool isCompleted = step['timestamp'] != null;
            bool isOngoing =
                !isCompleted &&
                (index == 0 || orderSteps[index - 1]['timestamp'] != null);

            log(isCompleted.toString());

            return _buildOrderStatusItem(
              icon: _getStepIcon(step['step']),
              title: step['step'],
              timestamp: step['timestamp'],
              isCompleted: isCompleted,
              isOngoing: isOngoing,
              isLast: index == orderSteps.length - 1,
            );
          }).toList(),
          Spacer(),
          if (trackId != null)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.buttonColor,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyWebView(url: trackId!),
                    ),
                  );
                },
                child: Text(
                  'Track Order',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String title,
    required dynamic timestamp,
    required bool isCompleted,
    required bool isOngoing,
    required bool isLast,
  }) {
    Color statusColor =
        isCompleted
            ? Colors
                .green // Completed
            : isOngoing
            ? Colors
                .orange // Ongoing
            : Colors.grey; // Pending

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: statusColor,
              child: Icon(icon, color: Colors.white),
            ),
            if (!isLast) ...[
              SizedBox(height: 8),
              DottedLine(
                direction: Axis.vertical,
                lineLength: 40,
                dashColor: statusColor,
                dashLength: 5,
                dashGapLength: 3,
              ),
            ],
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              SizedBox(height: 4),
              if (timestamp != null)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      timestamp != null
                          ? DateFormat('hh:mm a, dd MMM yyyy').format(
                            (timestamp as Timestamp)
                                .toDate(), // Convert Timestamp to DateTime
                          )
                          : "No Timestamp",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get appropriate icons for each step
  IconData _getStepIcon(String step) {
    switch (step) {
      case "Order Received":
        return Icons.receipt_long;
      case "Order In Making":
        return Icons.restaurant_menu;
      case "Order Ready":
        return Icons.check_circle_outline;
      case "On the way":
        return Icons.delivery_dining;
      case "Delivered":
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }
}

// class OrderTrackingScreen extends StatelessWidget {
//   const OrderTrackingScreen({super.key, required this.ongoingOrder});
//   final OrderModel ongoingOrder;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               "Order Id: ${ongoingOrder.trackid}",
//               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(height: 20),
//           _buildOrderStatusItem(
//             icon: Icons.receipt_long,
//             title: "Order Received",
//             subtitle: "10:52 AM, 23 May 2022",
//             isLast: false,
//           ),
//           _buildOrderStatusItem(
//             icon: Icons.delivery_dining,
//             title: "Order In Making",
//             subtitle: "",
//             isLast: true,
//           ),
//           _buildOrderStatusItem(
//             icon: Icons.location_on,
//             title: "Order Ready",
//             subtitle: "",
//             isLast: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderStatusItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isLast,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             CircleAvatar(
//               radius: 22,
//               backgroundColor: Apptheme.logoOutsideColor,
//               child: Icon(icon, color: Colors.white),
//             ),
//             if (!isLast) ...[
//               SizedBox(height: 8),
//               DottedLine(
//                 direction: Axis.vertical,
//                 lineLength: 40,
//                 dashColor: Apptheme.logoInsideColor,
//                 dashLength: 5,
//                 dashGapLength: 3,
//               ),
//             ],
//           ],
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.access_time, size: 16, color: Colors.grey),
//                   SizedBox(width: 5),
//                   Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
//                 ],
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
