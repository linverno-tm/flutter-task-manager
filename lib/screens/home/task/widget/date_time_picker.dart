import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime?) onDateTimeChanged;

  const DateTimePicker({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showDateTimePicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3C3C3C), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDateTime != null
                        ? DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(selectedDateTime!)
                        : 'Muddat tanlang',
                    style: TextStyle(
                      color: selectedDateTime != null
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (selectedDateTime != null)
                  GestureDetector(
                    onTap: () => onDateTimeChanged(null),
                    child: const Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDateTimePicker(BuildContext context) {
    final now = DateTime.now();
    DateTime tempDateTime = selectedDateTime ?? now;

    // Agar tempDateTime hozirgi vaqtdan oldingi bo'lsa, hozirgi vaqtga o'zgartir
    if (tempDateTime.isBefore(now)) {
      tempDateTime = now;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
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
                    onPressed: () {
                      onDateTimeChanged(tempDateTime);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: tempDateTime,
                minimumDate: now,
                onDateTimeChanged: (DateTime newDateTime) {
                  tempDateTime = newDateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
