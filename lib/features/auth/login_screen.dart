import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/auth/signup_screen.dart';
import 'package:gzresturent/features/auth/widgets/authtextfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    loginUser() {
      if (emailController.text.isEmpty) {
        showSnackBar(context, 'Email field is empty');
        return;
      }
      if (passwordController.text.isEmpty) {
        showSnackBar(context, 'Password filed is empty');
        return;
      }

      showLoadingDialog(context);
      ref
          .read(authControllerProvider.notifier)
          .loginWithEmailAndPassword(
            emailController.text.trim(),
            passwordController.text.trim(),
            context,
          );
      //  Navigator.of(context).pushNamed(HomeScreen.routeName);
    }

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            SizedBox(height: 30.h),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'assets/images/logo.png', // Change this to your logo asset
                height: 80.h,
              ),
            ),

            // Email/Phone Field
            AuthTextField(title: "Email", controller: emailController),
            const SizedBox(height: 15),
            AuthTextField(
              title: "Password *",
              isPass: true,
              controller: passwordController,
            ),

            // Password Field
            const SizedBox(height: 10),

            // Remember me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    Text("Remember me"),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  loginUser();
                },
                child: Text(
                  "Sign In",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("or"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 10),

            // Continue with Google Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ref
                      .read(authcontrollerprovider)
                      .signInWithGoogle(context, '');
                },
                icon: Image.asset(
                  'assets/icon/google.png', // Change to your Google logo asset
                  height: 24,
                ),
                label: Text("Continue with Google", style: TextStyle()),
              ),
            ),
            const SizedBox(height: 20),
            if (Platform.isIOS)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/icon/apple.png', // Change to your Google logo asset
                    height: 34,
                  ),
                  label: Text("Continue with Apple", style: TextStyle()),
                ),
              ),
            const SizedBox(height: 20),
            // Sign Up Link
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(SignupScreen.routeName);
              },
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  children: [
                    TextSpan(
                      text: "Sign Up Here",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
