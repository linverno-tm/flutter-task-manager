import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/screens/home/widget/drawer_holder.dart';
import 'package:my_tp_2/screens/home/widget/user_profile_card.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart';

class UserDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final AuthService authService;
  const UserDrawer({
    super.key,
    required this.userData,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const DrawerHolder(),
            UserProfileCard(userData: userData, authService: authService),
          ],
        ),
      ),
    );
  }
}
