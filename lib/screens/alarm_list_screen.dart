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
    Provider.of<AlarmProvider>(context, listen: false).fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your alarms')),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: alarmProvider.alarms.length,
                  itemBuilder: (context, index) {
                    return AlarmCard(
                      alarm: alarmProvider.alarms[index],
                      onTap: () {
                        Navigator.pushNamed(context, '/settings', arguments: index);
                      },
                    );
                  },
                ),
              ),
              if (alarmProvider.latestWeather != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: const Text('Current Weather'),
                      subtitle: Text(
                        'Temp: ${alarmProvider.latestWeather!['temp'] ?? 'N/A'}°C, '
                            'Humid: ${alarmProvider.latestWeather!['humid'] ?? 'N/A'}%, '
                            'Wind: ${alarmProvider.latestWeather!['wind'] ?? 'N/A'} m/s',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/settings'),
        child: const Icon(Icons.add),
      ),
    );
  }
}