import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../screens/alarm_detail_screen.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  const AlarmCard({super.key, required this.alarm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      child: ListTile(
        title: Text(alarm.name),
        subtitle: Text(alarm.time.format(context)),
        trailing: const Icon(Icons.alarm, color: Colors.red),
        onTap: onTap,
      ),
    );
  }
}