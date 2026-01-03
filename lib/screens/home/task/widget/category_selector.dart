import 'package:flutter/cupertino.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Personal',
      'icon': CupertinoIcons.person,
      'color': CupertinoColors.systemBlue,
    },
    {
      'name': 'Work',
      'icon': CupertinoIcons.briefcase,
      'color': CupertinoColors.systemPurple,
    },
    {
      'name': 'Shopping',
      'icon': CupertinoIcons.cart,
      'color': CupertinoColors.systemOrange,
    },
    {
      'name': 'Health',
      'icon': CupertinoIcons.heart,
      'color': CupertinoColors.systemRed,
    },
    {
      'name': 'Study',
      'icon': CupertinoIcons.book,
      'color': CupertinoColors.systemGreen,
    },
    {
      'name': 'Other',
      'icon': CupertinoIcons.tag,
      'color': CupertinoColors.systemGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        return _buildCategoryButton(
          name: category['name'],
          icon: category['icon'],
          color: category['color'],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryButton({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedCategory == name;

    return GestureDetector(
      onTap: () => onCategoryChanged(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF3C3C3C),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : CupertinoColors.systemGrey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              name,
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
