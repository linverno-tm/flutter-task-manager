import 'package:flutter/cupertino.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  const UserAvatar({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF3C3C3C),
        shape: BoxShape.circle,
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.white,
              size: 30,
            )
          : null,
    );
  }
}
