import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:my_tp_2/screens/home/widget/task_card.dart' show TaskCard;
import '../../../models/task_model.dart';

class DayTasksList extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDate;
  final ScrollController scrollController;
  final VoidCallback onTaskUpdated;

  const DayTasksList({
    super.key,
    required this.tasks,
    required this.selectedDate,
    required this.scrollController,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF121212)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              DateFormat('dd MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: tasks[index],
                        onTaskUpdated: onTaskUpdated,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.calendar,
              size: 60,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bu kunda vazifalar yo\'q',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Boshqa sanani tanlang yoki\nyangi vazifa qo\'shing',
            textAlign: TextAlign.center,
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
