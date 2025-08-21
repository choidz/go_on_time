import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_on_time/providers/alarm_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkDataAndNavigate();
  }

  Future<void> _checkDataAndNavigate() async {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    // deviceUid가 할당될 때까지 기다립니다.
    while (alarmProvider.deviceUid == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // --- ✨ 여기가 수정된 부분입니다 ---
    // MyApp을 불러오는 대신, main.dart에 정의된 '/home' 경로로 바로 이동합니다.
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
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