import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

void showOrderSuccessDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.bottomSlide,
    title: "Order Placed!",
    desc: "Your order has been placed successfully. Thank you!",
    btnOkText: "OK",
    btnOkOnPress: () {
      Navigator.pop(context); // Close dialog or navigate
    },
    btnOkColor: Apptheme.buttonColor,
    dismissOnTouchOutside: false,
  ).show();
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevents dismissing the dialog by tapping outside
    builder: (context) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(
              indicatorType: Indicator.ballClipRotatePulse,

              // /// Required, The loading type of the widget
              // colors: const [Colors.white],

              // /// Optional, The color collections
              // strokeWidth: 2,

              // /// Optional, The stroke of the line, only applicable to widget which contains line
              // backgroundColor: Colors.black,

              // /// Optional, Background of the widget
              // pathBackgroundColor: Colors.black,

              /// Optional, the stroke backgroundColor
            ),
            SizedBox(height: 20),
            Text(
              'Loading, please wait...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    },
  );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );
  return image;
}
