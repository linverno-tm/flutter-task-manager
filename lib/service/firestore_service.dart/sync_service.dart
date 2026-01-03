import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firestore_service.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _database = DatabaseService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Internet holatini kuzatish
  void startListening(String userId) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile,
      );

      if (hasConnection && !_isSyncing) {
        syncPendingTasks(userId);
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  // Internet bormi tekshirish
  Future<bool> hasInternetConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile,
    );
  }

  // Pending taskларni sync qilish
  Future<void> syncPendingTasks(String userId) async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        _isSyncing = false;
        return;
      }

      final unsyncedTasks = await _database.getUnsyncedTasks(userId);

      for (var task in unsyncedTasks) {
        try {
          if (task.id == null || task.id!.isEmpty) {
            // Yangi task - Firestore'ga qo'shish
            final firestoreId = await _firestore.addTask(task);

            // Local database'da yangilash
            final syncedTask = task.copyWith(id: firestoreId, isSynced: true);
            await _database.updateTask(syncedTask);
          } else {
            // Mavjud task - Firestore'da yangilash
            await _firestore.updateTask(userId, task);

            // Local database'da synced deb belgilash
            final syncedTask = task.copyWith(isSynced: true);
            await _database.updateTask(syncedTask);
          }
        } catch (e) {
          print('Task sync error: $e');
        }
      }

      // Firestore'dan local database'ga sync qilish
      await syncFromFirestore(userId);
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Firestore'dan local'ga sync
  Future<void> syncFromFirestore(String userId) async {
    try {
      final firestoreTasks = await _firestore.getAllTasks(userId);

      for (var task in firestoreTasks) {
        await _database.insertTask(task.copyWith(isSynced: true));
      }
    } catch (e) {
      print('Sync from Firestore error: $e');
    }
  }

  // To'liq sync (ikki tomonlama)
  Future<void> fullSync(String userId) async {
    await syncPendingTasks(userId);
    await syncFromFirestore(userId);
  }

  // Sync holatini tekshirish
  bool get isSyncing => _isSyncing;
}
