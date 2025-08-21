import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 날짜와 시간을 한국어 형식에 맞게 표시하기 위해 intl 패키지를 사용합니다.
// pubspec.yaml 파일에 `intl: ^0.18.1` (또는 최신 버전)을 추가해주세요.
import 'package:intl/intl.dart';
import '../providers/alarm_provider.dart';
import '../models/adjustment_history.dart';

// --- ✨ 1. StatefulWidget으로 변경 ---
// RefreshIndicator와 같은 상태 변화를 다루기 위해 StatefulWidget으로 전환합니다.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- ✨ 2. 새로고침 로직 추가 ---
  // 화면을 당겨서 새로고침할 때 호출될 함수입니다.
  Future<void> _refreshHistory() async {
    // listen: false로 설정하여 build 메서드 외부에서 Provider의 메서드를 안전하게 호출합니다.
    // AlarmProvider에 히스토리만 새로고침하는 public 메서드가 있다면 그것을 호출하는 것이 더 효율적입니다.
    // 예: await Provider.of<AlarmProvider>(context, listen: false).loadHistory();
    // 여기서는 전체 데이터를 다시 로드하는 것으로 가정합니다.
    await Provider.of<AlarmProvider>(context, listen: false).initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알람 조정 기록'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F2039),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      body: Consumer<AlarmProvider>(
        builder: (context, provider, child) {
          // --- ✨ 3. RefreshIndicator 적용 ---
          // 이제 리스트를 아래로 당겨서 새로고침할 수 있습니다.
          return RefreshIndicator(
            onRefresh: _refreshHistory,
            color: const Color(0xFF22BD4E), // 앱의 메인 색상과 통일
            child: provider.history.isEmpty
                ? _buildEmptyState() // 히스토리가 비었을 때 표시할 위젯
                : _buildHistoryList(provider.history), // 히스토리 리스트
          );
        },
      ),
    );
  }

  // 코드를 구조화하기 위해 비어있을 때와 리스트가 있을 때의 UI를 별도 위젯으로 분리합니다.
  Widget _buildEmptyState() {
    // 스크롤이 가능한 영역에 있어야 RefreshIndicator가 동작하므로 ListView로 감쌉니다.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '아직 조정된 알람 기록이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(List<AdjustmentHistory> history) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final historyEntry = history[index];
        return HistoryCard(history: historyEntry);
      },
    );
  }
}

// 각 히스토리 항목을 표시하는 카드 위젯 (변경 없음)
class HistoryCard extends StatelessWidget {
  final AdjustmentHistory history;

  const HistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final dateTime = history.timestamp.toDate();
    final formattedDate = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(dateTime);
    final formattedTime = DateFormat('a h:mm', 'ko_KR').format(dateTime);

    final originalTime = history.originalTime.format(context);
    final adjustedTime = history.adjustedTime.format(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "'${history.alarmName}' 알람 조정됨",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.history_toggle_off,
              title: '조정 시간',
              value: '$originalTime → $adjustedTime',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.info_outline,
              title: '조정 사유',
              value: history.reason,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}
