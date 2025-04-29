import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../../models/reservation.dart';
import '../controller/reservation_controller.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});
    static const routeName = '/my-reservation-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  int selectedNumber = 2;
  DateTime? selectedDate = DateTime.now();
  int selectedTimeIndex = -1;
  String selectedTimes = '';
  final TextEditingController notesController = TextEditingController();

  void _confirmReservation() {
    // if (selectedDate == null || selectedTime == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please select a date and time!")),
    //   );
    //   return;
    // }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Confirm Reservation"),
          content: Text(
            "Date: ${selectedDate}/05/2025"
            "Time: ${selectedTimeIndex}",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reservation Confirmed!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {},
        // ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (selectedTimeIndex == -1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a time!")),
              );
              return;
            }

            if (selectedDate!.isBefore(
              DateTime.now().subtract(const Duration(days: 1)),
            )) {
              // Show message
              showSnackBar(context, 'Please select an upcoming day.');
              return; // Stop further logic
            }

            String selectedTime = selectedTimes;
            var user = ref.read(userProvider);
            final reservation = Reservation(
              id: Uuid().v4(),

              customerId: user!.id,
              customerName: user.name,
              contactNumber: user.phoneNo,
              numberOfGuests: selectedNumber,
              reservationDate: selectedDate!,
              reservationTime: selectedTime,
              specialRequest: notesController.text,
            );

            ref
                .read(reservationControllerProvider.notifier)
                .addReservation(reservation: reservation, context: context);

            // _confirmReservation();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            "Confirm",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Make your reservation",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Number Selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Number", style: GoogleFonts.poppins(fontSize: 16)),
                    DropdownButton<int>(
                      value: selectedNumber,
                      underline: const SizedBox(),
                      items:
                          List.generate(10, (index) => index + 1)
                              .map(
                                (num) => DropdownMenuItem(
                                  value: num,
                                  child: Text(
                                    num.toString(),
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedNumber = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Add Notes(Optional)",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildTextField(
                notesController,
                'Additional Notes',
                'notes',
                Icons.notes,
                false,
              ),
              const SizedBox(height: 30),

              // Time selection
              // Text(
              //   "Select Time",
              //   style: GoogleFonts.poppins(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 8),

              // ref
              //     .watch(allTimeFetchProvider)
              //     .when(
              //       data: (data) {
              //         return Container(
              //           width: double.infinity,
              //           padding: const EdgeInsets.all(16),
              //           decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.circular(16),
              //             border: Border.all(color: Colors.grey.shade300),
              //           ),
              //           child: Wrap(
              //             spacing: 10,
              //             runSpacing: 10,
              //             children: List.generate(data.length, (index) {
              //               return GestureDetector(
              //                 onTap: () {
              //                   if (data[index].available == false) {
              //                     showSnackBar(
              //                       context,
              //                       'Unavailable time slot',
              //                     );
              //                     return;
              //                   }
              //                   setState(() {
              //                     selectedTimes = data[index].time;
              //                     selectedTimeIndex = index;
              //                   });
              //                 },
              //                 child:
              //                     data[index].available == true
              //                         ? Container(
              //                           padding: const EdgeInsets.symmetric(
              //                             horizontal: 16,
              //                             vertical: 10,
              //                           ),
              //                           decoration: BoxDecoration(
              //                             color:
              //                                 selectedTimeIndex == index
              //                                     ? Colors.pink.shade100
              //                                     : Colors.grey.shade200,
              //                             borderRadius: BorderRadius.circular(
              //                               20,
              //                             ),
              //                           ),
              //                           child: Text(
              //                             data[index].time.toString(),
              //                             style: GoogleFonts.poppins(
              //                               fontSize: 14,
              //                               fontWeight: FontWeight.bold,
              //                               color:
              //                                   selectedTimeIndex == index
              //                                       ? Colors.pink
              //                                       : Colors.black,
              //                             ),
              //                           ),
              //                         )
              //                         : Container(
              //                           padding: const EdgeInsets.symmetric(
              //                             horizontal: 16,
              //                             vertical: 10,
              //                           ),
              //                           decoration: BoxDecoration(
              //                             color: Colors.grey.shade800,
              //                             borderRadius: BorderRadius.circular(
              //                               20,
              //                             ),
              //                           ),
              //                           child: Row(
              //                             mainAxisSize: MainAxisSize.min,
              //                             children: [
              //                               Icon(
              //                                 Icons.block,
              //                                 color: Colors.red,
              //                                 size: 18,
              //                               ),
              //                               const SizedBox(width: 8),
              //                               Text(
              //                                 data[index].time.toString(),
              //                                 style: GoogleFonts.poppins(
              //                                   fontSize: 14,
              //                                   fontWeight: FontWeight.bold,
              //                                   color: Colors.white,
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //               );
              //             }),
              //           ),
              //         );
              //       },
              //       loading:
              //           () => const Scaffold(
              //             body: Center(
              //               child: LoadingIndicator(
              //                 indicatorType: Indicator.ballClipRotatePulse,
              //               ),
              //             ),
              //           ),
              //       error: (err, stack) {
              //         log('error is ${err}');
              //         return Scaffold(body: Center(child: Text('Error: $err')));
              //       },
              //     ),

              // const SizedBox(height: 20),
              Text(
                "Select Time",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ref
                  .watch(allTimeFetchProvider)
                  .when(
                    data: (data) {
                      // final availableTimes =
                      //     data
                      //         .where((element) => element.available == true)
                      //         .toList();
                      final availableTimes = data;

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        isExpanded: true,
                        hint: Text(
                          "Select available time",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: selectedTimes.isNotEmpty ? selectedTimes : null,
                        items:
                            availableTimes.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.time,
                                child: Text(
                                  item.available
                                      ? item.time
                                      : '${item.time} slot unavailble',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          final selected = data.firstWhere(
                            (t) => t.time == value,
                          );
                          if (selected.available == false) {
                            showSnackBar(context, 'Unavailable time slot');
                          } else {
                            setState(() {
                              selectedTimes = value!;
                              selectedTimeIndex = data.indexOf(selected);
                            });
                          }
                        },
                      );
                    },
                    loading:
                        () => const Center(
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotatePulse,
                          ),
                        ),
                    error: (err, stack) {
                      log('error is $err');
                      return Center(child: Text('Error: $err'));
                    },
                  ),
              const SizedBox(height: 20),

              // Calendar UI
              Text(
                "Select Date",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 120.h,
                width: double.infinity,
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate ?? DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: DateTime(2020, 1, 1),
                  maximumDate: DateTime(2035, 12, 31),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              // SizedBox(
              //   height: 120.h,
              //   width: double.infinity,
              //   child: GestureDetector(
              //     onTap: () async {
              //       DateTime? pickedDate = await showDatePicker(
              //         context: context,
              //         initialDate: selectedDate ?? DateTime.now(),
              //         firstDate: DateTime(2020, 1, 1),
              //         lastDate: DateTime(2035, 12, 31),
              //         builder: (context, child) {
              //           // If the platform is iOS, use CupertinoDatePicker style
              //           if (Theme.of(context).platform == TargetPlatform.iOS) {
              //             return CupertinoTheme(
              //               data: CupertinoThemeData(
              //                 brightness: Brightness.light,
              //               ),
              //               child: child!,
              //             );
              //           } else {
              //             return child!;
              //           }
              //         },
              //       );

              //       if (pickedDate != null && pickedDate != selectedDate) {
              //         setState(() {
              //           selectedDate = pickedDate;
              //         });
              //       }
              //     },
              //     child: Text(
              //       selectedDate != null
              //           ? "${selectedDate!.toLocal()}".split(' ')[0]
              //           : 'Select Date',
              //       style: TextStyle(fontSize: 18),
              //     ),
              //   ),
              // ),

              const SizedBox(height: 30),

              // Confirm button
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
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
        maxLines: 4,
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
