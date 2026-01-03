import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:my_tp_2/screens/home/task/edit_task_screen.dart';
import '../../../models/task_model.dart';
import '../../../service/task_service/task_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTaskUpdated;

  const TaskCard({super.key, required this.task, required this.onTaskUpdated});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              CupertinoPageRoute(
                builder: (context) => EditTaskScreen(task: task),
              ),
            )
            .then((_) => onTaskUpdated());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? CupertinoColors.systemGreen.withOpacity(0.3)
                : _getPriorityColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCheckbox(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryChip(),
                      const SizedBox(width: 8),
                      _buildPriorityChip(),
                      if (task.deadLine != null) ...[
                        const SizedBox(width: 8),
                        _builddeadLineChip(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await TaskService().toggleTaskComplete(task);
        onTaskUpdated();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? CupertinoColors.systemGreen
              : CupertinoColors.transparent,
          border: Border.all(
            color: task.isCompleted
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: task.isCompleted
            ? const Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        task.category,
        style: const TextStyle(color: CupertinoColors.systemBlue, fontSize: 12),
      ),
    );
  }

  Widget _buildPriorityChip() {
    final color = _getPriorityColor();
    final text = _getPriorityText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.flag_fill, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _builddeadLineChip() {
    final now = DateTime.now();
    final isOverdue = task.deadLine!.isBefore(now) && !task.isCompleted;
    final color = isOverdue
        ? CupertinoColors.systemRed
        : CupertinoColors.systemOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.clock, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM dd, HH:mm').format(task.deadLine!),
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case 1:
        return CupertinoColors.systemGreen;
      case 2:
        return CupertinoColors.systemOrange;
      case 3:
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case 1:
        return 'Past';
      case 2:
        return 'O\'rta';
      case 3:
        return 'Yuqori';
      default:
        return 'Normal';
    }
  }
}
