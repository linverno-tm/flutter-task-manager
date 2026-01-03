import 'package:flutter/cupertino.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ThemeSwitcher({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
            color: CupertinoColors.systemGrey,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(color: CupertinoColors.white, fontSize: 16),
            ),
          ),
          CupertinoSwitch(
            value: isDarkMode,
            activeColor: CupertinoColors.systemPurple,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}
