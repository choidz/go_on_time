// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
//
// class TrafficService {
//   String get _apiKey {
//     final key = dotenv.env['TRAFFIC_API_KEY'];
//     if (key == null || key.isEmpty) {
//       debugPrint('경고: TRAFFIC_API_KEY가 없거나 비어 있음');
//       return '';
//     }
//     return key;
//   }
//
//   String get _baseUrl {
//     final url = dotenv.env['TRAFFIC_BASE_URL'];
//     if (url == null || url.isEmpty) {
//       debugPrint('경고: TRAFFIC_BASE_URL이 없거나 비어 있음');
//       return '';
//     }
//     return url;
//   }
//
//   Future<Map<String, dynamic>?> fetchTrafficData(String? district) async {
//     try {
//       // district가 없으면 화성시로 기본 설정
//       final targetDistrict = district ?? 'Hwaseong-si';
//       final url = Uri.parse('$_baseUrl?key=$_apiKey&type=json&district=$targetDistrict');
//       debugPrint('교통 API 요청 URL: $url');
//
//       final response = await http.get(url);
//       debugPrint('교통 API 응답 상태: ${response.statusCode}, 내용: ${response.body.length > 1000 ? response.body.substring(0, 1000) + '...' : response.body}');
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         if (data['code'] == 'SUCCESS') {
//           final trafficAll = data['trafficAll'] as List<dynamic>? ?? [];
//           double totalTraffic = 0;
//           int count = 0;
//           for (var item in trafficAll) {
//             if (item is Map<String, dynamic>) {
//               final trafficAmount = int.tryParse(item['trafficAmout']?.toString() ?? '0');
//               totalTraffic += trafficAmount ?? 0;
//               count++;
//             }
//           }
//           final avgTraffic = count > 0 ? totalTraffic / count : 0;
//
//           return {
//             'district': targetDistrict,
//             'averageTraffic': avgTraffic,
//             'trafficData': trafficAll,
//           };
//         } else {
//           debugPrint('교통 API 오류: ${data['message']}');
//           return null;
//         }
//       } else {
//         debugPrint('교통 API 요청 실패: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('fetchTrafficData 오류: $e');
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TrafficService {
  // TMAP API 키를 가져오는 getter
  String? get _tmapApiKey {
    final key = dotenv.env['TMAP_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('경고: .env 파일에 TMAP_API_KEY가 설정되지 않았습니다.');
      return null;
    }
    return key;
  }

  // [신규] 장소 이름으로 위도, 경도 좌표를 가져오는 함수
  Future<Map<String, String>?> _getCoordinates(String placeName) async {
    final apiKey = _tmapApiKey;
    if (apiKey == null) return null;

    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=${Uri.encodeComponent(placeName)}&count=1');

    try {
      final response = await http.get(
        url,
        headers: {'appKey': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['searchPoiInfo']['pois']['poi'].isNotEmpty) {
          final poi = data['searchPoiInfo']['pois']['poi'][0];
          return {'lat': poi['noorLat'], 'lon': poi['noorLon']};
        }
      }
      debugPrint('좌표를 찾을 수 없습니다: $placeName');
      return null;
    } catch (e) {
      debugPrint('_getCoordinates 오류: $e');
      return null;
    }
  }

  // [신규] 출발지, 도착지 기반으로 예상 소요 시간(초)을 가져오는 함수
  Future<int?> getTravelTime(String startPoint, String endPoint) async {
    final apiKey = _tmapApiKey;
    if (apiKey == null) return null;

    final startCoords = await _getCoordinates(startPoint);
    final endCoords = await _getCoordinates(endPoint);

    if (startCoords == null || endCoords == null) {
      debugPrint('출발지 또는 도착지의 좌표를 찾지 못했습니다.');
      return null;
    }

    final url = Uri.parse('https://apis.openapi.sk.com/tmap/routes?version=1&callback=function');

    try {
      final response = await http.post(
        url,
        headers: {
          'appKey': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'startX': startCoords['lon'],
          'startY': startCoords['lat'],
          'endX': endCoords['lon'],
          'endY': endCoords['lat'],
          'reqCoordType': 'WGS84GEO',
          'resCoordType': 'WGS84GEO',
          'searchOption': '0', // 0: 추천경로
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          final totalTimeInSeconds = data['features'][0]['properties']['totalTime'];
          debugPrint('예상 소요 시간 ($startPoint -> $endPoint): $totalTimeInSeconds 초');
          return totalTimeInSeconds;
        }
      }
      return null;
    } catch (e) {
      debugPrint('getTravelTime 오류: $e');
      return null;
    }
  }

  // --- 기존 지역 기반 교통량 조회 기능 (참고용으로 남겨둠) ---
  String get _trafficApiKey {
    final key = dotenv.env['TRAFFIC_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('경고: TRAFFIC_API_KEY가 없거나 비어 있음');
      return '';
    }
    return key;
  }

  String get _baseUrl {
    final url = dotenv.env['TRAFFIC_BASE_URL'];
    if (url == null || url.isEmpty) {
      debugPrint('경고: TRAFFIC_BASE_URL이 없거나 비어 있음');
      return '';
    }
    return url;
  }

  Future<Map<String, dynamic>?> fetchTrafficData(String? district) async {
    try {
      final targetDistrict = district ?? 'Hwaseong-si';
      final url = Uri.parse('$_baseUrl?key=$_trafficApiKey&type=json&district=$targetDistrict');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'SUCCESS') {
          final trafficAll = data['trafficAll'] as List<dynamic>? ?? [];
          double totalTraffic = 0;
          int count = 0;
          for (var item in trafficAll) {
            if (item is Map<String, dynamic>) {
              final trafficAmount = int.tryParse(item['trafficAmout']?.toString() ?? '0');
              totalTraffic += trafficAmount ?? 0;
              count++;
            }
          }
          final avgTraffic = count > 0 ? totalTraffic / count : 0;

          return {
            'district': targetDistrict,
            'averageTraffic': avgTraffic,
            'trafficData': trafficAll,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('fetchTrafficData 오류: $e');
      return null;
    }
  }
}
