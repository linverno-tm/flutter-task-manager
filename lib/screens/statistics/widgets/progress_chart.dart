import 'package:flutter/cupertino.dart';
import '../../../models/task_model.dart';

class ProgressChart extends StatelessWidget {
  final List<Task> tasks;
  final int period; // 0: Today, 1: Week, 2: Month

  const ProgressChart({super.key, required this.tasks, required this.period});

  Map<String, int> _getChartData() {
    final now = DateTime.now();
    Map<String, int> data = {};

    if (period == 0) {
      // Bugun - soatlar bo'yicha
      for (int i = 0; i < 24; i += 4) {
        data['$i:00'] = 0;
      }
      for (var task in tasks) {
        if (task.isCompleted) {
          final hour = (task.createdAt.hour ~/ 4) * 4;
          final key = '$hour:00';
          data[key] = (data[key] ?? 0) + 1;
        }
      }
    } else if (period == 1) {
      // Hafta - kunlar bo'yicha
      final days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
      for (var day in days) {
        data[day] = 0;
      }
      for (var task in tasks) {
        if (task.isCompleted) {
          final dayIndex = task.createdAt.weekday % 7;
          data[days[dayIndex]] = (data[days[dayIndex]] ?? 0) + 1;
        }
      }
    } else {
      // Oy - haftalar bo'yicha
      for (int i = 1; i <= 4; i++) {
        data['$i-hafta'] = 0;
      }
      for (var task in tasks) {
        if (task.isCompleted) {
          final week = ((task.createdAt.day - 1) ~/ 7) + 1;
          final key = '$week-hafta';
          data[key] = (data[key] ?? 0) + 1;
        }
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final maxValue = chartData.values.isEmpty
        ? 1
        : chartData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bajarilgan vazifalar',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildBar(
                      label: entry.key,
                      value: entry.value,
                      maxValue: maxValue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required int value,
    required int maxValue,
  }) {
    final height = maxValue > 0 ? (value / maxValue) * 150 : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$value',
              style: const TextStyle(
                color: CupertinoColors.systemPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          height: height.clamp(20.0, 150.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.systemPurple,
                CupertinoColors.systemPurple.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
