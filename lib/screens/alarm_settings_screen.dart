import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';

class AlarmSettingsScreen extends StatefulWidget {
  final int? index;
  const AlarmSettingsScreen({super.key, this.index});

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  final _nameController = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);
  List<bool> _days = [true, true, true, true, true, false, false];
  String _ringtone = 'Default';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    if (widget.index != null) {
      final alarm = provider.alarms[widget.index!];
      _nameController.text = alarm.name;
      _time = alarm.time;
      _days = alarm.days;
      _ringtone = alarm.ringtone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            ListTile(
              title: Text(_time.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final newTime = await showTimePicker(context: context, initialTime: _time);
                if (newTime != null) setState(() => _time = newTime);
              },
            ),
            ElevatedButton(
              onPressed: () {
                final alarm = Alarm(name: _nameController.text, time: _time, days: _days, ringtone: _ringtone);
                final provider = Provider.of<AlarmProvider>(context, listen: false);
                if (widget.index != null) {
                  provider.updateAlarm(widget.index!, alarm);
                  provider.fetchWeatherAndAdjustAlarm(widget.index!);
                } else {
                  provider.addAlarm(alarm);
                  provider.fetchWeatherAndAdjustAlarm(provider.alarms.length - 1);
                }
                Navigator.pop(context);
              },
              child: const Text('Save & Adjust'),
            ),
          ],
        ),
      ),
    );
  }
}