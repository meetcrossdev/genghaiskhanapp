import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/auth/signup_screen.dart';
import 'package:gzresturent/features/auth/widgets/authtextfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool rememberMe = false;

void loadUserCredentials() async {
  // Get an instance of SharedPreferences to retrieve stored user data
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Load the stored email if it exists, otherwise default to empty string
  emailController.text = prefs.getString('email') ?? '';

  // Load the stored password if it exists, otherwise default to empty string
  passwordController.text = prefs.getString('password') ?? '';

  // Load the "remember me" checkbox value, defaulting to false
  rememberMe = prefs.getBool('remember_me') ?? false;

  // Refresh the UI to reflect the loaded values
  setState(() {});
}

Future<void> sendPasswordResetEmail(String email) async {
  // If the email field is empty, show a snackbar and return early
  if (emailController.text.isEmpty) {
    showSnackBar(context, 'Enter Email in the field.');
    return;
  }

  // Show a confirmation dialog before sending the reset email
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Password Reset'),
        content: Text(
          'Do you want to send a password reset email to $email?',
        ),
        actions: [
          // Cancel button: just close the dialog
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          // Confirm button: send the password reset email
          TextButton(
            onPressed: () async {
              try {
                // Call Firebase to send the password reset email
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                // Close the dialog
                Navigator.of(context).pop();
                // Show success message
                showSnackBar(context, 'Password reset link send');
              } catch (e) {
                // Print error to console if sending fails
                print("Error: $e");
              }
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    loadUserCredentials();
  }

@override
Widget build(BuildContext context) {
  // Detect if the current theme is dark mode
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Function to handle user login
  loginUser() {
    // Validate email field
    if (emailController.text.isEmpty) {
      showSnackBar(context, 'Email field is empty');
      return;
    }
    // Validate password field
    if (passwordController.text.isEmpty) {
      showSnackBar(context, 'Password field is empty');
      return;
    }

    // Show a loading dialog while authenticating
    showLoadingDialog(context);

    // Call login method from the auth controller using Riverpod
    ref.read(authControllerProvider.notifier).loginWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
      context,
    );

    // Optionally navigate to Home screen after login (currently commented)
    // Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  return Scaffold(
    appBar: AppBar(), // Top app bar
    backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dynamic background color
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Horizontal padding for layout
      child: SingleChildScrollView( // Allows scrolling when keyboard opens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            SizedBox(height: 30.h),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'assets/images/logo.png', // Logo image asset
                height: 80.h,
              ),
            ),

            // Email input field
            AuthTextField(title: "Email", controller: emailController),
            const SizedBox(height: 15),

            // Password input field
            AuthTextField(
              title: "Password *",
              isPass: true, // Hides the input text
              controller: passwordController,
            ),
            const SizedBox(height: 10),

            // Remember Me checkbox & Forgot Password link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) async {
                        setState(() {
                          rememberMe = value!;
                        });

                        // Save or remove credentials in SharedPreferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        if (rememberMe) {
                          // Save credentials
                          await prefs.setString('email', emailController.text);
                          await prefs.setString('password', passwordController.text);
                          await prefs.setBool('remember_me', true);
                        } else {
                          // Clear credentials
                          await prefs.remove('email');
                          await prefs.remove('password');
                          await prefs.setBool('remember_me', false);
                        }
                      },
                    ),
                    Text("Remember me"),
                  ],
                ),

                // Forgot Password button
                TextButton(
                  onPressed: () {
                    sendPasswordResetEmail(emailController.text.trim());
                  },
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
                  loginUser(); // Call login function on button press
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

            // OR divider line
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

            // Continue with Google button
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
                  // Call Google Sign-In method from auth controller
                  ref.read(authcontrollerprovider).signInWithGoogle(context, '');
                },
                icon: Image.asset(
                  'assets/icon/google.png', // Google logo asset
                  height: 24,
                ),
                label: Text("Continue with Google", style: TextStyle()),
              ),
            ),
            const SizedBox(height: 20),

            // Continue with Apple button (visible only on iOS)
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
                  onPressed: () {
                    // Call Apple Sign-In method from auth controller
                    ref.read(authcontrollerprovider).signInWithApple(context, '');
                  },
                  icon: Image.asset(
                    'assets/icon/apple.png', // Apple logo asset
                    height: 34,
                  ),
                  label: Text("Continue with Apple", style: TextStyle()),
                ),
              ),
            const SizedBox(height: 20),

            // Link to Sign Up page
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(SignupScreen.routeName); // Navigate to sign-up
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
    ),
  );
}

}
