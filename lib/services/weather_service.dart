import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geo; // 좌표 -> 주소 변환
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final http.Client _httpClient;

  WeatherService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  String get _serviceKey {
    final key = dotenv.env['WEATHER_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('경고: WEATHER_API_KEY가 없거나 비어 있음');
      return '';
    }
    return key;
  }

  Future<Map<String, dynamic>?> fetchWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          debugPrint('위치 권한이 거부됨');
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final placemarks = await geo.placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final region = place?.administrativeArea ?? '알 수 없음'; // 예: 서울, 부산
      debugPrint('현재 위치: $region (위도: ${position.latitude}, 경도: ${position.longitude})');

      final grid = _convertToGrid(position.latitude, position.longitude);
      debugPrint('격자 좌표: nx=${grid.x}, ny=${grid.y}');
      final now = DateTime.now();
      final baseDate = DateFormat('yyyyMMdd').format(now);
      final baseTime = DateFormat('HH00').format(now.subtract(const Duration(minutes: 20)));

      final url = Uri.parse(
          'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
              '?serviceKey=$_serviceKey&numOfRows=100&dataType=JSON'
              '&base_date=$baseDate&base_time=$baseTime&nx=${grid.x}&ny=${grid.y}'
      );
      debugPrint('API 요청 URL: $url');

      final response = await _httpClient.get(url);
      debugPrint('API 응답 상태: ${response.statusCode}, 내용: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['response']['body']['items']['item'] as List<dynamic>;

        double? temp, humid, wind, precip;

        for (var item in items) {
          if (item is! Map<String, dynamic>) continue;
          switch (item['category']) {
            case 'T1H':
              temp = double.tryParse(item['obsrValue'].toString());
              break;
            case 'REH':
              humid = double.tryParse(item['obsrValue'].toString());
              break;
            case 'WSD':
              wind = double.tryParse(item['obsrValue'].toString());
              break;
            case 'PPTN':
              precip = double.tryParse(item['obsrValue'].toString());
              break;
          }
        }

        return {
          'region': region, // 지역명 추가
          'temp': temp,
          'humid': humid,
          'wind': wind,
          'precip': precip,
        };
      } else {
        debugPrint('기상청 API 오류: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('fetchWeather 오류: $e');
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