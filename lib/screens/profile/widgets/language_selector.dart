import 'package:flutter/cupertino.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  static const List<Map<String, String>> languages = [
    {'code': 'uz', 'name': 'O\'zbekcha'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
  ];

  void _showLanguagePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: const Color(0xFF1E1E1E),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Bekor qilish'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Tanlash'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFF1E1E1E),
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: languages.indexWhere(
                    (lang) => lang['code'] == selectedLanguage,
                  ),
                ),
                onSelectedItemChanged: (index) {
                  onLanguageChanged(languages[index]['code']!);
                },
                children: languages.map((lang) {
                  return Center(
                    child: Text(
                      lang['name']!,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    return languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'O\'zbekcha'},
    )['name']!;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showLanguagePicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.globe,
              color: CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Til',
                style: TextStyle(color: CupertinoColors.white, fontSize: 16),
              ),
            ),
            Text(
              _getLanguageName(selectedLanguage),
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
