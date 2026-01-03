import 'package:flutter/cupertino.dart';
import '../../../models/task_model.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final ScrollController scrollController;
  final VoidCallback onTaskUpdated;

  const TaskList({
    super.key,
    required this.tasks,
    required this.scrollController,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: tasks[index], onTaskUpdated: onTaskUpdated);
      },
    );
  }
}
