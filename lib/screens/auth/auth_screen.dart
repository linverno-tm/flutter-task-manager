import 'package:flutter/cupertino.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart' show AuthService;

import 'widget/auth_widgets._all.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final fullName = _nameController.text.trim();

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Ismingizni kiriting';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _authService.signInWithGoogle(fullName: fullName);

      if (result == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (mounted) {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Xatolik: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthLogo(),
                const SizedBox(height: 40),
                const AuthTitle(),
                const SizedBox(height: 40),
                const AuthSubtitle(),
                const SizedBox(height: 50),
                NameInputField(controller: _nameController),
                const SizedBox(height: 30),
                GoogleSignInButton(
                  isLoading: _isLoading,
                  onPressed: _handleGoogleSignIn,
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 29),
                  ErrorMessage(message: _errorMessage),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
