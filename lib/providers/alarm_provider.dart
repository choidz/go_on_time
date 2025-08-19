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

  // saveData 메서드를 수정하여 규칙적인 문서 ID를 사용하도록 합니다.
  Future<void> saveData() async {
    if (_deviceUid == null) return;
    final batch = _firestore.batch();
    final alarmsRef = _firestore
        .collection('users')
        .doc(_deviceUid)
        .collection('alarms');

    // 기존 문서를 모두 삭제합니다.
    // (알람 정보가 변경되면 ID도 바뀌므로, 이 방식이 가장 간단하고 확실합니다.)
    final snapshot = await alarmsRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // 각 알람에 대해 규칙적인 ID를 생성하여 문서를 set 합니다.
    for (var alarm in _alarms) {
      // ★★★ 여기가 핵심 변경 부분입니다 ★★★
      // Firestore의 자동 ID 대신 alarm.documentId를 사용합니다.
      final docRef = alarmsRef.doc(alarm.documentId);
      batch.set(docRef, alarm.toJson());
    }

    // 날씨, 교통 데이터 저장은 기존과 동일합니다.
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

  // ... 이하 나머지 코드는 모두 동일 ...
  Future<void> fetchWeatherAndAdjustAlarm(int index) async {
    _latestWeather = await _weatherService.fetchWeather();
    _latestTraffic = await _trafficService.fetchTrafficData(_frequentRouteDistrict ?? _latestWeather?['district']);
    if (_latestWeather != null && _latestTraffic != null && index >= 0 && index < _alarms.length) {
      final alarm = _alarms[index];
      int extraTime = 0;

      if (_latestWeather!['precip'] != null && _latestWeather!['precip']! > 5) {
        extraTime += 15;
      }
      if (_latestWeather!['temp'] != null && _latestWeather!['temp']! < 0) {
        extraTime += 10;
      }

      final avgTraffic = _latestTraffic!['averageTraffic'] as double? ?? 0;
      if (avgTraffic > 1000) {
        extraTime += 15;
      }

      if (extraTime > 0) {
        final newTime = alarm.time.replacing(
          hour: alarm.time.hour,
          minute: alarm.time.minute - extraTime,
        );
        _alarms[index] = Alarm(
          name: alarm.name,
          time: newTime,
          days: alarm.days,
          ringtone: alarm.ringtone,
        );
      }
      await saveData();
      notifyListeners();
    }
  }

  Future<void> fetchWeather() async {
    _latestWeather = await _weatherService.fetchWeather();
    await saveData();
    notifyListeners();
  }

  Future<void> fetchTraffic() async {
    final district = _latestWeather?['district'] ?? 'Hwaseong-si'; // 화성시 기본값
    _latestTraffic = await _trafficService.fetchTrafficData(district);
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
