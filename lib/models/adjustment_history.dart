import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdjustmentHistory {
  final String alarmName;
  final TimeOfDay originalTime;
  final TimeOfDay adjustedTime;
  final String reason;
  final Timestamp timestamp; // Firestore의 Timestamp 타입을 사용해 시간순 정렬을 용이하게 합니다.

  AdjustmentHistory({
    required this.alarmName,
    required this.originalTime,
    required this.adjustedTime,
    required this.reason,
    required this.timestamp,
  });

  // Firestore 저장을 위한 Map 변환
  Map<String, dynamic> toJson() => {
    'alarmName': alarmName,
    'originalHour': originalTime.hour,
    'originalMinute': originalTime.minute,
    'adjustedHour': adjustedTime.hour,
    'adjustedMinute': adjustedTime.minute,
    'reason': reason,
    'timestamp': timestamp,
  };

  // Firestore 데이터를 객체로 변환
  factory AdjustmentHistory.fromJson(Map<String, dynamic> json) => AdjustmentHistory(
    alarmName: json['alarmName'],
    originalTime: TimeOfDay(hour: json['originalHour'], minute: json['originalMinute']),
    adjustedTime: TimeOfDay(hour: json['adjustedHour'], minute: json['adjustedMinute']),
    reason: json['reason'],
    timestamp: json['timestamp'],
  );
}
