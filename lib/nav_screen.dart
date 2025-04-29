import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/controller/store_hours_controller.dart';
import 'package:gzresturent/features/home/screen/home_screen.dart';
import 'package:gzresturent/features/home/screen/menu_screen.dart';
import 'package:gzresturent/features/home/screen/cart_screen.dart';
import 'package:gzresturent/features/profile/screen/profile_screen.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NavScreen extends ConsumerStatefulWidget {
  const NavScreen({super.key});
  static const routeName = '/nav-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavScreenState();
}

class _NavScreenState extends ConsumerState<NavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Replace with actual screens
    MenuScreen(),
    CheckoutScreens(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      var user = ref.read(userProvider);
      if (user == null) {
        showSnackBar(context, 'Please Login To Countinue');
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final holidaysState = ref.watch(holidaysProvider).value;
    final currentUser = ref.watch(userProvider);
    final DateTime today = DateTime.now();
    bool isHoliday = false;
    final DateTime todayNormalized = DateTime(
      today.year,
      today.month,
      today.day,
    );

    // Check if today's date exists in the holiday list
    if (holidaysState != null) {
      isHoliday = holidaysState.any(
        (date) =>
            date.year == todayNormalized.year &&
            date.month == todayNormalized.month &&
            date.day == todayNormalized.day,
      );
    }

    return Scaffold(
      body: ref
          .watch(storeStatusProvider)
          .when(
            data: (data) {
              if (isHoliday) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text(
                      "🎉 Today is a holiday! Enjoy your day! 🎊",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                if (currentUser?.status == 'inactive') {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: const Text(
                        "Your Account is temporary suspended",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  if (data == false) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset('assets/images/logo.png'),
                          ),

                          Text('Resturent is closed for now come back later'),
                        ],
                      ),
                    );
                  } else {
                    return IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    );
                  }
                }
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
          ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_sharp),
            label: 'Order',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
