import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../models/task_model.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<Task> tasks;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onDateSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _hasTasksOnDate(DateTime date) {
    return widget.tasks.any((task) {
      if (task.deadLine == null) return false;
      return task.deadLine!.year == date.year &&
          task.deadLine!.month == date.month &&
          task.deadLine!.day == date.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekDays(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _previousMonth,
          child: const Icon(
            CupertinoIcons.chevron_left,
            color: CupertinoColors.white,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _nextMonth,
          child: const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // Empty cells before first day
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Days of month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return Wrap(spacing: 4, runSpacing: 4, children: dayWidgets);
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected =
        widget.selectedDate.year == date.year &&
        widget.selectedDate.month == date.month &&
        widget.selectedDate.day == date.day;

    final isToday =
        DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    final hasTasks = _hasTasksOnDate(date);

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemPurple
              : isToday
              ? CupertinoColors.systemPurple.withOpacity(0.2)
              : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.white
                    : isToday
                    ? CupertinoColors.systemPurple
                    : CupertinoColors.white,
                fontSize: 14,
                fontWeight: isSelected || isToday
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            if (hasTasks && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
