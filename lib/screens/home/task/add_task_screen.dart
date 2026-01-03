import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/models/task_model.dart';
import 'package:my_tp_2/screens/home/task/widget/category_selector.dart';
import 'package:my_tp_2/screens/home/task/widget/date_time_picker.dart';
import 'package:my_tp_2/screens/home/task/widget/priority_selector.dart';

import '../../../service/auth_service/auth_service.dart';
import '../../../service/task_service/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedPriority = 2;
  String _selectedCategory = 'Personal';
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog(
        'Sarlavha kiritilmagan',
        'Iltimos, vazifa sarlavhasini kiriting',
      );
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _showErrorDialog('Xatolik', 'Foydalanuvchi topilmadi');
      return;
    }

    setState(() => _isLoading = true);

    final task = Task(
      id: userId, // Temporary ID, will be replaced by backend
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      deadLine: _selectedDeadline,
      priority: _selectedPriority,
      category: _selectedCategory,
      userId: userId,
    );

    final result = await _taskService.addTask(task);

    setState(() => _isLoading = false);

    if (result != null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _showErrorDialog('Xatolik', 'Vazifa qo\'shishda xatolik yuz berdi');
    }
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: const Text(
          'Yangi vazifa',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _addTask,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text(
                  'Saqlash',
                  style: TextStyle(
                    color: CupertinoColors.systemPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                placeholder: 'Sarlavha',
                icon: CupertinoIcons.text_cursor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                placeholder: 'Tavsif (ixtiyoriy)',
                icon: CupertinoIcons.text_alignleft,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              const Text(
                'Muhimlik darajasi',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              PrioritySelector(
                selectedPriority: _selectedPriority,
                onPriorityChanged: (priority) {
                  setState(() => _selectedPriority = priority);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Kategoriya',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Muddat',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DateTimePicker(
                selectedDateTime: _selectedDeadline,
                onDateTimeChanged: (dateTime) {
                  setState(() => _selectedDeadline = dateTime);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    int maxLines = 1,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
      style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
      maxLines: maxLines,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3C3C3C), width: 1),
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: CupertinoColors.systemGrey, size: 20),
      ),
    );
  }
}
