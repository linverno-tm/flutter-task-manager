// auth logo
import 'package:flutter/cupertino.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CupertinoColors.systemBlue.withOpacity(0.3),
            CupertinoColors.systemPurple.withOpacity(0.3),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CupertinoIcons.lock_fill,
        size: 80,
        color: CupertinoColors.white,
      ),
    );
  }
}

// auth title
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Xush kelibsiz",
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
        letterSpacing: 1.2,
      ),
    );
  }
}

// Auth Subtitle Widget
class AuthSubtitle extends StatelessWidget {
  const AuthSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Davom etish uchun Google Account bilan kiring",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: CupertinoColors.white, height: 1.5),
    );
  }
}

// Name Input Field Widget
class NameInputField extends StatelessWidget {
  final TextEditingController controller;

  const NameInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "To'liq ismingiz",
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: "Ismingizi kiriting",
          placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
          style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3C3C3C), width: 1),
          ),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// Google Sign In Button Widget
class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(12),
        color: CupertinoColors.white,
        child: isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.black)
            : const GoogleSignInContent(),
      ),
    );
  }
}

// Google Sign In Button Content Widget
class GoogleSignInContent extends StatelessWidget {
  const GoogleSignInContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          "https://www.google.com/favicon.ico",
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              CupertinoIcons.globe,
              size: 24,
              color: CupertinoColors.black,
            );
          },
        ),
        const SizedBox(width: 12),
        const Text(
          "Google bilan kirish",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
      ],
    );
  }
}

// Error Message Widget
class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
