// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StoreHour {
  final String day;
  final String openTime;
  final String closeTime;
  final bool isClosed;
  bool isAvailable;

  StoreHour({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
    this.isAvailable = true,
  });

  StoreHour copyWith({
    String? day,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) {
    return StoreHour(
      day: day ?? this.day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  factory StoreHour.fromMap(Map<String, dynamic> map) {
    return StoreHour(
      day: map['day'] ?? '',
      openTime: map['openTime'] ?? '',
      closeTime: map['closeTime'] ?? '',
      isClosed: map['isClosed'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreHour.fromJson(String source) =>
      StoreHour.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoreHour(day: $day, openTime: $openTime, closeTime: $closeTime, isClosed: $isClosed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StoreHour &&
        other.day == day &&
        other.openTime == openTime &&
        other.closeTime == closeTime &&
        other.isClosed == isClosed;
  }

  @override
  int get hashCode {
    return day.hashCode ^
        openTime.hashCode ^
        closeTime.hashCode ^
        isClosed.hashCode;
  }
}

class StoreLive {
  bool islive;
  StoreLive({required this.islive});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'islive': islive};
  }

  factory StoreLive.fromMap(Map<String, dynamic> map) {
    return StoreLive(islive: map['islive'] as bool);
  }

  String toJson() => json.encode(toMap());

  factory StoreLive.fromJson(String source) =>
      StoreLive.fromMap(json.decode(source) as Map<String, dynamic>);
}
