import 'package:flutter/cupertino.dart';

class HomeNavigationBar extends CupertinoNavigationBar {
  HomeNavigationBar({super.key, required VoidCallback onMenuPressed})
    : super(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: Text(
          "Bosh sahifa",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onMenuPressed,
          child: Icon(
            CupertinoIcons.line_horizontal_3,
            color: CupertinoColors.white,
          ),
        ),
        border: null,
      );
}
