import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/constant/themenotfier.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/login_screen.dart';
import 'package:gzresturent/features/profile/screen/edit_profile.dart';
import 'package:gzresturent/features/profile/screen/favortie_screen.dart';
import 'package:gzresturent/features/profile/screen/map_screen.dart';
import 'package:gzresturent/features/profile/screen/my_booking_screen.dart';
import 'package:gzresturent/features/profile/screen/order_list_screen.dart';
import 'package:gzresturent/features/profile/screen/refund_history_screen.dart';
import 'package:gzresturent/features/profile/screen/reservation_screen.dart';
import 'package:gzresturent/features/profile/screen/reward_points.dart';
import 'package:gzresturent/features/profile/screen/shop_hours.dart';

import '../../auth/controller/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> deleteUserAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user is signed in.")));
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
              title: const Text("Delete Account"),
              content: const Text(
                "Are you sure you want to delete your account and all associated data?",
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text("Delete"),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            )
            : AlertDialog(
              title: const Text("Delete Account"),
              content: const Text(
                "Are you sure you want to delete your account and all associated data?",
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Delete"),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            );
      },
    );

    if (confirm != true) return; // User cancelled

    try {
      // 1. Delete Firestore user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // 2. Delete Firebase Auth user
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your account has been deleted.")),
      );

      // 3. Navigate to login or welcome screen
      ref.read(userProvider.notifier).state = null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please re-login and try again.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: ${e.message}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    var user = ref.watch(userProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.pink[50],
                    backgroundImage:
                        user != null ? NetworkImage(user.profilePic) : null,
                    child:
                        user != null
                            ? null
                            : Icon(Icons.person, size: 40, color: Colors.pink),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null ? user.name : 'Guest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (user == null) {
                            Navigator.of(
                              context,
                            ).pushNamed(LoginScreen.routeName);
                          }
                        },
                        child: Text(
                          user != null ? user.email : 'Sign Up or Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDarkMode
                                ? Colors.grey[800]
                                : Colors.orange.shade100, // Dynamic background
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      width: 40,
                      height: 40,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          key: ValueKey<bool>(
                            isDarkMode,
                          ), // Ensures proper animation on change
                          color:
                              isDarkMode
                                  ? Colors.yellow.shade600
                                  : Colors.orange,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Action Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }
                      Navigator.of(
                        context,
                      ).pushNamed(FavouritesScreen.routeName);
                    },
                    child: _quickActionCard(
                      Icons.favorite_outline,
                      "Favourite",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(MyBookingScreen.routeName);
                    },
                    child: _quickActionCard(Icons.book_online, "Reservations"),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }
                      Navigator.of(context).pushNamed(RewardsScreen.routeName);
                    },
                    child: _quickActionCard(Icons.star_border, 'Gk Points'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // General Section
              Text(
                "General",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  // color: Colors.white,
                  //  color: Theme.of(context).cardColor,
                  color: Apptheme.logoInsideColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _menuItem(Icons.person_outline, "Profile", () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }
                      Navigator.of(
                        context,
                      ).pushNamed(EditProfileScreen.routeName);
                    }),

                    _menuItem(Icons.shopping_cart_outlined, "My Order", () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }
                      Navigator.of(
                        context,
                      ).pushNamed(OrderListScreen.routeName);
                    }),

                    //      _menuItem(Icons.list_alt, "Order Details", () {}),
                    _menuItem(Icons.money, "Report Issues", () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => RefundHistoryScreen(userId: user.id),
                        ),
                      );
                    }),
                    // _menuItem(Icons.restaurant, "Reservation", () {
                    //   if (user == null) {
                    //     showSnackBar(
                    //       context,
                    //       'Please login to access the feature',
                    //     );
                    //     return;
                    //   }
                    //   Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) => ReservationHistoryScreen(),
                    //     ),
                    //   );
                    // }),
                    if (user != null)
                      _menuItem(Icons.delete, "Delete Account", () {
                        deleteUserAccount(context);
                      }),
                    _menuItem(Icons.location_on_outlined, "Address", () {
                      if (user == null) {
                        showSnackBar(
                          context,
                          'Please login to access the feature',
                        );
                        return;
                      }
                      Navigator.of(context).pushNamed(MapLocation.routeName);
                    }),
                    _menuItem(Icons.store, "Resturant Hours", () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StoreHoursScreen(),
                        ),
                      );
                    }),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink[50],
                        child: Icon(Icons.login, color: Colors.pink),
                      ),
                      title: Text(
                        user != null ? "Logout" : "Login",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        if (user != null) {
                          ref.read(authcontrollerprovider).signOut();
                          ref.read(userProvider.notifier).state = null;
                        } else {
                          Navigator.of(
                            context,
                          ).pushNamed(LoginScreen.routeName);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Action Card Widget
  Widget _quickActionCard(IconData icon, String title) {
    return Container(
      width: 100,

      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      decoration: BoxDecoration(
        //  color: Theme.of(context).cardColor,
        color: Apptheme.logoInsideColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Menu Item Widget
  Widget _menuItem(IconData icon, String title, void Function()? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 14, color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
      onTap: onTap,
    );
  }
}
