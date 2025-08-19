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
          _buildNextAlarmBriefing(),
          const SizedBox(height: 16),
          _buildInfoCards(),
          const SizedBox(height: 24),
          _buildAdjustmentDetails(),
          const SizedBox(height: 16),
          _buildAlarmList(),
        ],
      ),
    );
  }

  Widget _buildNextAlarmBriefing() {
    final provider = Provider.of<AlarmProvider>(context);
    final nextAlarm = provider.alarms.isNotEmpty ? provider.alarms.first : null;
    final trafficStatus = _getTrafficStatus(provider.latestTraffic?['averageTraffic'] as double? ?? 0.0).status;

    String greeting;
    String briefing;

    if (nextAlarm != null) {
      greeting = "좋은 아침입니다! ☀️";
      briefing = "다음 알람은 '${nextAlarm.name}'이며, ${nextAlarm.time.format(context)}에 울립니다.";
    } else {
      greeting = "좋은 하루 보내세요! 👍";
      briefing = "오늘 예정된 알람이 없습니다.";
    }

    return Container(
      width: double.infinity,
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

  // Widget _buildAdjustmentDetails() {
  //   final provider = Provider.of<AlarmProvider>(context);
  //   // TODO: 실제 마지막으로 조정된 알람을 찾는 로직 필요
  //   final adjustedAlarm = provider.alarms.isNotEmpty ? provider.alarms.first : null;
  //
  //   // ===============================================================
  //   // ▼▼▼▼▼ [실제 로직] 나중에 이 주석을 해제하면 원래대로 동작합니다 ▼▼▼▼▼
  //   // ===============================================================
  //   /*
  //   if (adjustedAlarm == null || adjustedAlarm.startPoint == null || adjustedAlarm.startPoint!.isEmpty) {
  //     // 보여줄 정보가 없으면 위젯을 숨깁니다.
  //     return const SizedBox.shrink();
  //   }
  //   */
  //   // ===============================================================
  //
  //   // ===============================================================
  //   // ▼▼▼▼▼ [임시 로직] UI 확인을 위해 항상 보이도록 처리합니다 ▼▼▼▼▼
  //   // ===============================================================
  //   // 알람이 없을 경우를 대비해 임시 데이터를 만들어줍니다.
  //   final displayAlarm = adjustedAlarm ?? Alarm(name: '출근', time: TimeOfDay.now(), startPoint: '동탄역', endPoint: '강남역');
  //   // ===============================================================
  //
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('최근 조정된 알람', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
  //       const SizedBox(height: 8),
  //       Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             children: [
  //               _buildDetailRow(Icons.route_outlined, '경로', '${displayAlarm.startPoint} → ${displayAlarm.endPoint}'),
  //               const Divider(height: 24),
  //               _buildDetailRow(Icons.history_toggle_off, '조정 시간', '15분 (07:30 → 07:15)'), // 예시 데이터
  //               const Divider(height: 24),
  //               _buildDetailRow(Icons.info_outline, '주요 원인', '강설 예보, 출근길 정체'), // 예시 데이터
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  // [수정] TMAP API 결과를 동적으로 표시하고, 임시로 항상 보이도록 수정한 위젯
  Widget _buildAdjustmentDetails() {
    final provider = Provider.of<AlarmProvider>(context);
    final details = provider.lastAdjustmentDetails;

    // ===============================================================
    // ▼▼▼▼▼ [실제 로직] 나중에 이 주석을 해제하면 원래대로 동작합니다 ▼▼▼▼▼
    // ===============================================================
    /*
    if (details == null) {
      // 조정 내역이 없으면 위젯을 숨깁니다.
      return const SizedBox.shrink();
    }
    */
    // ===============================================================


    // ===============================================================
    // ▼▼▼▼▼ [임시 로직] UI 확인을 위해 항상 보이도록 처리합니다 ▼▼▼▼▼
    // ===============================================================
    // 조정 내역이 없을 경우를 대비해 임시 데이터를 만들어줍니다.
    final displayDetails = details ?? {
      'startPoint': '동탄역',
      'endPoint': '강남역',
      'originalTime': const TimeOfDay(hour: 7, minute: 30),
      'adjustedTime': const TimeOfDay(hour: 7, minute: 15),
      'reason': '강설 예보, 출근길 정체',
    };
    // ===============================================================


    // TimeOfDay를 포맷팅합니다.
    final originalTime = (displayDetails['originalTime'] as TimeOfDay).format(context);
    final adjustedTime = (displayDetails['adjustedTime'] as TimeOfDay).format(context);
    final adjustmentText = '$originalTime → $adjustedTime';

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
                _buildDetailRow(Icons.route_outlined, '경로', '${displayDetails['startPoint']} → ${displayDetails['endPoint']}'),
                const Divider(height: 24),
                _buildDetailRow(Icons.history_toggle_off, '조정 시간', adjustmentText),
                const Divider(height: 24),
                _buildDetailRow(Icons.info_outline, '주요 원인', displayDetails['reason'].toString()),
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
                // [신규] Dismissible 위젯으로 AlarmCard를 감싸 스와이프 기능을 추가합니다.
                return Dismissible(
                  key: Key(alarm.documentId), // 각 항목을 식별할 고유 키
                  direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프
                  onDismissed: (direction) {
                    // 스와이프가 완료되면 알람을 삭제합니다.
                    provider.deleteAlarm(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'${alarm.name}' 알람이 삭제되었습니다.")),
                    );
                  },
                  // [신규] 삭제 전에 사용자에게 확인을 받습니다.
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("삭제 확인"),
                          content: const Text("이 알람을 정말로 삭제하시겠습니까?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("취소"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("삭제", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  // [신규] 스와이프할 때 배경에 보이는 UI
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: AlarmCard(
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
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

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
