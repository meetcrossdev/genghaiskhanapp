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
  late Map<String, TimeOfDay> _openingTimes = Map.from(defaultOpeningTimes);
  late Map<String, TimeOfDay> _closingTimes = Map.from(defaultClosingTimes);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreHours();
  }

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

  Future<void> _selectTime(
    BuildContext context,
    String day,
    bool isOpening,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTimes[day]! : _closingTimes[day]!,
    );

    if (pickedTime != null) {
      setState(() {
        if (isOpening) {
          _openingTimes[day] = pickedTime;
        } else {
          _closingTimes[day] = pickedTime;
        }
      });
    }
  }

  void _saveStoreHours() {
    final List<StoreHour> updatedHours =
        _isOpen.keys.map((day) {
          return StoreHour(
            day: day,
            openTime:
                "${_openingTimes[day]!.hour}:${_openingTimes[day]!.minute}",
            closeTime:
                "${_closingTimes[day]!.hour}:${_closingTimes[day]!.minute}",
            isClosed: !_isOpen[day]!,
          );
        }).toList();

    ref
        .read(storeHourControllerProvider.notifier)
        .updateStoreHours(
          hours: updatedHours,
          context: context,
          storeId: storeId,
        );
    ref
        .read(storeHourControllerProvider.notifier)
        .updateStoreStatus(context: context, isLive: true);
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Apptheme.logoInsideColor,
        title: const Text("Store Hours", style: TextStyle(color: Colors.white)),

        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          bool isWeb = kIsWeb;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isTablet || isWeb
                    ? Column(
                      children: [
                        // ElevatedButton(
                        //   onPressed: () {},
                        //   child: Text('Holidy '),
                        // ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 2.6.sp,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: _buildStoreHoursList(isGrid: true),
                          ),
                        ),
                      ],
                    )
                    : ListView(children: _buildStoreHoursList(isGrid: false)),
          );
        },
      ),
    );
  }

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
                  // Switch(
                  //   value: _isOpen[day]!,
                  //   onChanged: (value) {
                  //     // setState(() {
                  //     //   _isOpen[day] = value;
                  //     // });
                  //   },
                  // ),
                  Container(
                    padding: EdgeInsets.all(10),
                    //  height: 20.h,
                    // width: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: _isOpen[day]! ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      _isOpen[day]! ? "Open" : "Closed",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              if (_isOpen[day]!) _buildTimeRow(day),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTimeRow(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {},
          child: _buildTimePicker(_openingTimes[day]!),
        ),
        const Text(" - "),
        GestureDetector(
          onTap: () {},
          child: _buildTimePicker(_closingTimes[day]!),
        ),
      ],
    );
  }

  Widget _buildTimePicker(TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        DateFormat.jm().format(DateTime(2024, 1, 1, time.hour, time.minute)),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
