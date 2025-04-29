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
      backgroundColor: Apptheme.logoInsideColor,
      appBar: AppBar(
        backgroundColor: Apptheme.logoInsideColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
                  SizedBox(height: 60),
                  buildTextField(
                    namecontroller,
                    "First Name",
                    "Huzaifa",
                    Icons.person,
                    true,
                  ),

                  buildTextField(
                    emailcontroller,
                    "Email",
                    "hkexapril@gmail.com",
                    Icons.email,
                    false,
                  ),
                  buildTextField(
                    phoneControllercontroller,
                    "Phone Number",
                    "+445566556",
                    Icons.phone,
                    false,
                    isVerified: true,
                  ),
                  buildTextField(
                    locationController,
                    "Location",
                    "",
                    Icons.location_city,
                    true,
                  ),
                  buildTextField(
                    dobController,
                    "DoB",
                    "",
                    Icons.door_back_door,
                    true,
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        save();
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
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
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
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isRequired ? " *" : ""),
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon:
              isVerified
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : isPassword
                  ? Icon(Icons.visibility_off, color: Colors.grey)
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
