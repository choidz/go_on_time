import 'package:flutter/material.dart';

class Alarm {
  final String name;
  final TimeOfDay time;
  final List<bool> days;
  final String ringtone;
  final String? district;
  final String? startPoint;
  final String? endPoint;

  Alarm({
    required this.name,
    required this.time,
    this.days = const [true, true, true, true, true, false, false],
    this.ringtone = 'Default',
    this.district,
    this.startPoint,
    this.endPoint,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'hour': time.hour,
    'minute': time.minute,
    'days': days,
    'ringtone': ringtone,
    'district': district,
    'startPoint': startPoint,
    'endPoint': endPoint,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    name: json['name'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    days: List<bool>.from(json['days']),
    ringtone: json['ringtone'],
    district: json['district'],
    startPoint: json['startPoint'],
    endPoint: json['endPoint'],
  );

  // documentId getter는 그대로 유지합니다.
  String get documentId {
    final timeString = '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';
    const dayChars = ['월', '화', '수', '목', '금', '토', '일'];
    String daysString = '';
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        daysString += dayChars[i];
      }
    }
    if (daysString.isEmpty) {
      daysString = '반복없음';
    }
    final sanitizedName = name.replaceAll(RegExp(r'\\s+'), '');
    return '$timeString-$sanitizedName-$daysString';
  }
}
