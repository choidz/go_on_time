import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
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
    // listen: false로 설정하여 build 메서드 밖에서 안전하게 호출합니다.
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    // 데이터 로딩이 완료될 때까지 기다립니다.
    await alarmProvider.initializeFirebase();
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
                return Center(child: Text('데이터를 불러오는 데 실패했습니다: ${snapshot.error}'));
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
          _buildAdjustmentDetails(), // ✨ 여기가 수정된 위젯입니다.
          const SizedBox(height: 16),
          _buildAlarmList(),
        ],
      ),
    );
  }

  // --- ✨ 1. '최근 조정 내역' 위젯 수정 ---
  // 임시 데이터를 사용하던 로직을 삭제하고, Provider의 실제 데이터를 사용하도록 변경합니다.
  Widget _buildAdjustmentDetails() {
    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        // 조정된 적이 있는 알람들만 필터링합니다.
        final adjustedAlarms = provider.alarms
            .where((alarm) => alarm.lastAdjustedTime != null)
            .toList();

        // 조정된 알람이 없으면 위젯을 아예 표시하지 않습니다.
        if (adjustedAlarms.isEmpty) {
          return const SizedBox.shrink();
        }

        // 가장 최근에 조정된 알람을 찾기 위해 시간순으로 정렬합니다.
        adjustedAlarms.sort((a, b) => b.lastAdjustedTime!.compareTo(a.lastAdjustedTime!));
        final mostRecent = adjustedAlarms.first;

        // UI에 표시할 텍스트를 준비합니다. null일 경우를 대비해 기본값을 설정합니다.
        final route = '${mostRecent.startPoint ?? "출발지 미설정"} → ${mostRecent.endPoint ?? "도착지 미설정"}';
        final originalTime = mostRecent.originalTime?.format(context) ?? '이전 시간';
        final adjustedTime = mostRecent.time.format(context);
        final adjustmentText = '$originalTime → $adjustedTime';
        final reason = mostRecent.adjustmentReason ?? '원인 정보 없음';

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
                    _buildDetailRow(Icons.route_outlined, '경로', route),
                    const Divider(height: 24),
                    _buildDetailRow(Icons.history_toggle_off, '조정 시간', adjustmentText),
                    const Divider(height: 24),
                    _buildDetailRow(Icons.info_outline, '주요 원인', reason),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  // --- 이하 위젯들은 큰 변경 사항이 없습니다 ---

  Widget _buildNextAlarmBriefing() {
    // Consumer로 감싸서 Provider 데이터 변경 시 자동으로 UI가 업데이트되도록 합니다.
    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        // TODO: '다음 알람'을 찾는 정확한 로직 구현 필요 (현재는 첫 번째 알람 표시)
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
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Flexible(child: Text(value, textAlign: TextAlign.end,)),
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
                return Dismissible(
                  key: Key(alarm.documentId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    provider.deleteAlarm(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'${alarm.name}' 알람이 삭제되었습니다.")),
                    );
                  },
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
                    onTap: () => Navigator.pushNamed(context, '/settings', arguments: index),
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
