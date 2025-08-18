// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/alarm_provider.dart';
// import '../widgets/alarm_card.dart';
// import 'traffic_screen.dart';
// import 'traffic_map_screen.dart';
//
// class AlarmListScreen extends StatefulWidget {
//   const AlarmListScreen({super.key});
//
//   @override
//   State<AlarmListScreen> createState() => _AlarmListScreenState();
// }
//
// class _AlarmListScreenState extends State<AlarmListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
//     alarmProvider.fetchWeather();
//     alarmProvider.fetchTraffic();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const Color textColor = Color(0xFF0F2039); // 글씨 색상
//     const Color buttonColor = Color(0xFF22BD4E); // 버튼 색상
//
//     return Theme(
//       data: ThemeData(
//         scaffoldBackgroundColor: Colors.white,
//         primaryColor: buttonColor,
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.white,
//           foregroundColor: textColor,
//           elevation: 0,
//           titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
//         ),
//         cardTheme: const CardTheme(
//           color: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
//         ),
//         textTheme: TextTheme(
//           bodyLarge: TextStyle(color: textColor),
//           bodyMedium: TextStyle(color: textColor),
//           titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//         ),
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('GoOnTime'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.settings),
//               color: textColor,
//               onPressed: () => Navigator.pushNamed(context, '/settings'),
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(color: buttonColor),
//                 child: const Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
//               ),
//               ListTile(
//                 title: const Text('교통 정보', style: TextStyle(color: textColor)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const TrafficScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Welcome Banner (상단 알림)
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 16.0),
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text('Encooltorm, Today\'s your', style: TextStyle(color: Colors.white, fontSize: 14)),
//                           Text('plan is almost done', style: TextStyle(color: Colors.white, fontSize: 14)),
//                         ],
//                       ),
//                       Row(
//                         children: const [
//                           Text('50%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                           SizedBox(width: 8),
//                           Icon(Icons.circle, size: 40, color: Colors.white),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Category 섹션
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Card(
//                         margin: const EdgeInsets.only(right: 4.0),
//                         child: InkWell(
//                           onTap: () {},
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Icon(Icons.wb_sunny, size: 24, color: textColor),
//                                 const SizedBox(height: 8),
//                                 const Text('날씨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
//                                 Text(
//                                   Provider.of<AlarmProvider>(context).latestWeather != null
//                                       ? '온도: ${Provider.of<AlarmProvider>(context).latestWeather!['temp'] ?? 'N/A'}°C'
//                                       : '데이터 없음',
//                                   style: TextStyle(fontSize: 12, color: textColor),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 ElevatedButton(
//                                   onPressed: () {},
//                                   style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
//                                   child: const Text('Go to Plan →'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                      Expanded(
//                       child: Card(
//                         margin: const EdgeInsets.only(left: 4.0),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => const TrafficMapScreen()),
//                             );
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Icon(Icons.directions_car, size: 24, color: textColor),
//                                 const SizedBox(height: 8),
//                                 const Text('교통량 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
//                                 Text(
//                                   Provider.of<AlarmProvider>(context).latestTraffic != null
//                                       ? '교통량: ${Provider.of<AlarmProvider>(context).latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대'
//                                       : '데이터 없음',
//                                   style: TextStyle(fontSize: 12, color: textColor),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 ElevatedButton(
//                                   onPressed: () {},
//                                   style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
//                                   child: const Text('Go to Plan →'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Oatogory Plan 섹션
//                 const Text('Oatogory Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
//                 const SizedBox(height: 8),
//                 _buildPlanCard(
//                   context,
//                   title: 'Streating wabflow design and Kanooneve on mobile',
//                   progress: 20,
//                   items: [
//                     'Create Her FI',
//                     'Create Landing Bame Lot ond',
//                   ],
//                 ),
//                 _buildPlanCard(
//                   context,
//                   title: 'Creating arablow design reawoneve on mobile',
//                   progress: 0,
//                   items: [
//                     'Oreate Ler Flo',
//                     'Oreate Landing Page',
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Alarm 섹션
//                 const Text('Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
//                 const SizedBox(height: 8),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: Provider.of<AlarmProvider>(context).alarms.length,
//                   itemBuilder: (context, index) {
//                     final alarm = Provider.of<AlarmProvider>(context).alarms[index];
//                     return AlarmCard(
//                       alarm: alarm,
//                       onTap: () {
//                         Navigator.pushNamed(context, '/settings', arguments: index);
//                       },
//                       onAdjust: () async {
//                         await Provider.of<AlarmProvider>(context, listen: false).fetchWeatherAndAdjustAlarm(index);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               '알람 조정됨: ${alarm.time.format(context)} → ${Provider.of<AlarmProvider>(context).alarms[index].time.format(context)}',
//                               style: TextStyle(color: textColor),
//                             ),
//                             backgroundColor: Colors.white,
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => Navigator.pushNamed(context, '/settings'),
//           backgroundColor: buttonColor,
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   // Plan 카드 위젯
//   Widget _buildPlanCard(BuildContext context, {
//     required String title,
//     required int progress,
//     required List<String> items,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.check_circle, size: 24, color: Color(0xFF22BD4E)),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(title, style: TextStyle(fontSize: 16, color: Color(0xFF0F2039))),
//                 ),
//                 Text('$progress', style: TextStyle(fontSize: 16, color: Color(0xFF0F2039))),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...items.map((item) => Padding(
//               padding: const EdgeInsets.only(left: 32.0, top: 4.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.circle, size: 12, color: Colors.grey),
//                   const SizedBox(width: 8),
//                   Text(item, style: TextStyle(fontSize: 14, color: Color(0xFF0F2039))),
//                 ],
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';
import 'traffic_screen.dart';
import 'traffic_map_screen.dart';
import 'alarm_settings_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  late Future<void> _initialLoad;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _initialLoad = _fetchInitialData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _fetchInitialData() async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    await Future.wait([
      alarmProvider.fetchWeather(),
      alarmProvider.fetchTraffic(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0F2039);
    const Color buttonColor = Color(0xFF22BD4E);

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: buttonColor,
        appBarTheme: const AppBarTheme(
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
        textTheme: const TextTheme(
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
              icon: const Icon(Icons.settings_outlined),
              color: textColor,
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        drawer: _buildDrawer(context, textColor, buttonColor),
        body: SafeArea(
          child: FutureBuilder(
            future: _initialLoad,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: buttonColor));
              } else if (snapshot.hasError) {
                return const Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
              } else {
                return RefreshIndicator(
                  onRefresh: _fetchInitialData,
                  color: buttonColor,
                  child: _buildMainContent(),
                );
              }
            },
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

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [개선] Welcome Banner -> 오늘의 첫 알람 브리핑
          _buildNextAlarmBriefing(),
          const SizedBox(height: 16),
          _buildInfoCards(),
          const SizedBox(height: 24),
          // [개선] Oatogory Plan -> 알람별 상세 정보
          _buildAdjustmentDetails(),
          const SizedBox(height: 16),
          _buildAlarmList(),
        ],
      ),
    );
  }

  // [신규] 오늘의 첫 알람 브리핑 위젯
  Widget _buildNextAlarmBriefing() {
    final provider = Provider.of<AlarmProvider>(context);
    // TODO: 실제 다음 알람을 찾는 로직 추가 필요
    final nextAlarm = provider.alarms.isNotEmpty ? provider.alarms.first : null;
    final trafficStatus = _getTrafficStatus(provider.latestTraffic?['averageTraffic'] as double? ?? 0.0).status;

    String greeting = "좋은 하루 보내세요! ☀️";
    String briefing = "설정된 알람이 없습니다.";

    if (nextAlarm != null) {
      greeting = "좋은 아침입니다! ☀️";
      briefing = "다음 알람은 '${nextAlarm.name}'이며, ${nextAlarm.time.format(context)}에 울립니다.";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(briefing, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          if (nextAlarm != null)
            Text("현재 교통상황은 '$trafficStatus'입니다.", style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  // [신규] 최근 조정된 알람 정보 위젯
  Widget _buildAdjustmentDetails() {
    final provider = Provider.of<AlarmProvider>(context);
    // TODO: 실제 마지막으로 조정된 알람을 찾는 로직 필요
    final adjustedAlarm = provider.alarms.isNotEmpty ? provider.alarms.first : null;

    // ▼▼▼▼▼ 이 부분을 잠시 주석 처리 ▼▼▼▼▼
    // if (adjustedAlarm == null || adjustedAlarm.startPoint == null || adjustedAlarm.startPoint!.isEmpty) {
    //   // 보여줄 정보가 없으면 위젯을 숨깁니다.
    //   return const SizedBox.shrink();
    // }
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    // 알람이 없을 경우를 대비해 임시 데이터를 만들어줍니다.
    final displayAlarm = adjustedAlarm ?? Alarm(name: '출근', time: TimeOfDay.now(), startPoint: '동탄역', endPoint: '강남역');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('최근 조정된 알람', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(Icons.route_outlined, '경로', '${displayAlarm.startPoint} → ${displayAlarm.endPoint}'),
                const Divider(height: 24),
                _buildDetailRow(Icons.history_toggle_off, '조정 시간', '15분 (07:30 → 07:15)'), // 예시 데이터
                const Divider(height: 24),
                _buildDetailRow(Icons.info_outline, '주요 원인', '강설 예보, 출근길 정체'), // 예시 데이터
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(value),
      ],
    );
  }

  // --- 이하 기존 위젯 빌더들 ---

  Drawer _buildDrawer(BuildContext context, Color textColor, Color buttonColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: buttonColor),
            child: const Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.traffic, color: textColor),
            title: Text('교통 정보', style: TextStyle(color: textColor)),
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
    );
  }

  Widget _buildInfoCards() {
    final provider = Provider.of<AlarmProvider>(context);
    final weather = provider.latestWeather;
    final traffic = provider.latestTraffic;

    final trafficInfo = _getTrafficStatus(traffic?['averageTraffic'] as double? ?? 0.0);

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.wb_sunny, size: 24),
                  const SizedBox(height: 8),
                  const Text('날씨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(weather != null ? '${weather['temp'] ?? 'N/A'}°C' : '...', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrafficMapScreen())),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(trafficInfo.icon, size: 24, color: trafficInfo.color),
                    const SizedBox(height: 8),
                    const Text('교통', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(trafficInfo.status, style: TextStyle(fontSize: 14, color: trafficInfo.color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmList() {
    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        if (provider.alarms.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.alarm_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('저장된 알람이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('우측 하단의 + 버튼으로 새 알람을 추가하세요.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('모든 알람', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = provider.alarms[index];
                return AlarmCard(
                  alarm: alarm,
                  onTap: () => Navigator.pushNamed(context, '/settings', arguments: index)
                      .then((_) => setState(() {})),
                  onAdjust: () async {
                    final originalTime = alarm.time.format(context);
                    await provider.fetchWeatherAndAdjustAlarm(index);
                    if (!mounted) return;
                    final adjustedTime = provider.alarms[index].time.format(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('알람 조정됨: $originalTime → $adjustedTime')),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 교통량 상태를 계산하는 헬퍼 함수
  ({Color color, IconData icon, String status}) _getTrafficStatus(double trafficValue) {
    if (trafficValue < 1000) {
      return (color: const Color(0xFF22BD4E), icon: Icons.check_circle_outline, status: '원활');
    } else if (trafficValue < 2000) {
      return (color: Colors.orange, icon: Icons.watch_later_outlined, status: '서행');
    } else {
      return (color: Colors.red, icon: Icons.warning_amber_rounded, status: '정체');
    }
  }
}
