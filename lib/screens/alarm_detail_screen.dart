import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmDetailScreen extends StatelessWidget {
  final Alarm alarm;
  const AlarmDetailScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(alarm.time.format(context), style: const TextStyle(fontSize: 60)),
            Text(alarm.name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}