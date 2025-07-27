import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../services/traffic_service.dart';

class TrafficMapScreen extends StatefulWidget {
  const TrafficMapScreen({super.key});

  @override
  State<TrafficMapScreen> createState() => _TrafficMapScreenState();
}

class _TrafficMapScreenState extends State<TrafficMapScreen> {
  final TrafficService _trafficService = TrafficService();
  late final MapController _mapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadTrafficData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadTrafficData() async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    final district = alarmProvider.latestWeather?['district'] ?? '분당구';
    final trafficData = await _trafficService.fetchTrafficData(district);
    if (trafficData != null) {
      setState(() {
        _currentPosition = LatLng(37.3596, 127.1054); // 분당구 대략적인 좌표
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교통량 지도'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // 서브도메인 제거
            userAgentPackageName: 'com.example.yourapp', // 고유 User-Agent 설정
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ],
          ),
          SimpleAttributionWidget(
            source: const Text('© OpenStreetMap contributors'),
            onTap: null,
            backgroundColor: Colors.black.withOpacity(0.5),
            alignment: Alignment.bottomRight,
          ),
        ],
      ),
    );
  }
}