import 'package:flutter/material.dart';
import 'package:gzresturent/features/auth/login_screen.dart';
import 'package:gzresturent/features/auth/signup_screen.dart';
import 'package:gzresturent/features/boarding_screen.dart';
import 'package:gzresturent/features/home/screen/checkout_screen.dart';
import 'package:gzresturent/features/home/screen/home_screen.dart';
import 'package:gzresturent/features/onboarding/onboarding.dart';
import 'package:gzresturent/features/profile/screen/edit_profile.dart';
import 'package:gzresturent/features/profile/screen/favortie_screen.dart';
import 'package:gzresturent/features/profile/screen/map_screen.dart';
import 'package:gzresturent/features/profile/screen/order_list_screen.dart';
import 'package:gzresturent/features/profile/screen/reward_points.dart';
import 'package:gzresturent/models/cart.dart';
import 'package:gzresturent/models/menu_items.dart';
import 'package:gzresturent/nav_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case OnboardingScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const OnboardingScreen(),
      );

    case OnStartingScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const OnStartingScreen(),
      );

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const HomeScreen(),
      );
    case NavScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const NavScreen(),
      );

    case LoginScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const LoginScreen(),
      );

    case SignupScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => const SignupScreen(),
      );
    case CheckoutScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;

      final cartItems = args['cartItems'] as List<CartItemModel>;
      final total = args['total'] as double;

      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => CheckoutScreen(cartitem: cartItems, total: total),
      );

    case FavouritesScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => FavouritesScreen(),
      );

    case RewardsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => RewardsScreen(),
      );

    case OrderListScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => OrderListScreen(),
      );

    case MapLocation.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => MapLocation(),
      );
    case EditProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => EditProfileScreen(),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder:
            (context) => const Scaffold(
              body: Center(
                child: Text(
                  'THE SCREEN DOES NOT EXIST YET',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
            ),
      );
  }
}
