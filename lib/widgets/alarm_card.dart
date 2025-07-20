import 'package:flutter/material.dart';

import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final VoidCallback? onAdjust;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      child: ListTile(
        title: Text(alarm.name),
        subtitle: Text(alarm.time.format(context)),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onAdjust != null)
              IconButton(
                icon: const Icon(Icons.adjust),
                onPressed: onAdjust,
              ),
            const Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}