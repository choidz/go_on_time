import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_on_time/firebase_options.dart';
import 'package:workmanager/workmanager.dart';
import 'package:go_on_time/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:go_on_time/providers/alarm_provider.dart';

// --- ✨ 1. 필요한 모든 import 추가 ---
// 화면 이동(라우팅) 및 한국어 설정을 위해 필요한 파일들을 모두 가져옵니다.
import 'package:go_on_time/screens/splash_screen.dart';
import 'package:go_on_time/screens/alarm_list_screen.dart';
import 'package:go_on_time/screens/alarm_settings_screen.dart';
import 'package:go_on_time/screens/traffic_screen.dart';
import 'package:go_on_time/screens/history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 백그라운드 작업 로직은 그대로 유지합니다.
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

  // --- ✨ 2. 한국어 날짜 포맷 초기화 ---
  // 앱이 시작될 때 한국어 날짜/시간 형식을 사용할 수 있도록 설정합니다.
  await initializeDateFormatting('ko_KR', null);

  // Firebase, DotEnv, Workmanager 초기화 로직은 그대로 유지합니다.
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
      // --- ✨ 3. MaterialApp 설정 통합 및 완성 ---
      child: MaterialApp(
        title: 'GoOnTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.white,
        ),
        // 앱의 첫 시작 화면을 '/' 경로로 지정하고, SplashScreen을 보여줍니다.
        initialRoute: '/',
        // 앱 내 모든 화면 이동 경로를 이곳에서 관리합니다.
        routes: {
          '/': (context) => const SplashScreen(), // 시작 화면
          '/home': (context) => const AlarmListScreen(), // 메인 알람 목록 화면
          '/settings': (context) => AlarmSettingsScreen(index: ModalRoute.of(context)?.settings.arguments as int?),
          '/traffic': (context) => const TrafficScreen(),
          '/history': (context) => const HistoryScreen(),
        },
        // --- ✨ 4. 한국어 로케일 설정 추가 ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
      ),
    ),
  );
}
