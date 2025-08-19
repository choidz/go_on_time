import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/alarm_provider.dart';
import 'screens/alarm_list_screen.dart';
import 'screens/alarm_settings_screen.dart';
import 'screens/traffic_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: MaterialApp(
        title: 'GoOnTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.white,
          // scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AlarmListScreen(),
          '/settings': (context) => AlarmSettingsScreen(index: ModalRoute.of(context)?.settings.arguments as int?),
          '/traffic': (context) => const TrafficScreen(), // 추가
        },
      ),
    );
  }
}