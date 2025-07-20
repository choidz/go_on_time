import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TrafficService {
  String get _apiKey {
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

  Future<Map<String, dynamic>?> fetchTrafficData() async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey&type=json');
      debugPrint('교통 API 요청 URL: $url');

      final response = await http.get(url);
      debugPrint('교통 API 응답 상태: ${response.statusCode}, 내용: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'SUCCESS') {
          final trafficAll = data['trafficAll'] as List<dynamic>? ?? [];
          double totalTraffic = 0;
          int count = trafficAll.length;
          for (var item in trafficAll) {
            if (item is Map<String, dynamic>) {
              final trafficAmount = int.tryParse(item['trafficAmout']?.toString() ?? '0');
              totalTraffic += trafficAmount ?? 0;
            }
          }
          final avgTraffic = count > 0 ? totalTraffic / count : 0;

          return {
            'averageTraffic': avgTraffic,
            'trafficData': trafficAll,
          };
        } else {
          debugPrint('교통 API 오류: ${data['message']}');
          return null;
        }
      } else {
        debugPrint('교통 API 요청 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('fetchTrafficData 오류: $e');
      return null;
    }
  }
}