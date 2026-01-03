import 'package:flutter/cupertino.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddTaskButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 95, // Bottom nav bar (65) + margin (30)
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                CupertinoColors.systemPurple,
                CupertinoColors.systemIndigo,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.add,
            color: CupertinoColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
