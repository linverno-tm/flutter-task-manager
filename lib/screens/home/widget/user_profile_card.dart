import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/screens/home/widget/user_avatar_widget.dart';
import 'package:my_tp_2/screens/home/widget/user_info_widget.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart';

class UserProfileCard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final AuthService authService;
  const UserProfileCard({
    super.key,
    required this.userData,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          UserAvatar(photoUrl: userData?["photUrl"]),
          SizedBox(width: 16),
          Expanded(
            child: UserInfo(userData: userData, user: user),
          ),
        ],
      ),
    );
  }
}
