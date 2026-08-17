import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _database = DatabaseService();
  final Connectivity _connectivity = Connectivity();

  /// Host used to confirm real connectivity. Firestore's own endpoint, so a
  /// success here means the backend is actually reachable.
  static const String _reachabilityHost = 'firestore.googleapis.com';
  static const Duration _reachabilityTimeout = Duration(seconds: 4);

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

  /// Whether the device can actually reach the network.
  ///
  /// `connectivity_plus` only reports which interface is up, so a phone
  /// attached to a Wi-Fi access point with no upstream still reports `wifi`.
  /// The interface check is used as a cheap negative, then confirmed with a
  /// DNS lookup. On the web `dart:io` is unavailable, so the interface state
  /// is all we have.
  Future<bool> hasInternetConnection() async {
    if (!await _hasNetworkInterface()) {
      return false;
    }
    if (kIsWeb) {
      return true;
    }

    try {
      final result = await InternetAddress.lookup(
        _reachabilityHost,
      ).timeout(_reachabilityTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<bool> _hasNetworkInterface() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
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

      for (final task in unsyncedTasks) {
        try {
          if (task.id == null || task.id!.isEmpty) {
            // No id at all: let Firestore allocate one, then adopt it locally.
            final firestoreId = await _firestore.addTask(task);
            await _database.updateTask(
              task.copyWith(id: firestoreId, isSynced: true),
            );
          } else {
            // The task already has an id - either a Firestore id from an
            // online create, or a client-generated one from an offline create.
            // updateTask upserts, so both cases converge on the same document
            // and the local and remote ids stay identical.
            await _firestore.updateTask(userId, task);
            await _database.updateTask(task.copyWith(isSynced: true));
          }
        } catch (e) {
          debugPrint('Task sync error: $e');
        }
      }

      // Firestore'dan local database'ga sync qilish
      await syncFromFirestore(userId);
    } catch (e) {
      debugPrint('Sync error: $e');
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
      debugPrint('Sync from Firestore error: $e');
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
