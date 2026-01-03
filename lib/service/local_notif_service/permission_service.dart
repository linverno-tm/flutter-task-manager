import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<void> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;

      if (status.isDenied) {
        debugPrint('🔔 Requesting notification permission...');
        final result = await Permission.notification.request();
        debugPrint('🔔 Permission result: $result');
      } else {
        debugPrint('🔔 Notification permission already granted');
      }
    }
  }

  static Future<bool> isNotificationEnabled() async {
    return await Permission.notification.isGranted;
  }
}
