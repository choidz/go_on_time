import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 추가

class WeatherService {
  // .env에서 API 키 로드 (런타임 시 초기화)
  String get _serviceKey {
    return dotenv.env['WEATHER_API_KEY'] ?? '';
  }

  Future<Map<String, dynamic>?> fetchWeather() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

    final grid = _convertToGrid(position.latitude, position.longitude);

    final now = DateTime.now();
    final baseDate = DateFormat('yyyyMMdd').format(now);
    final baseTime = DateFormat('HH00').format(now.subtract(const Duration(minutes: 20)));

    final url = Uri.parse(
        'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
            '?serviceKey=$_serviceKey&numOfRows=100&dataType=JSON'
            '&base_date=$baseDate&base_time=$baseTime&nx=${grid.x}&ny=${grid.y}'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['response']['body']['items']['item'];

      double? temp, humid, wind, precip; // 강수량(PPTN) 추가

      for (var item in items) {
        switch (item['category']) {
          case 'T1H': // 기온
            temp = double.tryParse(item['obsrValue'].toString());
            break;
          case 'REH': // 습도
            humid = double.tryParse(item['obsrValue'].toString());
            break;
          case 'WSD': // 풍속
            wind = double.tryParse(item['obsrValue'].toString());
            break;
          case 'PPTN': // 강수량 (초단기실황에서 제공 여부 확인 필요)
            precip = double.tryParse(item['obsrValue'].toString());
            break;
        }
      }

      return {'temp': temp, 'humid': humid, 'wind': wind, 'precip': precip};
    } else {
      debugPrint('기상청 API 오류: ${response.body}');
      return null;
    }
  }

  GridXY _convertToGrid(double lat, double lon) {
    const double RE = 6371.00877;
    const double GRID = 5.0;
    const double SLAT1 = 30.0;
    const double SLAT2 = 60.0;
    const double OLON = 126.0;
    const double OLAT = 38.0;
    const double XO = 43;
    const double YO = 136;

    double DEGRAD = pi / 180.0;
    double re = RE / GRID;
    double slat1 = SLAT1 * DEGRAD;
    double slat2 = SLAT2 * DEGRAD;
    double olon = OLON * DEGRAD;
    double olat = OLAT * DEGRAD;

    double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);
    double sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = pow(sf, sn) * cos(slat1) / sn;
    double ro = tan(pi * 0.25 + olat * 0.5);
    ro = re * sf / pow(ro, sn);

    double ra = tan(pi * 0.25 + lat * DEGRAD * 0.5);
    ra = re * sf / pow(ra, sn);
    double theta = lon * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    int x = (ra * sin(theta) + XO + 0.5).floor();
    int y = (ro - ra * cos(theta) + YO + 0.5).floor();
    return GridXY(x, y);
  }
}

class GridXY {
  final int x;
  final int y;
  GridXY(this.x, this.y);
}