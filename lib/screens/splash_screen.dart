import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_on_time/providers/alarm_provider.dart';
import 'package:go_on_time/app.dart'; // MyApp이 있는 파일

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 직후 데이터 로딩을 시작합니다.
    _checkDataAndNavigate();
  }

  Future<void> _checkDataAndNavigate() async {
    // Provider를 통해 AlarmProvider 인스턴스에 접근합니다.
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    // deviceUid가 할당될 때까지 잠시 기다립니다.
    // AlarmProvider 생성자에서 비동기 작업이 시작되므로,
    // 완료될 때까지 주기적으로 확인하는 방식이 안정적입니다.
    while (alarmProvider.deviceUid == null) {
      // 0.1초 간격으로 확인
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 로딩이 완료되었으므로 MyApp으로 화면을 전환합니다.
    // Provider는 이미 main.dart에서 MyApp의 상위를 감싸고 있으므로
    // 여기서는 화면 전환만 하면 됩니다.
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyApp(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 로딩 중 보여줄 화면 UI
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Go On Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('데이터를 동기화하는 중입니다...'),
          ],
        ),
      ),
    );
  }
}
