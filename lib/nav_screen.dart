import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/home/screen/home_screen.dart';
import 'package:gzresturent/features/home/screen/menu_screen.dart';
import 'package:gzresturent/features/home/screen/cart_screen.dart';
import 'package:gzresturent/features/profile/screen/profile_screen.dart';

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
      var user=ref.read(userProvider);
      if(user==null){
        showSnackBar(context, 'Please Login To Countinue');
      }
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
            label: 'Cart',
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
