import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  static const routeName = '/edit-profile-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController phoneControllercontroller = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dobController = TextEditingController();

//loading the current user data
  loadUserData() {
    var user = ref.read(userProvider);
    if (user != null) {
      namecontroller = TextEditingController(text: user.name);
      emailcontroller = TextEditingController(text: user.email);
      phoneControllercontroller = TextEditingController(text: user.phoneNo);
      locationController = TextEditingController(text: user.address);
      dobController = TextEditingController(text: user.dob);
    }
  }
//saving the new updated data
  void save() {
    ref
        .read(userProfileControllerProvider.notifier)
        .editProfile(
          context: context,
          name: namecontroller.text.trim(),
          email: emailcontroller.text.trim(),
          phoneno: phoneControllercontroller.text.trim(),
          dob: dobController.text.trim(),
        );

    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => DashBoard(),
    // ));
  }

  @override
  void initState() {
    loadUserData();
    super.initState();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Apptheme.logoInsideColor, // Set scaffold background to brand color

    appBar: AppBar(
      backgroundColor: Apptheme.logoInsideColor, // Match with scaffold background
      elevation: 0, // Remove shadow for flat look
      iconTheme: IconThemeData(color: Colors.white), // Back icon color
      title: Text("My Profile", style: TextStyle(color: Colors.white)),
      centerTitle: true,
    ),

    // Main body of the screen using Stack to overlay profile image and form
    body: Stack(
      children: [
        // Main content container, pushed down to leave space for profile image
        Container(
          margin: EdgeInsets.only(top: 80),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                SizedBox(height: 60), // Space for profile image

                // Text field for first name (required)
                buildTextField(
                  namecontroller,
                  "First Name",
                  "Huzaifa",
                  Icons.person,
                  true,
                ),

                // Text field for email (not required)
                buildTextField(
                  emailcontroller,
                  "Email",
                  "hkexapril@gmail.com",
                  Icons.email,
                  false,
                ),

                // Text field for phone number (not required, but shows verified icon)
                buildTextField(
                  phoneControllercontroller,
                  "Phone Number",
                  "+445566556",
                  Icons.phone,
                  false,
                  isVerified: true,
                ),

                // Text field for location (required)
                buildTextField(
                  locationController,
                  "Location",
                  "",
                  Icons.location_city,
                  true,
                ),

                // Text field for date of birth (required)
                buildTextField(
                  dobController,
                  "DoB",
                  "",
                  Icons.door_back_door,
                  true,
                ),

                SizedBox(height: 20),

                // Update button to save profile details
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      save(); // Call save function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Positioned profile avatar on top center of the screen
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              children: [
                // Placeholder profile image avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),

                // Icon overlay for future profile image linking/upload
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Apptheme.logoInsideColor,
                    child: Icon(Icons.link, color: Colors.white, size: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Reusable text field builder for form inputs
Widget buildTextField(
  TextEditingController controller,
  String label,
  String value,
  IconData icon,
  bool isRequired, {
  bool isPassword = false,
  bool isVerified = false,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15),
    child: TextField(
      obscureText: isPassword, // Hide text for password fields
      controller: controller,
      decoration: InputDecoration(
        // Label text with * if required
        labelText: label + (isRequired ? " *" : ""),
        labelStyle: TextStyle(color: Colors.black54),

        // Leading icon
        prefixIcon: Icon(icon, color: Colors.grey),

        // Optional trailing icon for verified or password field
        suffixIcon: isVerified
            ? Icon(Icons.check_circle, color: Colors.green)
            : isPassword
                ? Icon(Icons.visibility_off, color: Colors.grey)
                : null,

        // Rounded border and filled background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );
}

}
