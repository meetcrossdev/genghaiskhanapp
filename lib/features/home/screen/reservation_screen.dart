import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/features/auth/widgets/authtextfield.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();


   // Show confirmation reservation dialog
  void _confirmReservation() {
 
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
    var user = ref.read(userProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
     
      ),
      //display the confirm button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            //validation for number of people
            if (selectedTimeIndex == -1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a time!")),
              );
              return;
            }
             //use case if user is null
            if (user == null) {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("name and phone field can not be empty"),
                  ),
                );
                return;
              }
            }
            //validation for date
            if (selectedDate!.isBefore(
              DateTime.now().subtract(const Duration(days: 1)),
            )) {
              // Show message
              showSnackBar(context, 'Please select an upcoming day.');
              return; // Stop further logic
            }

            final weekday = selectedDate!.weekday; // 1 = Monday, 7 = Sunday

            // Rule 1: No reservations on Monday or Sunday
            if (weekday == DateTime.monday || weekday == DateTime.sunday) {
              showSnackBar(
                context,
                'No reservations available on Monday and Sunday.',
              );
              return;
            }

            String selectedTime = selectedTimes;

            // Rule 2: No reservations on Saturday between 11:15 AM and 12:00 PM
            if (weekday == DateTime.saturday) {
              log('selected Time is ${selectedTime}');
              if (selectedTime == "11:15 AM" ||
                  selectedTime == "11:30 AM" ||
                  selectedTime == "11:45 AM" ||
                  selectedTime == "12:00 PM") {
                showSnackBar(
                  context,
                  'Reservations are not available on Saturday from 11:15 AM to 12:00 PM.',
                );
                return;
              }
            }

            // String selectedTime = selectedTimes;

            final reservation = Reservation(
              id: Uuid().v4(),

              customerId: user == null ? '' : user.id,
              customerName:
                  user == null ? nameController.text.trim() : user.name,
              contactNumber:
                  user == null ? phoneController.text.trim() : user.phoneNo,
              numberOfGuests: selectedNumber,
              reservationDate: selectedDate!,
              reservationTime: selectedTime,
              specialRequest: notesController.text,
            );

            log('reservation added');
            ref
                .read(reservationControllerProvider.notifier)
                .addReservation(reservation: reservation, context: context);

            //   _confirmReservation();
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
                  border: Border.all(color: Apptheme.logoInsideColor),
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
              //if user is not loged in then name and phone field is displayed
              if (user == null) ...[
                SizedBox(height: 10.h),
                Text(
                  "Enter Name",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AuthTextField(title: 'Name', controller: nameController),
                SizedBox(height: 10.h),
                Text(
                  "Enter Phone No",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AuthTextField(title: 'Phone No', controller: phoneController),
              ],

              //  const SizedBox(height: 8),
              const SizedBox(height: 30),

              //    Time selection
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
                      final format = DateFormat.jm(); // e.g., "12:15 PM"
                      final now = DateTime.now();
                      final isSaturday = now.weekday == DateTime.saturday;

                      final isClosed =
                          now.weekday == DateTime.sunday ||
                          now.weekday == DateTime.monday;

                      final sortedSlots =
                          data..sort((a, b) {
                            final timeA = format.parse(a.time);
                            final timeB = format.parse(b.time);
                            return timeA.compareTo(timeB);
                          });

                      final filteredSlots =
                          isSaturday
                              ? sortedSlots.sublist(
                                4,
                              ) // Skip the first 4 slots on Tuesday
                              : sortedSlots;

                      print(
                        filteredSlots.map((slot) => slot.time).toList(),
                      ); // Output filtered slots

                      final availableTimes = filteredSlots;

                      return isClosed
                          ? Text('Monday and Sunday the resturent is closed')
                          : Container(
                            width: double.infinity,
                            height: 200.h,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(data.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (data[index].available == false) {
                                        showSnackBar(
                                          context,
                                          'Unavailable time slot',
                                        );
                                        return;
                                      }
                                      setState(() {
                                        selectedTimes = data[index].time;
                                        selectedTimeIndex = index;
                                      });
                                    },
                                    child:
                                        data[index].available == true
                                            ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedTimeIndex == index
                                                        ? Colors.pink.shade100
                                                        : Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                data[index].time.toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      selectedTimeIndex == index
                                                          ? Colors.pink
                                                          : Colors.black,
                                                ),
                                              ),
                                            )
                                            : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.block,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    data[index].time.toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                  );
                                }),
                              ),
                            ),
                          );
                    },
                    loading:
                        () => const Scaffold(
                          body: Center(
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballClipRotatePulse,
                            ),
                          ),
                        ),
                    error: (err, stack) {
                      log('error is ${err}');
                      return Scaffold(body: Center(child: Text('Error: $err')));
                    },
                  ),

        
              const SizedBox(height: 8),

            
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
              const SizedBox(height: 12),
              //additional notes UI
              Text(
                "Add Notes(Optional)",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              buildTextField(
                notesController,
                'Additional Notes',
                'notes',
                Icons.notes,
                false,
              ),

            
              const SizedBox(height: 30),

              // Confirm button
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
//input textfield Ui
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
