import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/home/controller/reservation_controller.dart';
import 'package:gzresturent/models/reservation.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../../models/ordermodal.dart';
import '../../home/controller/order_controller.dart';

class MyBookingScreen extends ConsumerStatefulWidget {
  const MyBookingScreen({super.key});
  static const routeName = '/my-booking-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyBookingScreenState();
}

class _MyBookingScreenState extends ConsumerState<MyBookingScreen> {
  final PageController _pageController =
      PageController(); // PageView controller
  int _selectedIndex = 0; // 0 for Ongoing, 1 for History

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Booking",
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
          _buildTabButton("Current", _selectedIndex == 0, 0),
          _buildTabButton("Record", _selectedIndex == 1, 1),
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
        .watch(userReservationsProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
          data: (data) {
            final ongoingReservation =
                data
                    .where(
                      (reservation) =>
                          reservation.status.toLowerCase() == "pending",
                    )
                    .toList();

            if (ongoingReservation.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No Booking in Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Filter only ongoing orders (status: "Order Received" or "On the way")
              return ListView.builder(
                itemCount: ongoingReservation.length,
                itemBuilder: (context, index) {
                  return BookingHistoryCard(
                    reservation: ongoingReservation[index],
                    onTap: () {
                      ref
                          .read(reservationControllerProvider.notifier)
                          .deleteReservation(
                            reservationId: ongoingReservation[index].id,
                            context: context,
                          );
                    },
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

  // Order History UI
  Widget _buildOrderHistory() {
    return ref
        .watch(userReservationsProvider(FirebaseAuth.instance.currentUser!.uid))
        .when(
          data: (data) {
            final onCompletedReservation =
                data
                    .where(
                      (order) =>
                          order.status.toLowerCase() == "approved" ||
                          order.status.toLowerCase() == "rejected",
                    )
                    .toList();

            if (onCompletedReservation.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No Booking Records To Show",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                            order.status.toLowerCase() == "approved" ||
                            order.status.toLowerCase() == "rejected",
                      )
                      .toList();

              return ListView.builder(
                itemCount: ongoingOrders.length,
                itemBuilder: (context, index) {
                  return BookingHistoryCard(
                    reservation: ongoingOrders[index],
                    onTap: () {
                      ref
                          .read(reservationControllerProvider.notifier)
                          .deleteReservation(
                            reservationId: ongoingOrders[index].id,
                            context: context,
                          );
                    },
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

class BookingHistoryCard extends StatelessWidget {
  final VoidCallback onTap;
  final Reservation reservation;

  const BookingHistoryCard({
    super.key,
    required this.onTap,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID
              Text(
                "Notes: ${reservation.specialRequest}",
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
                    reservation.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(reservation.status),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.buttonColor,
                    ),
                    onPressed: onTap,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time: ${reservation.reservationTime}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(reservation.reservationDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
      case "approved":
        return Colors.green;
      case "rejected":
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

  const OrderTrackingScreen({super.key, required this.ongoingOrder});

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

            return _buildOrderStatusItem(
              icon: _getStepIcon(step['step']),
              title: step['step'],
              timestamp: step['timestamp'],
              isCompleted: isCompleted,
              isOngoing: isOngoing,
              isLast: index == orderSteps.length - 1,
            );
          }).toList(),
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
