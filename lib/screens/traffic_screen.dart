import 'package:flutter/material.dart';

class TrafficScreen extends StatelessWidget {
  const TrafficScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교통 정보'),
      ),
      body: const Center(
        child: Text('교통 정보 화면 (임시)'),
      ),
    );
  }
}