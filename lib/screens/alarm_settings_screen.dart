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
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();

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
      _startPointController.text = alarm.startPoint ?? '';
      _endPointController.text = alarm.endPoint ?? '';
      _time = alarm.time;
      _days = alarm.days;
      _ringtone = alarm.ringtone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }

  void _saveAndAdjustAlarm() {
    final alarm = Alarm(
      name: _nameController.text.isNotEmpty ? _nameController.text : '새 알람',
      time: _time,
      days: _days,
      ringtone: _ringtone,
      startPoint: _startPointController.text,
      endPoint: _endPointController.text,
    );

    final provider = Provider.of<AlarmProvider>(context, listen: false);

    if (widget.index != null) {
      provider.updateAlarm(widget.index!, alarm);
      provider.fetchWeatherAndAdjustAlarm(widget.index!);
    } else {
      provider.addAlarm(alarm);
      provider.fetchWeatherAndAdjustAlarm(provider.alarms.length - 1);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // AlarmListScreen의 색상 테마를 그대로 가져옵니다.
    const Color textColor = Color(0xFF0F2039);
    const Color buttonColor = Color(0xFF22BD4E);
    const Color hintColor = Colors.grey;

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: buttonColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          elevation: 0,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hintColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: buttonColor, width: 2),
          ),
          labelStyle: const TextStyle(color: textColor),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: textColor,
          dayPeriodTextColor: textColor,
          dialHandColor: buttonColor,
          dialBackgroundColor: Colors.grey[200],
          entryModeIconColor: buttonColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.index == null ? '새 알람' : '알람 수정'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAndAdjustAlarm,
              tooltip: '저장 및 조정',
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '알람 이름',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _startPointController,
                decoration: const InputDecoration(
                  labelText: '출발지 (예: 동탄역)',
                  prefixIcon: Icon(Icons.trip_origin),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endPointController,
                decoration: const InputDecoration(
                  labelText: '도착지 (예: 강남역)',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: textColor),
                title: const Text('알람 시간', style: TextStyle(color: textColor)),
                subtitle: Text(_time.format(context), style: const TextStyle(fontSize: 16)),
                onTap: () async {
                  final newTime = await showTimePicker(context: context, initialTime: _time);
                  if (newTime != null) setState(() => _time = newTime);
                },
              ),
              // ... (요일 선택 UI 등을 여기에 추가할 수 있습니다) ...
            ],
          ),
        ),
      ),
    );
  }
}
