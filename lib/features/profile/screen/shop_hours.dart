import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/constant/colors.dart';
import '../../../models/store_hours.dart';
import '../../home/controller/store_hours_controller.dart';
import '../../home/repository/store_hours_repository.dart';

class StoreHoursScreen extends ConsumerStatefulWidget {
  const StoreHoursScreen({super.key});

  @override
  _StoreHoursScreenState createState() => _StoreHoursScreenState();
}

class _StoreHoursScreenState extends ConsumerState<StoreHoursScreen> {
  static const Map<String, TimeOfDay> defaultOpeningTimes = {
    "Monday": TimeOfDay(hour: 9, minute: 0),
    "Tuesday": TimeOfDay(hour: 9, minute: 0),
    "Wednesday": TimeOfDay(hour: 9, minute: 0),
    "Thursday": TimeOfDay(hour: 9, minute: 0),
    "Friday": TimeOfDay(hour: 9, minute: 0),
    "Saturday": TimeOfDay(hour: 9, minute: 0),
    "Sunday": TimeOfDay(hour: 9, minute: 0),
  };

  static const Map<String, TimeOfDay> defaultClosingTimes = {
    "Monday": TimeOfDay(hour: 21, minute: 0),
    "Tuesday": TimeOfDay(hour: 21, minute: 0),
    "Wednesday": TimeOfDay(hour: 21, minute: 0),
    "Thursday": TimeOfDay(hour: 21, minute: 0),
    "Friday": TimeOfDay(hour: 21, minute: 0),
    "Saturday": TimeOfDay(hour: 21, minute: 0),
    "Sunday": TimeOfDay(hour: 21, minute: 0),
  };

  late Map<String, bool> _isOpen = {
    for (var day in defaultOpeningTimes.keys) day: true,
  };
  late Map<String, TimeOfDay> _openingTimes = Map.from(
    defaultOpeningTimes,
  ); //display openaing
  late Map<String, TimeOfDay> _closingTimes = Map.from(
    defaultClosingTimes,
  ); //display closing time

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreHours();
  }

  //fetching the store hours from server
  void _fetchStoreHours() {
    ref
        .read(storeHoursProvider(storeId))
        .when(
          data: (hours) {
            setState(() {
              if (hours.isNotEmpty) {
                _isOpen = {for (var hour in hours) hour.day: !hour.isClosed};
                _openingTimes = {
                  for (var hour in hours) hour.day: _parseTime(hour.openTime),
                };
                _closingTimes = {
                  for (var hour in hours) hour.day: _parseTime(hour.closeTime),
                };
              }
              _isLoading = false;
            });
          },
          loading: () => setState(() => _isLoading = true),
          error: (err, stack) {
            setState(() => _isLoading = false);
            print("Error fetching store hours: $err");
          },
        );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa), // Light background for the screen
      appBar: AppBar(
        backgroundColor: Apptheme.logoInsideColor, // Custom color from theme
        title: const Text("Store Hours", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // White color for back button
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Detect if device is tablet or web
          bool isTablet = constraints.maxWidth > 600;
          bool isWeb = kIsWeb;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isTablet || isWeb
                    // Grid layout for tablet/web view
                    ? Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2, // Two columns
                            childAspectRatio:
                                2.6.sp, // Adjust width/height ratio
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: _buildStoreHoursList(
                              isGrid: true,
                            ), // Generate cards
                          ),
                        ),
                      ],
                    )
                    // List layout for mobile view
                    : ListView(children: _buildStoreHoursList(isGrid: false)),
          );
        },
      ),
    );
  }

  // Builds a list of store hour cards (either for grid or list view)
  List<Widget> _buildStoreHoursList({required bool isGrid}) {
    return _isOpen.keys.map((day) {
      return Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the day (e.g., Monday, Tuesday)
              Text(
                day,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge (Open/Closed)
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color:
                          _isOpen[day]!
                              ? Colors.green
                              : Colors.red, // Green if open, red if closed
                    ),
                    child: Text(
                      _isOpen[day]! ? "Open" : "Closed",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Show time row only if the store is open
              if (_isOpen[day]!) _buildTimeRow(day),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Builds the time row with opening and closing time pickers
  Widget _buildTimeRow(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Opening time picker
        GestureDetector(
          onTap: () {}, // You can add time picker logic here
          child: _buildTimePicker(_openingTimes[day]!),
        ),
        const Text(" - "), // Separator
        // Closing time picker
        GestureDetector(
          onTap: () {}, // You can add time picker logic here
          child: _buildTimePicker(_closingTimes[day]!),
        ),
      ],
    );
  }

  // Builds a styled time display box
  Widget _buildTimePicker(TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        DateFormat.jm().format(
          DateTime(2024, 1, 1, time.hour, time.minute),
        ), // Format time (e.g., 2:00 PM)
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
