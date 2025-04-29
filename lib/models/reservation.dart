class Reservation {
  final String id;
  final String customerId; // Can be empty if guest user
  final String customerName;
  final String contactNumber;
  final int numberOfGuests;
  final DateTime reservationDate;
  final String reservationTime; // Store time as a string like "19:30"
  final String specialRequest; // Optional (e.g., "Window seat")
  final String status; // "Pending", "Confirmed", "Cancelled"

  Reservation({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.numberOfGuests,
    required this.reservationDate,
    required this.reservationTime,
    this.specialRequest = '',
    this.status = 'Pending',
  });

  // Convert a Reservation object to a Map (for Firestore or local DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'contactNumber': contactNumber,
      'numberOfGuests': numberOfGuests,
      'reservationDate': reservationDate.toIso8601String(),
      'reservationTime': reservationTime,
      'specialRequest': specialRequest,
      'status': status,
    };
  }

  // Create a Reservation object from a Map (for fetching from DB)
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      contactNumber: map['contactNumber'],
      numberOfGuests: map['numberOfGuests'],
      reservationDate: DateTime.parse(map['reservationDate']),
      reservationTime: map['reservationTime'],
      specialRequest: map['specialRequest'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}
