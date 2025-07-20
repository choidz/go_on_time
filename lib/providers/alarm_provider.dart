import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/traffic_service.dart';
import '../services/weather_service.dart';

class AlarmProvider extends ChangeNotifier {
  final List<Alarm> _alarms = [];
  final WeatherService _weatherService = WeatherService();
  final TrafficService _trafficService = TrafficService();
  Map<String, dynamic>? _latestWeather;
  Map<String, dynamic>? _latestTraffic;

  List<Alarm> get alarms => _alarms;
  Map<String, dynamic>? get latestWeather => _latestWeather;
  Map<String, dynamic>? get latestTraffic => _latestTraffic;

  Future<void> fetchWeatherAndAdjustAlarm(int index) async {
    _latestWeather = await _weatherService.fetchWeather();
    _latestTraffic = await _trafficService.fetchTrafficData();
    if (_latestWeather != null && _latestTraffic != null && index >= 0 && index < _alarms.length) {
      final alarm = _alarms[index];
      int extraTime = 0;

      // 날씨 기반 조정
      if (_latestWeather!['precip'] != null && _latestWeather!['precip']! > 5) {
        extraTime += 15; // 강수량 5mm 이상 시 15분 추가
      }
      if (_latestWeather!['temp'] != null && _latestWeather!['temp']! < 0) {
        extraTime += 10; // 기온 0도 이하 시 10분 추가
      }

      // 교통 기반 조정
      final avgTraffic = _latestTraffic!['averageTraffic'] as double? ?? 0;
      if (avgTraffic > 1000) { // 평균 교통량 1000 이상 시 정체로 간주, 15분 추가
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
      notifyListeners();
    }
  }

  // 기상청 API 호출만 위한 메서드 (UI 갱신용)
  Future<void> fetchWeather() async {
    _latestWeather = await _weatherService.fetchWeather();
    notifyListeners();
  }

  // 교통 데이터 호출만 위한 메서드 (UI 갱신용)
  Future<void> fetchTraffic() async {
    _latestTraffic = await _trafficService.fetchTrafficData();
    notifyListeners();
  }

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    notifyListeners();
  }

  void updateAlarm(int index, Alarm alarm) {
    _alarms[index] = alarm;
    notifyListeners();
  }

  void deleteAlarm(int index) {
    _alarms.removeAt(index);
    notifyListeners();
  }
}