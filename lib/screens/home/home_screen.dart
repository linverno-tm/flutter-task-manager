import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/screens/home/widget/add_task_button.dart'
    show AddTaskButton;
import 'package:my_tp_2/screens/home/widget/empty_state.dart' show EmptyState;
import 'package:my_tp_2/screens/home/widget/task_list.dart' show TaskList;
import 'package:my_tp_2/service/auth_service/auth_service.dart'
    show AuthService;
import 'package:my_tp_2/service/task_service/task_service.dart'
    show TaskService;
import '../../models/task_model.dart';
import 'task/add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onScrollDown;
  final VoidCallback onScrollUp;

  const HomeScreen({
    super.key,
    required this.onScrollDown,
    required this.onScrollUp,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final ScrollController _scrollController = ScrollController();

  List<Task> _tasks = [];
  bool _isLoading = true;
  double _lastScrollPosition = 0;
  int _selectedFilter = 0; // 0: All, 1: Today, 2: Completed, 3: Pending

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll > _lastScrollPosition && currentScroll > 50) {
      widget.onScrollDown();
    } else if (currentScroll < _lastScrollPosition) {
      widget.onScrollUp();
    }

    _lastScrollPosition = currentScroll;
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final tasks = await _taskService.getAllTasks(userId);

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> _getFilteredTasks() {
    switch (_selectedFilter) {
      case 1: // Today
        final today = DateTime.now();
        return _tasks.where((task) {
          if (task.deadLine == null) return false;
          return task.deadLine!.year == today.year &&
              task.deadLine!.month == today.month &&
              task.deadLine!.day == today.day;
        }).toList();
      case 2: // Completed
        return _tasks.where((task) => task.isCompleted).toList();
      case 3: // Pending
        return _tasks.where((task) => !task.isCompleted).toList();
      default: // All
        return _tasks;
    }
  }

  void _navigateToAddTask() {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => const AddTaskScreen()))
        .then((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: const Text(
          'Vazifalar',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _loadTasks,
          child: const Icon(
            CupertinoIcons.refresh,
            color: CupertinoColors.white,
          ),
        ),
        border: null,
      ),
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildFilterTabs(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(radius: 15),
                        )
                      : filteredTasks.isEmpty
                      ? const EmptyState()
                      : TaskList(
                          tasks: filteredTasks,
                          scrollController: _scrollController,
                          onTaskUpdated: _loadTasks,
                        ),
                ),
              ],
            ),
          ),
          AddTaskButton(onPressed: _navigateToAddTask),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor: const Color(0xFF1E1E1E),
        thumbColor: CupertinoColors.systemPurple.withOpacity(0.3),
        groupValue: _selectedFilter,
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Hammasi', style: TextStyle(fontSize: 13)),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Bugun', style: TextStyle(fontSize: 13)),
          ),
          2: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Bajarilgan', style: TextStyle(fontSize: 13)),
          ),
          3: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Kutilmoqda', style: TextStyle(fontSize: 13)),
          ),
        },
        onValueChanged: (value) {
          setState(() => _selectedFilter = value!);
        },
      ),
    );
  }
}
