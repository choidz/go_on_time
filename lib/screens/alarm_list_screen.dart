import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';
import 'traffic_screen.dart';
import 'traffic_map_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  @override
  void initState() {
    super.initState();
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    alarmProvider.fetchWeather();
    alarmProvider.fetchTraffic();
  }

  @override
  Widget build(BuildContext context) {
    // 포인트 컬러 (Bluebird #2181A1)
    const Color pointColor = Color(0xFF2181A1);

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: pointColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: pointColor,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2, // 엘리베이션 줄임
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GoOnTime', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: pointColor),
                child: const Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                title: const Text('교통 정보'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrafficScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info 섹션: 2x2 카드 배치
                Padding(
                  padding: const EdgeInsets.all(4.0), // 패딩 줄임
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Info',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2181A1)),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 4, // 간격 줄임
                        mainAxisSpacing: 4, // 간격 줄임
                        childAspectRatio: 1.2, // 카드 비율 조정 (더 작게)
                        padding: const EdgeInsets.all(4.0), // 패딩 줄임
                        children: [
                          // 날씨 카드
                          _buildCard(
                            context,
                            title: '날씨',
                            icon: Icons.wb_sunny,
                            iconColor: Colors.yellow,
                            content: Provider.of<AlarmProvider>(context).latestWeather != null
                                ? '온도: ${Provider.of<AlarmProvider>(context).latestWeather!['temp'] ?? 'N/A'}°C'
                                : '데이터 없음',
                          ),
                          // 도로교통정보 카드
                          _buildCard(
                            context,
                            title: '도로교통정보',
                            icon: Icons.traffic,
                            iconColor: Colors.green,
                            content: Provider.of<AlarmProvider>(context).latestTraffic != null
                                ? '교통량: ${Provider.of<AlarmProvider>(context).latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대'
                                : '데이터 없음',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TrafficMapScreen()),
                              );
                            },
                          ),
                          // 테스트 카드 (플레이스홀더)
                          _buildCard(
                            context,
                            title: '테스트',
                            icon: Icons.assessment,
                            iconColor: pointColor,
                            content: '준비 중',
                          ),
                          // 예약 카드 (플레이스홀더)
                          _buildCard(
                            context,
                            title: '예약',
                            icon: Icons.schedule,
                            iconColor: pointColor,
                            content: '준비 중',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Alarm 섹션: 알람 리스트
                Padding(
                  padding: const EdgeInsets.all(4.0), // 패딩 줄임
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Alarm',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2181A1)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: Provider.of<AlarmProvider>(context).alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = Provider.of<AlarmProvider>(context).alarms[index];
                          return AlarmCard(
                            alarm: alarm,
                            onTap: () {
                              Navigator.pushNamed(context, '/settings', arguments: index);
                            },
                            onAdjust: () async {
                              await Provider.of<AlarmProvider>(context, listen: false).fetchWeatherAndAdjustAlarm(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '알람 조정됨: ${alarm.time.format(context)} → ${Provider.of<AlarmProvider>(context).alarms[index].time.format(context)}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          backgroundColor: pointColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // 카드 위젯 생성 함수
  Widget _buildCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0), // 패딩 줄임
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: iconColor), // 아이콘 크기 줄임
              const SizedBox(height: 4), // 간격 줄임
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // 텍스트 크기 줄임
              const SizedBox(height: 4), // 간격 줄임
              Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)), // 텍스트 크기 줄임
            ],
          ),
        ),
      ),
    );
  }
}