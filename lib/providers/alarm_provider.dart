import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/weather_service.dart';

class AlarmProvider extends ChangeNotifier {
  final List<Alarm> _alarms = [];
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _latestWeather;

  List<Alarm> get alarms => _alarms;
  Map<String, dynamic>? get latestWeather => _latestWeather;

  Future<void> fetchWeatherAndAdjustAlarm(int index) async {
    _latestWeather = await _weatherService.fetchWeather();
    if (_latestWeather != null && index >= 0 && index < _alarms.length) {
      final alarm = _alarms[index];
      int extraTime = 0;
      if (_latestWeather!['precip'] != null && _latestWeather!['precip']! > 5) {
        extraTime += 15;
      }
      if (_latestWeather!['temp'] != null && _latestWeather!['temp']! < 0) {
        extraTime += 10;
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