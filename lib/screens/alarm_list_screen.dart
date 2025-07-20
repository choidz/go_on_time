import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';

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
    alarmProvider.fetchWeather(); // 날씨 데이터 로드
    alarmProvider.fetchTraffic(); // 교통 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('goOnTime')),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: alarmProvider.alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = alarmProvider.alarms[index];
                    return AlarmCard(
                      alarm: alarm,
                      onTap: () {
                        Navigator.pushNamed(context, '/설정', arguments: index);
                      },
                      onAdjust: () async {
                        await alarmProvider.fetchWeatherAndAdjustAlarm(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '알람 조정됨: ${alarm.time.format(context)} → ${alarmProvider.alarms[index].time.format(context)}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (alarmProvider.latestWeather != null || alarmProvider.latestTraffic != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(
                          title: Text('현재 상황'),
                          tileColor: Colors.transparent,
                        ),
                        if (alarmProvider.latestWeather != null)
                          ListTile(
                            title: const Text('날씨'),
                            subtitle: Text(
                              '지역: ${alarmProvider.latestWeather!['region'] ?? '알 수 없음'}, '
                                  '온도: ${alarmProvider.latestWeather!['temp'] ?? 'N/A'}°C, '
                                  '습도: ${alarmProvider.latestWeather!['humid'] ?? 'N/A'}%, '
                                  '바람: ${alarmProvider.latestWeather!['wind'] ?? 'N/A'} m/s, '
                                  '강수량: ${alarmProvider.latestWeather!['precip'] ?? 'N/A'} mm',
                            ),
                          ),
                        if (alarmProvider.latestTraffic != null)
                          ListTile(
                            title: const Text('교통'),
                            subtitle: Text(
                              '평균 교통량: ${alarmProvider.latestTraffic!['averageTraffic']?.toStringAsFixed(2) ?? 'N/A'} 대',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/설정'),
        child: const Icon(Icons.add),
      ),
    );
  }
}