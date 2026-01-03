import 'package:flutter/cupertino.dart';

class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final Function(int) onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPriorityButton(
            priority: 1,
            label: 'Past',
            color: CupertinoColors.systemGreen,
            icon: CupertinoIcons.flag,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityButton(
            priority: 2,
            label: 'O\'rta',
            color: CupertinoColors.systemOrange,
            icon: CupertinoIcons.flag,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityButton(
            priority: 3,
            label: 'Yuqori',
            color: CupertinoColors.systemRed,
            icon: CupertinoIcons.flag_fill,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton({
    required int priority,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedPriority == priority;

    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF3C3C3C),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : CupertinoColors.systemGrey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
