import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final VoidCallback onAdjust;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    // 메인 화면의 테마를 가져와서 일관성을 유지합니다.
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color!;

    // 활성화된 요일을 표시하기 위한 로직
    const dayChars = ['월', '화', '수', '목', '금', '토', '일'];
    String daysString = '';
    for (int i = 0; i < alarm.days.length; i++) {
      if (alarm.days[i]) {
        daysString += '${dayChars[i]} ';
      }
    }
    if (daysString.isEmpty) {
      daysString = '반복 없음';
    }

    // 출발지 -> 도착지 경로 표시
    final routeString = (alarm.startPoint?.isNotEmpty == true && alarm.endPoint?.isNotEmpty == true)
        ? '\n${alarm.startPoint} → ${alarm.endPoint}'
        : '';

    return Card(
      // Card 자체의 속성은 AlarmListScreen의 CardTheme을 따릅니다.
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          alarm.name,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          '${alarm.time.format(context)} | ${daysString.trim()}$routeString',
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: textColor.withOpacity(0.8)),
              onPressed: onTap,
              tooltip: '수정',
            ),
            IconButton(
              icon: Icon(Icons.auto_awesome, color: theme.primaryColor),
              onPressed: onAdjust,
              tooltip: '즉시 조정',
            ),
          ],
        ),
        onTap: onTap, // ListTile 전체를 탭해도 수정 화면으로 이동
      ),
    );
  }
}
