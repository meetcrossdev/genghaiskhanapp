import 'package:flutter/material.dart';
import 'package:gzresturent/core/constant/colors.dart';

class AuthTextField extends StatelessWidget {
  AuthTextField({
    super.key,
    required this.title,
    this.isPass = false,
    required this.controller,
  });
  final String title;
  final TextEditingController controller;
  bool isPass;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(color: Colors.grey), // Adjust label color
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Apptheme.logoInsideColor,
          ), // Border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ), // Border color when focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.redAccent,
          ), // Border color when there's an error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ), // Error border when focused
        ),
        prefixIcon: isPass ? Icon(Icons.lock, color: Colors.red) : null,
        suffixIcon: isPass ? Icon(Icons.visibility_off) : null,
      ),
      obscureText: isPass ? true : false,
    );
  }
}
