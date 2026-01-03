import 'package:flutter/cupertino.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.checkmark_alt_circle,
              size: 80,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vazifalar yo\'q',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yangi vazifa qo\'shish uchun\n+ tugmasini bosing',
            textAlign: TextAlign.center,
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
