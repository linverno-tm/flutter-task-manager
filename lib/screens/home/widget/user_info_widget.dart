import 'package:flutter/cupertino.dart';

class UserInfo extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final dynamic user;
  const UserInfo({super.key, required this.userData, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Xush kelibsiz",
          style: TextStyle(color: CupertinoColors.white, fontSize: 14),
        ),
        SizedBox(height: 4),

        Text(
          userData?["fullName"] ??
              userData?["disPlayName"] ??
              user?.displayName ??
              "Foydalanuvchi",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),

          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
