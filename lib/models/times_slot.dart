class TimeSlot {
  final String id;
  final String time;
  final bool available;

  TimeSlot({
    required this.id,
    required this.time,
    required this.available,
  });

  // 🔁 Convert from Firestore document
  factory TimeSlot.fromMap(Map<String, dynamic> map, String id) {
    return TimeSlot(
      id: id,
      time: map['time'] ?? '',
      available: map['available'] ?? false,
    );
  }

  // 🔁 Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'available': available,
    };
  }

  // ✅ CopyWith for updating fields
  TimeSlot copyWith({
    String? id,
    String? time,
    bool? available,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      time: time ?? this.time,
      available: available ?? this.available,
    );
  }
}
