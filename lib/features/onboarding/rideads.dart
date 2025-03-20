import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/nav_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RideadsScreen extends StatelessWidget {
  const RideadsScreen({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: 2);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0.sp),
              child: Text(
                'Bringing Flavor to You 🍜',
                // textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 40.sp,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Image.asset('assets/images/img3.png', height: 200.h),
            SizedBox(height: 40.h),
            SmoothPageIndicator(
              controller: pageController, // PageController
              count: 3,
              effect: const ExpandingDotsEffect(
                dotHeight: 7,
                dotWidth: 7,
                radius: 10,
                activeDotColor: Colors.black,
                dotColor: Colors.black,
              ), // your preferred effect
              onDotClicked: (index) {},
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Apptheme.buttonColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(NavScreen.routeName);
                        },
                        child: const Text(
                          'Starts',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
