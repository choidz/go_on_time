import 'package:flutter/material.dart';

class Alarm {
  final String name;
  final TimeOfDay time;
  final List<bool> days; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final String ringtone;

  Alarm({
    required this.name,
    required this.time,
    this.days = const [true, true, true, true, true, false, false],
    this.ringtone = 'Default',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'hour': time.hour,
    'minute': time.minute,
    'days': days,
    'ringtone': ringtone,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    name: json['name'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    days: List<bool>.from(json['days']),
    ringtone: json['ringtone'],
  );
}