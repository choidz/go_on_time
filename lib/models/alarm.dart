import 'package:flutter/material.dart';

class Alarm {
  final String name;
  final TimeOfDay time;
  final List<bool> days; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final String ringtone;
  final String? district; // 자주 가는 길(동 단위) - 선택적, 미래 기능용

  Alarm({
    required this.name,
    required this.time,
    this.days = const [true, true, true, true, true, false, false],
    this.ringtone = 'Default',
    this.district, // 기본값 null
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'hour': time.hour,
    'minute': time.minute,
    'days': days,
    'ringtone': ringtone,
    'district': district, // 새 필드 추가
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    name: json['name'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    days: List<bool>.from(json['days']),
    ringtone: json['ringtone'],
    district: json['district'], // 새 필드 처리 (null 허용)
  );
}