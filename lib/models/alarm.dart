import 'package:flutter/material.dart';

class Alarm {
  final String name;
  final TimeOfDay time;
  final List<bool> days;
  final String ringtone;
  final String? district;
  final String? startPoint;
  final String? endPoint;

  // --- 🔽 1. 조정 내역을 저장할 필드 추가 ---
  // TimeOfDay 대신 DateTime을 사용하면 '가장 최근' 조정 시점을 날짜까지 포함해
  // 정확하게 비교할 수 있어 더 좋습니다.
  final DateTime? lastAdjustedTime;
  final TimeOfDay? originalTime;
  final String? adjustmentReason;

  Alarm({
    required this.name,
    required this.time,
    this.days = const [true, true, true, true, true, false, false],
    this.ringtone = 'Default',
    this.district,
    this.startPoint,
    this.endPoint,
    // --- 🔽 생성자에 추가된 필드 반영 ---
    this.lastAdjustedTime,
    this.originalTime,
    this.adjustmentReason,
  });

  // Firestore에 저장하기 위한 Map 변환 함수
  Map<String, dynamic> toJson() => {
    'name': name,
    'hour': time.hour,
    'minute': time.minute,
    'days': days,
    'ringtone': ringtone,
    'district': district,
    'startPoint': startPoint,
    'endPoint': endPoint,
    // --- 🔽 2. 새로 추가된 필드를 JSON으로 직렬화 ---
    // DateTime은 ISO 8601 형식의 문자열로 저장하는 것이 표준적입니다.
    'lastAdjustedTime': lastAdjustedTime?.toIso8601String(),
    // TimeOfDay는 Firestore에 직접 저장할 수 없으므로 hour와 minute으로 분리합니다.
    'originalHour': originalTime?.hour,
    'originalMinute': originalTime?.minute,
    'adjustmentReason': adjustmentReason,
  };

  // Firestore에서 받아온 Map 데이터를 Alarm 객체로 변환하는 팩토리 생성자
  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    name: json['name'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    days: List<bool>.from(json['days']),
    ringtone: json['ringtone'],
    district: json['district'],
    startPoint: json['startPoint'],
    endPoint: json['endPoint'],
    // --- 🔽 3. JSON 데이터를 새로 추가된 필드로 역직렬화 ---
    // 저장된 문자열을 다시 DateTime 객체로 파싱합니다.
    lastAdjustedTime: json['lastAdjustedTime'] == null
        ? null
        : DateTime.parse(json['lastAdjustedTime']),
    // 분리해서 저장했던 originalHour, originalMinute을 다시 TimeOfDay 객체로 합칩니다.
    originalTime: json['originalHour'] == null
        ? null
        : TimeOfDay(hour: json['originalHour'], minute: json['originalMinute']),
    adjustmentReason: json['adjustmentReason'],
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
    // 사소한 수정: '\\s+' -> '\s+'
    final sanitizedName = name.replaceAll(RegExp(r'\s+'), '');
    return '$timeString-$sanitizedName-$daysString';
  }
}
