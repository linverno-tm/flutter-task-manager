import '../../models/task_model.dart';
import '../firestore_service.dart/database_service.dart';
import '../firestore_service.dart/firestore_service.dart';
import '../firestore_service.dart/sync_service.dart';
import '../local_notif_service/local_notification_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _database = DatabaseService();
  final NotificationService _notification = NotificationService();
  final SyncService _sync = SyncService();

  // ➕ Task qo'shish
  Future<String?> addTask(Task task) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();
      String? taskId;

      if (hasInternet) {
        // Online: Firestore'ga qo'shish
        taskId = await _firestore.addTask(task);
        final syncedTask = task.copyWith(id: taskId, isSynced: true);
        await _database.insertTask(syncedTask);
      } else {
        // Offline: Local database'ga qo'shish
        taskId = DateTime.now().millisecondsSinceEpoch.toString();
        final unsyncedTask = task.copyWith(id: taskId, isSynced: false);
        await _database.insertTask(unsyncedTask);
      }

      // Notification schedule qilish
      if (task.deadLine != null) {
        await _notification.scheduleTaskNotification(
          taskId: taskId,
          title: task.title,
          description: task.description,
          scheduledDate: task.deadLine!,
        );
      }

      return taskId;
    } catch (e) {
      print('Add task error: $e');
      return null;
    }
  }

  // ✏️ Task yangilash
  Future<bool> updateTask(Task task) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        // Online: Firestore'da yangilash
        await _firestore.updateTask(task.userId, task);
        final syncedTask = task.copyWith(isSynced: true);
        await _database.updateTask(syncedTask);
      } else {
        // Offline: Local database'da yangilash
        final unsyncedTask = task.copyWith(isSynced: false);
        await _database.updateTask(unsyncedTask);
      }

      // Notification yangilash
      if (task.deadLine != null && !task.isCompleted) {
        await _notification.rescheduleTaskNotification(
          taskId: task.id!,
          title: task.title,
          description: task.description,
          scheduledDate: task.deadLine!,
        );
      } else {
        await _notification.cancelNotification(task.id!);
      }

      return true;
    } catch (e) {
      print('Update task error: $e');
      return false;
    }
  }

  // 🗑️ Task o'chirish
  Future<bool> deleteTask(String userId, String taskId) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        await _firestore.deleteTask(userId, taskId);
      }

      await _database.deleteTask(taskId);
      await _notification.cancelNotification(taskId);

      return true;
    } catch (e) {
      print('Delete task error: $e');
      return false;
    }
  }

  // ✅ Task bajarish/bekor qilish
  Future<bool> toggleTaskComplete(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    if (updatedTask.isCompleted) {
      // Task bajarildi - notification o'chirish
      await _notification.cancelNotification(task.id!);
    } else if (updatedTask.deadLine != null) {
      // Task bekor qilindi - notification qaytarish
      await _notification.scheduleTaskNotification(
        taskId: task.id!,
        title: task.title,
        description: task.description,
        scheduledDate: updatedTask.deadLine!,
      );
    }

    return await updateTask(updatedTask);
  }

  // 📋 Barcha tasklar
  Future<List<Task>> getAllTasks(String userId) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        final tasks = await _firestore.getAllTasks(userId);
        for (var task in tasks) {
          await _database.insertTask(task.copyWith(isSynced: true));
        }
        return tasks;
      } else {
        return await _database.getAllTasks(userId);
      }
    } catch (e) {
      print('Get all tasks error: $e');
      return await _database.getAllTasks(userId);
    }
  }

  // 📅 Bugungi tasklar
  Future<List<Task>> getTodayTasks(String userId) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        return await _firestore.getTodayTasks(userId);
      } else {
        return await _database.getTodayTasks(userId);
      }
    } catch (e) {
      print('Get today tasks error: $e');
      return await _database.getTodayTasks(userId);
    }
  }

  // 📊 Statistika
  Future<int> getCompletedTasksCount(String userId) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        return await _firestore.getCompletedTasksCount(userId);
      } else {
        return await _database.getCompletedTasksCount(userId);
      }
    } catch (e) {
      print('Get completed tasks count error: $e');
      return await _database.getCompletedTasksCount(userId);
    }
  }

  Future<int> getTotalTasksCount(String userId) async {
    return await _database.getTotalTasksCount(userId);
  }

  // 🔄 Realtime stream (Firestore)
  Stream<List<Task>> getTasksStream(String userId) {
    return _firestore.getTasksStream(userId);
  }

  // 🧹 Barcha tasklar o'chirish
  Future<void> clearAllTasks(String userId) async {
    try {
      final hasInternet = await _sync.hasInternetConnection();

      if (hasInternet) {
        await _firestore.clearAllTasks(userId);
      }

      await _database.clearAllTasks(userId);
      await _notification.cancelAllNotifications();
    } catch (e) {
      print('Clear all tasks error: $e');
    }
  }

  // 🔄 Manual sync
  Future<void> syncTasks(String userId) async {
    await _sync.syncPendingTasks(userId);
  }
}
