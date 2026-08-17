import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_tp_2/service/auth_service/auth_service.dart'
    show AuthService;
import 'package:my_tp_2/service/data/sync_service.dart'
    show SyncService;
import 'package:my_tp_2/service/local_notif_service/permission_service.dart'
    show PermissionService;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_screen.dart';
import 'service/local_notif_service/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize
  await Firebase.initializeApp();

  // Timezone initialize - CRITICAL!
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));

  // Permission request - Android 13+
  await PermissionService.requestNotificationPermission();

  // Notification service initialize
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    // Auth state changes'ni kuzatib, sync'ni boshlash
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _syncService.startListening(user.uid);
      } else {
        _syncService.stopListening();
      }
    });
  }

  @override
  void dispose() {
    _syncService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemPurple,
        scaffoldBackgroundColor: Color(0xFF121212),
        barBackgroundColor: Color(0xFF1E1E1E),
      ),
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoPageScaffold(
              child: Center(child: CupertinoActivityIndicator(radius: 15)),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
