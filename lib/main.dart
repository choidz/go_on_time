import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_on_time/screens/splash_screen.dart'; // SplashScreen import
import 'firebase_options.dart';
import 'package:workmanager/workmanager.dart';
import 'package:go_on_time/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:go_on_time/providers/alarm_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final weatherService = WeatherService();
    final weather = await weatherService.fetchWeather();
    if (weather != null) {
      debugPrint('Background Weather Update: $weather');
      final alarmProvider = AlarmProvider();
      await alarmProvider.initializeFirebase();
      await alarmProvider.fetchWeather();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: 'assets/.env');
  if (dotenv.env['WEATHER_API_KEY'] == null) {
    debugPrint('Warning: WEATHER_API_KEY is not loaded from .env');
  }

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  final prefs = await SharedPreferences.getInstance();
  bool isWorkScheduled = prefs.getBool('weatherTaskScheduled') ?? false;
  if (!isWorkScheduled) {
    Workmanager().registerPeriodicTask(
      "weatherUpdate",
      "weatherTask",
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 5),
    );
    await prefs.setBool('weatherTaskScheduled', true);
    debugPrint('Weather update task scheduled.');
  } else {
    debugPrint('Weather update task already scheduled.');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
