import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/nav_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DriveAdsScreen extends StatelessWidget {
  const DriveAdsScreen({super.key, required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0.sp),
              child: Text(
                'Delicious Choices Await 🍽️',
                // textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 40.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 68.0.w),
              child: Image.asset(
                'assets/images/img.png',
                width: double.infinity,
                height: 250.h,
              ),
            ),
            SizedBox(height: 120.h),

            Expanded(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(NavScreen.routeName);
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Apptheme.buttonColor,
                        ),
                        onPressed: () {
                          tabController.animateTo(tabController.index + 1);
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
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
