import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm.dart';
import '../models/adjustment_history.dart';
import '../services/traffic_service.dart';
import '../services/weather_service.dart';

class AlarmProvider extends ChangeNotifier {
  final List<Alarm> _alarms = [];
  final WeatherService _weatherService = WeatherService();
  final TrafficService _trafficService = TrafficService();
  Map<String, dynamic>? _latestWeather;
  Map<String, dynamic>? _latestTraffic;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _deviceUid;

  String? get deviceUid => _deviceUid;
  List<Alarm> get alarms => _alarms;
  Map<String, dynamic>? get latestWeather => _latestWeather;
  Map<String, dynamic>? get latestTraffic => _latestTraffic;

  String? _frequentRouteDistrict;

  final List<AdjustmentHistory> _history = [];
  List<AdjustmentHistory> get history => _history;

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

  // --- ✨ 1. _loadData에서 히스토리 로딩 로직 호출 ---
  Future<void> _loadData() async {
    if (_deviceUid == null) return;
    // 여러 데이터를 동시에 불러와 앱 로딩 속도를 개선합니다.
    await Future.wait([
      _loadAlarms(),
      _loadWeatherData(),
      _loadTrafficData(),
      _loadHistory(), // 히스토리 데이터 로딩 함수 호출
    ]);
    notifyListeners();
  }

  // 가독성을 위해 각 데이터 로딩 로직을 별도 함수로 분리합니다.
  Future<void> _loadAlarms() async {
    if (_deviceUid == null) return;
    final snapshot = await _firestore.collection('users').doc(_deviceUid).collection('alarms').get();
    _alarms.clear();
    _alarms.addAll(snapshot.docs.map((doc) => Alarm.fromJson(doc.data())).toList());
  }

  Future<void> _loadWeatherData() async {
    if (_deviceUid == null) return;
    final weatherDoc = await _firestore.collection('users').doc(_deviceUid).collection('data').doc('weather').get();
    if (weatherDoc.exists) _latestWeather = weatherDoc.data();
  }

  Future<void> _loadTrafficData() async {
    if (_deviceUid == null) return;
    final trafficDoc = await _firestore.collection('users').doc(_deviceUid).collection('data').doc('traffic').get();
    if (trafficDoc.exists) _latestTraffic = trafficDoc.data();
  }

  // --- ✨ 2. 히스토리 데이터를 불러오는 함수 추가 ---
  Future<void> _loadHistory() async {
    if (_deviceUid == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('adjustment_history')
        .orderBy('timestamp', descending: true) // 최신순으로 정렬
        .get();
    _history.clear();
    _history.addAll(snapshot.docs.map((doc) => AdjustmentHistory.fromJson(doc.data())).toList());
  }

  Future<void> saveData() async {
    if (_deviceUid == null) return;
    final batch = _firestore.batch();
    final alarmsRef = _firestore.collection('users').doc(_deviceUid).collection('alarms');

    final snapshot = await alarmsRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    for (var alarm in _alarms) {
      final docRef = alarmsRef.doc(alarm.documentId);
      batch.set(docRef, alarm.toJson());
    }
    batch.set(_firestore.collection('users').doc(_deviceUid).collection('data').doc('weather'), _latestWeather ?? {});
    batch.set(_firestore.collection('users').doc(_deviceUid).collection('data').doc('traffic'), _latestTraffic ?? {});
    await batch.commit();
    debugPrint('Data saved with custom alarm document IDs.');
  }

  Future<void> fetchWeatherAndAdjustAlarm(int index) async {
    if (index < 0 || index >= _alarms.length) return;

    final alarm = _alarms[index];
    final originalTime = alarm.time;

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
      if ((_latestWeather!['precip'] as num? ?? 0) > 5) extraTimeInSeconds += 15 * 60;
      if ((_latestWeather!['temp'] as num? ?? 0) < 0) extraTimeInSeconds += 10 * 60;
    }

    final totalTravelTime = Duration(seconds: travelTimeInSeconds + extraTimeInSeconds);
    final now = DateTime.now();
    final desiredArrivalDateTime = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    final newDepartureDateTime = desiredArrivalDateTime.subtract(totalTravelTime);
    final newTime = TimeOfDay.fromDateTime(newDepartureDateTime);

    String reason = "실시간 교통정보";
    List<String> reasons = [];
    if (_latestWeather != null) {
      if ((_latestWeather!['precip'] as num? ?? 0) > 5) reasons.add("강수 예보");
      if ((_latestWeather!['temp'] as num? ?? 0) < 0) reasons.add("저온");
    }
    if (reasons.isNotEmpty) {
      reason += " (${reasons.join(', ')})";
    }

    _alarms[index] = Alarm(
      name: alarm.name,
      time: newTime,
      days: alarm.days,
      ringtone: alarm.ringtone,
      startPoint: alarm.startPoint,
      endPoint: alarm.endPoint,
      district: alarm.district,
      originalTime: originalTime,
      adjustmentReason: reason,
      lastAdjustedTime: DateTime.now(),
    );

    await saveData();

    // --- ✨ 3. 히스토리 기록 로직 추가 ---
    final historyEntry = AdjustmentHistory(
      alarmName: alarm.name,
      originalTime: originalTime,
      adjustedTime: newTime,
      reason: reason,
      timestamp: Timestamp.now(), // 현재 시각을 Firestore Timestamp로 저장
    );

    // Firestore 'adjustment_history' 컬렉션에 새 문서 추가
    await _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('adjustment_history')
        .add(historyEntry.toJson());

    // 로컬 히스토리 리스트의 맨 앞에 새 기록 추가 (UI 즉시 반영용)
    _history.insert(0, historyEntry);

    notifyListeners();
    debugPrint("'${alarm.name}' 알람 조정 완료 및 히스토리 기록됨.");
  }

  // 이하 다른 메서드들은 그대로 유지
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
