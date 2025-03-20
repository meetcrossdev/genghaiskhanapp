import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/features/home/screen/home_screen.dart';
import 'package:gzresturent/features/onboarding/onboarding.dart';
import 'package:gzresturent/nav_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  static const routeName = '/onboarding-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6a6a6a), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Food Image
          Positioned(
            top: 50.h,
            left: 10.w,
            right: 10.w,
            child: Image.network(
              'https://static.vecteezy.com/system/resources/previews/046/364/473/non_2x/chinese-food-noodles-transparent-background-free-png.png',
              width: MediaQuery.of(context).size.width * 0.8,
              height: 350.h,
              fit: BoxFit.fitWidth,
            ),
          ),

          // Floating Ingredients Labels
          Positioned(
            top: 180,
            left: 60,
            child: _buildFloatingLabel("Cucumber", Icons.eco),
          ),
          Positioned(
            top: 250,
            right: 50,
            child: _buildFloatingLabel("Elements Foods", Icons.egg),
          ),
          Positioned(
            top: 300,
            left: 40,
            child: _buildFloatingLabel("Leaf", Icons.local_florist),
          ),

          // Text Content
          Positioned(
            bottom: 150,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cooking",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Delicious\nLike a Chef",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "This recipe app offers a wide selection of diverse and easy recipes suitable for all cooking levels!",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Get Started Button
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(OnStartingScreen.routeName);
              },
              child: Text(
                "Get Started",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabel(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 18),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
