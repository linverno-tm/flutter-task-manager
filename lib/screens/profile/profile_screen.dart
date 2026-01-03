import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart';
import 'package:my_tp_2/service/firestore_service.dart/sync_service.dart';
import 'package:my_tp_2/service/task_service/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/settings_tile.dart';
import 'widgets/theme_switcher.dart';
import 'widgets/language_selector.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onScrollDown;
  final VoidCallback onScrollUp;

  const ProfileScreen({
    super.key,
    required this.onScrollDown,
    required this.onScrollUp,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final SyncService _syncService = SyncService();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  double _lastScrollPosition = 0;
  bool _isDarkMode = true;
  String _selectedLanguage = 'uz';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll > _lastScrollPosition && currentScroll > 50) {
      widget.onScrollDown();
    } else if (currentScroll < _lastScrollPosition) {
      widget.onScrollUp();
    }

    _lastScrollPosition = currentScroll;
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final data = await _authService.getUserData();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'uz';
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() => _isDarkMode = isDark);
    // TODO: Theme'ni o'zgartirish uchun app restart kerak
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() => _selectedLanguage = language);
    // TODO: Til o'zgartirish uchun localization kerak
  }

  Future<void> _syncData() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    _showLoadingDialog();

    try {
      await _syncService.fullSync(userId);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        _showSuccessDialog('Ma\'lumotlar muvaffaqiyatli sinxronlandi');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        _showErrorDialog('Sinxronlashda xatolik: ${e.toString()}');
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      'Barcha ma\'lumotlarni o\'chirish',
      'Barcha vazifalaringiz o\'chiriladi. Davom etasizmi?',
    );

    if (!confirmed) return;

    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    _showLoadingDialog();

    try {
      await _taskService.clearAllTasks(userId);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        _showSuccessDialog('Barcha ma\'lumotlar o\'chirildi');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        _showErrorDialog(
          'Ma\'lumotlarni o\'chirishda xatolik: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await _showConfirmDialog(
      'Chiqish',
      'Hisobdan chiqmoqchimisiz?',
    );

    if (!confirmed) return;

    await _authService.signOut();
  }

  void _showLoadingDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CupertinoActivityIndicator(radius: 20)),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Muvaffaqiyatli'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Xatolik'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Bekor qilish'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Ha'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF121212),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        middle: const Text(
          'Profil',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 15))
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3C),
              shape: BoxShape.circle,
              image: _userData?['photoURL'] != null
                  ? DecorationImage(
                      image: NetworkImage(_userData!['photoURL']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _userData?['photoURL'] == null
                ? const Icon(
                    CupertinoIcons.person_fill,
                    color: CupertinoColors.white,
                    size: 35,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['fullName'] ??
                      _userData?['displayName'] ??
                      user?.displayName ??
                      'Foydalanuvchi',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Sozlamalar',
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ThemeSwitcher(
                isDarkMode: _isDarkMode,
                onThemeChanged: _saveTheme,
              ),
              const Divider(height: 1, color: Color(0xFF3C3C3C)),
              LanguageSelector(
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: _saveLanguage,
              ),
              const Divider(height: 1, color: Color(0xFF3C3C3C)),
              SettingsTile(
                icon: CupertinoIcons.refresh_circled,
                title: 'Sinxronlashtirish',
                onTap: _syncData,
              ),
              const Divider(height: 1, color: Color(0xFF3C3C3C)),
              SettingsTile(
                icon: CupertinoIcons.trash,
                title: 'Ma\'lumotlarni tozalash',
                onTap: _clearAllData,
                isDestructive: true,
              ),
              const Divider(height: 1, color: Color(0xFF3C3C3C)),
              SettingsTile(
                icon: CupertinoIcons.square_arrow_right,
                title: 'Chiqish',
                onTap: _logout,
                isDestructive: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              color: CupertinoColors.systemGrey.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
