import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/auth/login_screen.dart';
import 'package:gzresturent/features/auth/widgets/authtextfield.dart';

import '../../core/utility.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  static const routeName = '/signup-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  File? profileImage;
  final TextEditingController dobController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phonenoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String mydevicetoken = '';

  // function for adding profile picture
  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileImage = File(res.files.first.path!);
      });
    }
  }

  //fucntion for user signup with email and password

  void signUpWithEmailAndPassword() async {
    //all the if statement show validation
    if (firstNameController.text.isEmpty) {
      showSnackBar(context, 'Enter your first name');
      return;
    }
    if (lastNameController.text.isEmpty) {
      showSnackBar(context, 'Enter your last name');
      return;
    }
    if (emailController.text.isEmpty) {
      showSnackBar(context, 'Enter your email');
      return;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      showSnackBar(context, 'Please enter a valid email');
      return;
    }
    if (phonenoController.text.isEmpty) {
      showSnackBar(context, 'Enter your phone number');
      return;
    }
    if (phonenoController.text.length != 10) {
      showSnackBar(context, 'Phone number should be exactly 10 digits');
      return;
    }
    if (phonenoController.text.startsWith('0')) {
      showSnackBar(context, 'Phone number should not start with zero');
      return;
    }
    if (passwordController.text.isEmpty) {
      showSnackBar(context, 'Enter your password');
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      showSnackBar(context, 'Confirm your password');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar(context, 'Passwords do not match');
      return;
    }
    if (profileImage == null) {
      showSnackBar(context, 'Choose a profile image');
      return;
    }

    // Process image (assuming _processImage checks CNIC validity)

    // Combine first and last name
    String fullName = '${firstNameController.text} ${lastNameController.text}';
    showLoadingDialog(context);
    // Call authentication method
    ref
        .read(authControllerProvider.notifier)
        .signUpWithEmailAndPassword(
          name: fullName,
          email: emailController.text,
          phone: phonenoController.text,
          imageFile: profileImage!,
          password: passwordController.text,
          context: context,
          devicetoken: mydevicetoken,
          dob: dobController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the authControllerProvider state to check if a loading operation is in progress
    bool isloading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(15.0.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Text
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
              SizedBox(height: 20.h),

              // Profile Image Selector
              GestureDetector(
                onTap: selectProfileImage,
                child: Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xff81A8A6),
                    backgroundImage: const AssetImage(
                      'assets/images/profile.png',
                    ),
                    child:
                        profileImage != null
                            ? ClipOval(
                              child: Image.file(
                                profileImage!,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                              ),
                            )
                            : Container(), // Show nothing if no image is selected
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // First Name Field
              Text('First Name', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(title: 'john', controller: firstNameController),

              SizedBox(height: 10.h),

              // Last Name Field
              Text('Last Name', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(title: 'Doe', controller: lastNameController),

              SizedBox(height: 10.h),

              // Phone Field
              Text('Phone', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(title: 'Phone', controller: phonenoController),

              SizedBox(height: 10.h),

              // Email Field
              Text('Email', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(title: 'email', controller: emailController),

              SizedBox(height: 20.h),

              // Date of Birth Field
              Text('DOB', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(title: 'dob', controller: dobController),

              SizedBox(height: 10.h),

              // Password Field
              Text('Password', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(
                title: 'password',
                isPass: true,
                controller: passwordController,
              ),

              SizedBox(height: 10.h),

              // Confirm Password Field
              Text('Confirm Password', style: TextStyle(fontSize: 16.sp)),
              AuthTextField(
                title: 'Confirm Password',
                isPass: true,
                controller: confirmPasswordController,
              ),

              SizedBox(height: 20.h),

              // Sign Up Button
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
                    // Trigger signup logic when button is pressed
                    signUpWithEmailAndPassword();
                  },
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Navigate to Login Screen
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phonenoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
