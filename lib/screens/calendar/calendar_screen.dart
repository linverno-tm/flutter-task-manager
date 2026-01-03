import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart'
    show AuthService;
import 'package:my_tp_2/service/task_service/task_service.dart'
    show TaskService;
import '../../models/task_model.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/day_tasks_list.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onScrollDown;
  final VoidCallback onScrollUp;

  const CalendarScreen({
    super.key,
    required this.onScrollDown,
    required this.onScrollUp,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final ScrollController _scrollController = ScrollController();

  List<Task> _allTasks = [];
  List<Task> _selectedDayTasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  double _lastScrollPosition = 0;

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
      _allTasks = tasks;
      _filterTasksByDate(_selectedDate);
      _isLoading = false;
    });
  }

  void _filterTasksByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedDayTasks = _allTasks.where((task) {
        if (task.deadLine == null) return false;
        return task.deadLine!.year == date.year &&
            task.deadLine!.month == date.month &&
            task.deadLine!.day == date.day;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: const Text(
          'Kalendar',
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
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 15))
            : Column(
                children: [
                  CalendarWidget(
                    selectedDate: _selectedDate,
                    tasks: _allTasks,
                    onDateSelected: _filterTasksByDate,
                  ),
                  Expanded(
                    child: DayTasksList(
                      tasks: _selectedDayTasks,
                      selectedDate: _selectedDate,
                      scrollController: _scrollController,
                      onTaskUpdated: _loadTasks,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
