import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/task_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getTasksCollection(String userId) => 'users/$userId/tasks';

  // Task qo'shish
  Future<String> addTask(Task task) async {
    final docRef = await _firestore
        .collection(_getTasksCollection(task.userId))
        .add(task.toFirestore());
    return docRef.id;
  }

  // Barcha tasklar
  Future<List<Task>> getAllTasks(String userId) async {
    final snapshot = await _firestore
        .collection(_getTasksCollection(userId))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  // Bugungi tasklar
  Future<List<Task>> getTodayTasks(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection(_getTasksCollection(userId))
        .where(
          'deadline',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  /// Writes a task, creating the document if it is not there yet.
  ///
  /// This is an upsert rather than an `update` on purpose: a task created
  /// while offline is stored locally under a client-generated id, so the
  /// document does not exist in Firestore yet. `update` would throw
  /// `not-found` and the task would never reach the cloud.
  Future<void> updateTask(String userId, Task task) async {
    await _firestore
        .collection(_getTasksCollection(userId))
        .doc(task.id)
        .set(task.toFirestore(), SetOptions(merge: true));
  }

  // Task o'chirish
  Future<void> deleteTask(String userId, String taskId) async {
    await _firestore
        .collection(_getTasksCollection(userId))
        .doc(taskId)
        .delete();
  }

  // Bajarilgan tasklar soni
  Future<int> getCompletedTasksCount(String userId) async {
    final snapshot = await _firestore
        .collection(_getTasksCollection(userId))
        .where('isCompleted', isEqualTo: true)
        .get();

    return snapshot.docs.length;
  }

  // Realtime stream
  Stream<List<Task>> getTasksStream(String userId) {
    return _firestore
        .collection(_getTasksCollection(userId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  // Barcha tasklarni o'chirish
  Future<void> clearAllTasks(String userId) async {
    final snapshot = await _firestore
        .collection(_getTasksCollection(userId))
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
