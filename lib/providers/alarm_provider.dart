import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm.dart';
import '../services/traffic_service.dart';
import '../services/weather_service.dart';

class AlarmProvider extends ChangeNotifier {
  final List<Alarm> _alarms = [];
  final WeatherService _weatherService = WeatherService();
  final TrafficService _trafficService = TrafficService();
  Map<String, dynamic>? _latestWeather;
  Map<String, dynamic>? _latestTraffic;

  // [신규] 마지막 조정 내역을 임시로 저장할 변수
  Map<String, dynamic>? lastAdjustmentDetails;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _deviceUid;

  String? get deviceUid => _deviceUid;
  List<Alarm> get alarms => _alarms;
  Map<String, dynamic>? get latestWeather => _latestWeather;
  Map<String, dynamic>? get latestTraffic => _latestTraffic;

  String? _frequentRouteDistrict;

  AlarmProvider() {
    initializeFirebase().then((_) => _loadData());
  }

  Future<void> initializeFirebase() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _deviceUid = userCredential.user?.uid;
      debugPrint('Anonymous User UID: $_deviceUid');
    } catch (e) {
      debugPrint('Firebase Anonymous Sign-In Error: $e');
    }
  }

  Future<void> _loadData() async {
    if (_deviceUid == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('alarms')
        .get();
    _alarms.clear();
    _alarms.addAll(snapshot.docs.map((doc) => Alarm.fromJson(doc.data())).toList());

    final weatherDoc = await _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('data')
        .doc('weather')
        .get();
    if (weatherDoc.exists) _latestWeather = weatherDoc.data();

    final trafficDoc = await _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('data')
        .doc('traffic')
        .get();
    if (trafficDoc.exists) _latestTraffic = trafficDoc.data();

    notifyListeners();
  }

  Future<void> saveData() async {
    if (_deviceUid == null) return;
    final batch = _firestore.batch();
    final alarmsRef = _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('alarms');

    final snapshot = await alarmsRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    for (var alarm in _alarms) {
      final docRef = alarmsRef.doc(alarm.documentId);
      batch.set(docRef, alarm.toJson());
    }
    batch.set(
      _firestore
          .collection('users')
          .doc(_deviceUid)
          .collection('data')
          .doc('weather'),
      _latestWeather ?? {},
    );
    batch.set(
      _firestore
          .collection('users')
          .doc(_deviceUid)
          .collection('data')
          .doc('traffic'),
      _latestTraffic ?? {},
    );
    await batch.commit();
    debugPrint('Data saved with custom alarm document IDs.');
  }

  Future<void> fetchWeatherAndAdjustAlarm(int index) async {
    if (index < 0 || index >= _alarms.length) return;

    final alarm = _alarms[index];
    final originalTime = alarm.time; // [수정] 덮어쓰기 전에 원래 시간 저장

    if (alarm.startPoint == null || alarm.endPoint == null || alarm.startPoint!.isEmpty || alarm.endPoint!.isEmpty) {
      debugPrint("경로가 설정되지 않아 '${alarm.name}' 알람을 조정할 수 없습니다.");
      return;
    }

    final travelTimeInSeconds = await _trafficService.getTravelTime(alarm.startPoint!, alarm.endPoint!);

    if (travelTimeInSeconds == null) {
      debugPrint("TMAP API 호출에 실패하여 알람을 조정할 수 없습니다.");
      return;
    }

    _latestWeather = await _weatherService.fetchWeather();

    int extraTimeInSeconds = 0;

    if (_latestWeather != null) {
      if ((_latestWeather!['precip'] as num? ?? 0) > 5) {
        extraTimeInSeconds += 15 * 60; // 15분
      }
      if ((_latestWeather!['temp'] as num? ?? 0) < 0) {
        extraTimeInSeconds += 10 * 60; // 10분
      }
    }

    final totalTravelTime = Duration(seconds: travelTimeInSeconds + extraTimeInSeconds);

    final now = DateTime.now();
    final desiredArrivalDateTime = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);

    final newDepartureDateTime = desiredArrivalDateTime.subtract(totalTravelTime);
    final newTime = TimeOfDay.fromDateTime(newDepartureDateTime);

    // [신규] 화면 표시를 위해 조정 내역을 변수에 저장
    String reason = "실시간 교통정보";
    List<String> reasons = [];
    if (_latestWeather != null) {
      if ((_latestWeather!['precip'] as num? ?? 0) > 5) reasons.add("강수 예보");
      if ((_latestWeather!['temp'] as num? ?? 0) < 0) reasons.add("저온");
    }
    if (reasons.isNotEmpty) {
      reason += " (${reasons.join(', ')})";
    }

    lastAdjustmentDetails = {
      'startPoint': alarm.startPoint,
      'endPoint': alarm.endPoint,
      'originalTime': originalTime,
      'adjustedTime': newTime,
      'reason': reason,
    };

    _alarms[index] = Alarm(
      name: alarm.name,
      time: newTime,
      days: alarm.days,
      ringtone: alarm.ringtone,
      startPoint: alarm.startPoint,
      endPoint: alarm.endPoint,
      district: alarm.district,
    );

    await saveData();
    notifyListeners();

    debugPrint("'${alarm.name}' 알람이 TMAP 데이터 기반으로 조정되었습니다: ${newTime.toString()}");
  }

  Future<void> fetchTraffic() async {
    final district = _latestWeather?['district'] ?? 'Hwaseong-si';
    _latestTraffic = await _trafficService.fetchTrafficData(district);
    await saveData();
    notifyListeners();
  }

  Future<void> fetchWeather() async {
    _latestWeather = await _weatherService.fetchWeather();
    await saveData();
    notifyListeners();
  }

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    saveData();
    notifyListeners();
  }

  void updateAlarm(int index, Alarm alarm) {
    _alarms[index] = alarm;
    saveData();
    notifyListeners();
  }

  void deleteAlarm(int index) {
    _alarms.removeAt(index);
    saveData();
    notifyListeners();
  }

  void setFrequentRoute(String district) {
    _frequentRouteDistrict = district;
    notifyListeners();
  }
}
