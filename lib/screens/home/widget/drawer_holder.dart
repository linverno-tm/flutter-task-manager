import 'package:flutter/cupertino.dart';

class DrawerHolder extends StatelessWidget {
  const DrawerHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12, bottom: 20),
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
