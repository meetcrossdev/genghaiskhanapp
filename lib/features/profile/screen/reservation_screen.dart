import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReservationHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservation History"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your reservation history'),
            SizedBox(height: 20),
            // Reservation list section
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Example number of reservations
                itemBuilder: (context, index) {
                  return ReservationHistoryItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationHistoryItem extends StatelessWidget {
  final String reservationId = "#123456";
  final String status = "Confirmed";
  final String date = "10th April, 2025";
  final String time = "7:00 PM";
  final int guests = 2;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservation ID: $reservationId",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Date: $date"),
            Text("Time: $time"),
            Text("Guests: $guests"),
            SizedBox(height: 8),
            Text(
              "Status: $status",
              style: TextStyle(
                color: status == "Confirmed" ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Option to modify reservation logic
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  child: Text('Modify'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Option to cancel reservation logic
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
