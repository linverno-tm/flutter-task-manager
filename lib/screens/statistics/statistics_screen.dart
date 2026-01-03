import 'package:flutter/cupertino.dart';
import '../../models/task_model.dart';
import '../../service/auth_service/auth_service.dart';
import '../../service/task_service/task_service.dart';
import 'widgets/stats_card.dart';
import 'widgets/productivity_meter.dart';
import 'widgets/progress_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final VoidCallback onScrollDown;
  final VoidCallback onScrollUp;

  const StatisticsScreen({
    super.key,
    required this.onScrollDown,
    required this.onScrollUp,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final ScrollController _scrollController = ScrollController();

  List<Task> _allTasks = [];
  bool _isLoading = true;
  double _lastScrollPosition = 0;
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month

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
      _isLoading = false;
    });
  }

  List<Task> _getFilteredTasks() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 0: // Today
        return _allTasks.where((task) {
          return task.createdAt.year == now.year &&
              task.createdAt.month == now.month &&
              task.createdAt.day == now.day;
        }).toList();
      case 1: // Week
        final weekAgo = now.subtract(const Duration(days: 7));
        return _allTasks.where((task) {
          return task.createdAt.isAfter(weekAgo);
        }).toList();
      case 2: // Month
        return _allTasks.where((task) {
          return task.createdAt.year == now.year &&
              task.createdAt.month == now.month;
        }).toList();
      default:
        return _allTasks;
    }
  }

  int _getCompletedCount(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  int _getPendingCount(List<Task> tasks) {
    return tasks.where((task) => !task.isCompleted).length;
  }

  double _getProductivityPercentage(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    return (_getCompletedCount(tasks) / tasks.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final completedCount = _getCompletedCount(filteredTasks);
    final pendingCount = _getPendingCount(filteredTasks);
    final productivity = _getProductivityPercentage(filteredTasks);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: const Text(
          'Statistika',
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
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    ProductivityMeter(percentage: productivity),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Jami',
                            value: '${filteredTasks.length}',
                            icon: CupertinoIcons.square_list,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Bajarilgan',
                            value: '$completedCount',
                            icon: CupertinoIcons.checkmark_circle,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Kutilmoqda',
                            value: '$pendingCount',
                            icon: CupertinoIcons.clock,
                            color: CupertinoColors.systemOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Samaradorlik',
                            value: '${productivity.toStringAsFixed(0)}%',
                            icon: CupertinoIcons.chart_bar,
                            color: CupertinoColors.systemPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ProgressChart(
                      tasks: filteredTasks,
                      period: _selectedPeriod,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return CupertinoSlidingSegmentedControl<int>(
      backgroundColor: const Color(0xFF1E1E1E),
      thumbColor: CupertinoColors.systemPurple.withOpacity(0.3),
      groupValue: _selectedPeriod,
      children: const {
        0: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('Bugun', style: TextStyle(fontSize: 14)),
        ),
        1: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('Hafta', style: TextStyle(fontSize: 14)),
        ),
        2: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('Oy', style: TextStyle(fontSize: 14)),
        ),
      },
      onValueChanged: (value) {
        setState(() => _selectedPeriod = value!);
      },
    );
  }
}
