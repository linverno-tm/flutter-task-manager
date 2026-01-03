import 'package:flutter/cupertino.dart';

class DrawleHandel extends StatelessWidget {
  const DrawleHandel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey2,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
