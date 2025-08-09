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
    const Color textColor = Color(0xFF0F2039); // 글씨 색상
    const Color buttonColor = Color(0xFF22BD4E); // 버튼 색상

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: buttonColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          elevation: 0,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GoOnTime'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: textColor,
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: buttonColor),
                child: const Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                title: const Text('교통 정보', style: TextStyle(color: textColor)),
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner (상단 알림)
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Encooltorm, Today\'s your', style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text('plan is almost done', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: const [
                          Text('50%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.circle, size: 40, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                // Category 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.only(right: 4.0),
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.wb_sunny, size: 24, color: textColor),
                                const SizedBox(height: 8),
                                const Text('날씨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                Text(
                                  Provider.of<AlarmProvider>(context).latestWeather != null
                                      ? '온도: ${Provider.of<AlarmProvider>(context).latestWeather!['temp'] ?? 'N/A'}°C'
                                      : '데이터 없음',
                                  style: TextStyle(fontSize: 12, color: textColor),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
                                  child: const Text('Go to Plan →'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.only(left: 4.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TrafficMapScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.directions_car, size: 24, color: textColor),
                                const SizedBox(height: 8),
                                const Text('교통량 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                Text(
                                  Provider.of<AlarmProvider>(context).latestTraffic != null
                                      ? '교통량: ${Provider.of<AlarmProvider>(context).latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대'
                                      : '데이터 없음',
                                  style: TextStyle(fontSize: 12, color: textColor),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
                                  child: const Text('Go to Plan →'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Oatogory Plan 섹션
                const Text('Oatogory Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                _buildPlanCard(
                  context,
                  title: 'Streating wabflow design and Kanooneve on mobile',
                  progress: 20,
                  items: [
                    'Create Her FI',
                    'Create Landing Bame Lot ond',
                  ],
                ),
                _buildPlanCard(
                  context,
                  title: 'Creating arablow design reawoneve on mobile',
                  progress: 0,
                  items: [
                    'Oreate Ler Flo',
                    'Oreate Landing Page',
                  ],
                ),
                const SizedBox(height: 16),
                // Alarm 섹션
                const Text('Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
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
                              style: TextStyle(color: textColor),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          backgroundColor: buttonColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Plan 카드 위젯
  Widget _buildPlanCard(BuildContext context, {
    required String title,
    required int progress,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, size: 24, color: Color(0xFF22BD4E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 16, color: Color(0xFF0F2039))),
                ),
                Text('$progress', style: TextStyle(fontSize: 16, color: Color(0xFF0F2039))),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(item, style: TextStyle(fontSize: 14, color: Color(0xFF0F2039))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}