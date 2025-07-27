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
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('메뉴'),
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
      // body: SafeArea(
      //   child: SingleChildScrollView(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.stretch,
      //       children: [
      //         // 날씨/교통 정보 Card (최상단)
      //         if (Provider.of<AlarmProvider>(context).latestWeather != null ||
      //             Provider.of<AlarmProvider>(context).latestTraffic != null)
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Card(
      //               color: Colors.white,
      //               elevation: 4,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(12),
      //               ),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   const ListTile(
      //                     title: Text('현재 상황', style: TextStyle(fontWeight: FontWeight.bold)),
      //                     tileColor: Colors.transparent,
      //                   ),
      //                   if (Provider.of<AlarmProvider>(context).latestWeather != null)
      //                     ListTile(
      //                       leading: const Icon(Icons.wb_sunny, color: Colors.yellow),
      //                       title: const Text('날씨'),
      //                       subtitle: Text(
      //                         '지역: ${Provider.of<AlarmProvider>(context).latestWeather!['region'] ?? '알 수 없음'} '
      //                             '${Provider.of<AlarmProvider>(context).latestWeather!['city'] ?? ''} '
      //                             '${Provider.of<AlarmProvider>(context).latestWeather!['district'] ?? ''}\n'
      //                             '온도: ${Provider.of<AlarmProvider>(context).latestWeather!['temp'] ?? 'N/A'}°C\n'
      //                             '습도: ${Provider.of<AlarmProvider>(context).latestWeather!['humid'] ?? 'N/A'}%\n'
      //                             '바람: ${Provider.of<AlarmProvider>(context).latestWeather!['wind'] ?? 'N/A'} m/s\n'
      //                             '강수량: ${Provider.of<AlarmProvider>(context).latestWeather!['precip'] ?? 'N/A'} mm',
      //                         style: const TextStyle(fontSize: 14),
      //                       ),
      //                     ),
      //                   if (Provider.of<AlarmProvider>(context).latestTraffic != null)
      //                     ListTile(
      //                       leading: const Icon(Icons.traffic, color: Colors.green),
      //                       title: const Text('교통'),
      //                       subtitle: Text(
      //                         '지역: ${Provider.of<AlarmProvider>(context).latestTraffic!['district'] ?? '알 수 없음'}\n'
      //                             '평균 교통량: ${Provider.of<AlarmProvider>(context).latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대',
      //                         style: const TextStyle(fontSize: 14),
      //                       ),
      //                     ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         // 알람 리스트 (날씨/교통 아래)
      //         ListView.builder(
      //           shrinkWrap: true,
      //           physics: const NeverScrollableScrollPhysics(),
      //           itemCount: Provider.of<AlarmProvider>(context).alarms.length,
      //           itemBuilder: (context, index) {
      //             final alarm = Provider.of<AlarmProvider>(context).alarms[index];
      //             return AlarmCard(
      //               alarm: alarm,
      //               onTap: () {
      //                 Navigator.pushNamed(context, '/settings', arguments: index);
      //               },
      //               onAdjust: () async {
      //                 await Provider.of<AlarmProvider>(context, listen: false).fetchWeatherAndAdjustAlarm(index);
      //                 ScaffoldMessenger.of(context).showSnackBar(
      //                   SnackBar(
      //                     content: Text(
      //                       '알람 조정됨: ${alarm.time.format(context)} → ${Provider.of<AlarmProvider>(context).alarms[index].time.format(context)}',
      //                     ),
      //                   ),
      //                 );
      //               },
      //             );
      //           },
      //         ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 알람 리스트
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
              // 날씨 정보 Card
              if (Provider.of<AlarmProvider>(context).latestWeather != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(
                          title: Text('날씨', style: TextStyle(fontWeight: FontWeight.bold)),
                          tileColor: Colors.transparent,
                        ),
                        ListTile(
                          leading: const Icon(Icons.wb_sunny, color: Colors.yellow),
                          subtitle: Text(
                            '지역: ${Provider.of<AlarmProvider>(context).latestWeather!['region'] ?? '알 수 없음'} '
                                '${Provider.of<AlarmProvider>(context).latestWeather!['city'] ?? ''} '
                                '${Provider.of<AlarmProvider>(context).latestWeather!['district'] ?? ''}\n'
                                '온도: ${Provider.of<AlarmProvider>(context).latestWeather!['temp'] ?? 'N/A'}°C\n'
                                '습도: ${Provider.of<AlarmProvider>(context).latestWeather!['humid'] ?? 'N/A'}%\n'
                                '바람: ${Provider.of<AlarmProvider>(context).latestWeather!['wind'] ?? 'N/A'} m/s\n'
                                '강수량: ${Provider.of<AlarmProvider>(context).latestWeather!['precip'] ?? 'N/A'} mm',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
// 교통 정보 Card
              if (Provider.of<AlarmProvider>(context).latestTraffic != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TrafficMapScreen()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ListTile(
                            title: Text('교통', style: TextStyle(fontWeight: FontWeight.bold)),
                            tileColor: Colors.transparent,
                          ),
                          ListTile(
                            leading: const Icon(Icons.traffic, color: Colors.green),
                            subtitle: Text(
                              '지역: ${Provider.of<AlarmProvider>(context).latestWeather!['region'] ?? '알 수 없음'} '
                                  '${Provider.of<AlarmProvider>(context).latestWeather!['city'] ?? ''} '
                                  '${Provider.of<AlarmProvider>(context).latestWeather!['district'] ?? ''}\n'
                                  '평균 교통량: ${Provider.of<AlarmProvider>(context).latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // 나머지 Card (테스트용 주석 처리)
              /*
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('추가 정보 1', style: TextStyle(fontWeight: FontWeight.bold)),
                        tileColor: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.info, color: Colors.purple),
                        title: Text('상태'),
                        subtitle: Text(
                          '상태: 정상\n'
                              '값: 100\n'
                              '시간: 12:00',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('추가 정보 2', style: TextStyle(fontWeight: FontWeight.bold)),
                        tileColor: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.settings, color: Colors.orange),
                        title: Text('설정'),
                        subtitle: Text(
                          '모드: 자동\n'
                              '레벨: 중간\n'
                              '업데이트: 2025-07-27',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('추가 정보 3', style: TextStyle(fontWeight: FontWeight.bold)),
                        tileColor: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.battery_full, color: Colors.blue),
                        title: Text('배터리'),
                        subtitle: Text(
                          '수명: 85%\n'
                              '상태: 충전 중\n'
                              '시간: 2시간',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('추가 정보 4', style: TextStyle(fontWeight: FontWeight.bold)),
                        tileColor: Colors.transparent,
                      ),
                      ListTile(
                        leading: Icon(Icons.wifi, color: Colors.teal),
                        title: Text('네트워크'),
                        subtitle: Text(
                          '신호: 강함\n'
                              '속도: 50Mbps\n'
                              '연결: Wi-Fi',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/settings'),
        child: const Icon(Icons.add),
      ),
    );
  }
}