import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';
import 'package:my_tp_2/models/task_model.dart';

Task buildTask({
  String? id = 'task-1',
  String title = 'Write documentation',
  String description = 'README and API docs',
  DateTime? createdAt,
  DateTime? deadline,
  bool isCompleted = false,
  String category = 'Work',
  int priority = 3,
  String userId = 'user-1',
  bool isSynced = false,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 15, 9, 30),
    deadLine: deadline,
    isCompleted: isCompleted,
    category: category,
    priority: priority,
    userId: userId,
    isSynced: isSynced,
  );
}

void main() {
  group('Task defaults', () {
    test('unspecified fields fall back to sane values', () {
      final task = Task(
        id: null,
        title: 'Quick note',
        description: '',
        createdAt: DateTime.utc(2026, 1, 1),
        userId: 'user-1',
      );

      expect(task.category, 'Personal');
      expect(task.priority, 2);
      expect(task.isCompleted, isFalse);
      expect(task.isSynced, isFalse);
      expect(task.deadLine, isNull);
    });
  });

  group('SQLite mapping', () {
    test('booleans are stored as integers', () {
      final map = buildTask(isCompleted: true, isSynced: true).toMap();

      expect(map['isCompleted'], 1);
      expect(map['isSynced'], 1);
    });

    test('dates are stored as ISO-8601 strings', () {
      final createdAt = DateTime.utc(2026, 1, 15, 9, 30);
      final deadline = DateTime.utc(2026, 1, 20, 18);

      final map = buildTask(createdAt: createdAt, deadline: deadline).toMap();

      expect(map['createdAt'], createdAt.toIso8601String());
      expect(map['deadline'], deadline.toIso8601String());
    });

    test('a null deadline stays null in the map', () {
      expect(buildTask().toMap()['deadline'], isNull);
    });

    test('toMap -> fromMap round trip preserves every field', () {
      final original = buildTask(
        deadline: DateTime.utc(2026, 1, 20, 18),
        isCompleted: true,
        isSynced: true,
      );

      final restored = Task.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.createdAt, original.createdAt);
      expect(restored.deadLine, original.deadLine);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.category, original.category);
      expect(restored.priority, original.priority);
      expect(restored.userId, original.userId);
      expect(restored.isSynced, original.isSynced);
    });

    test('fromMap applies defaults for missing optional columns', () {
      final task = Task.fromMap({
        'id': 'task-9',
        'title': 'Legacy row',
        'description': 'written before categories existed',
        'createdAt': DateTime.utc(2025, 6, 1).toIso8601String(),
        'deadline': null,
        'isCompleted': 0,
        'category': null,
        'priority': null,
        'userId': 'user-1',
        'isSynced': 0,
      });

      expect(task.category, 'Personal');
      expect(task.priority, 2);
      expect(task.isCompleted, isFalse);
    });
  });

  group('Firestore mapping', () {
    test('toFirestore omits local-only fields', () {
      final map = buildTask(isSynced: true).toFirestore();

      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('isSynced'), isFalse);
    });

    test('toFirestore keeps booleans as booleans', () {
      final map = buildTask(isCompleted: true).toFirestore();

      expect(map['isCompleted'], isTrue);
      expect(map['isCompleted'], isA<bool>());
    });

    test('dates are converted to Firestore timestamps', () {
      final createdAt = DateTime.utc(2026, 1, 15, 9, 30);
      final deadline = DateTime.utc(2026, 1, 20, 18);

      final map = buildTask(createdAt: createdAt, deadline: deadline)
          .toFirestore();

      // Timestamp.toDate() returns local time, so compare instants.
      expect(map['createdAt'], isA<Timestamp>());
      expect(
        (map['createdAt'] as Timestamp).toDate().isAtSameMomentAs(createdAt),
        isTrue,
      );
      expect(
        (map['deadline'] as Timestamp).toDate().isAtSameMomentAs(deadline),
        isTrue,
      );
    });

    test('a null deadline is written as null, not a zero timestamp', () {
      expect(buildTask().toFirestore()['deadline'], isNull);
    });
  });

  group('copyWith', () {
    test('overrides only the given field', () {
      final original = buildTask();
      final updated = original.copyWith(isCompleted: true);

      expect(updated.isCompleted, isTrue);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.createdAt, original.createdAt);
      expect(updated.userId, original.userId);
    });

    test('marking a task synced keeps the rest intact', () {
      final original = buildTask(isSynced: false);
      final synced = original.copyWith(id: 'firestore-id', isSynced: true);

      expect(synced.id, 'firestore-id');
      expect(synced.isSynced, isTrue);
      expect(synced.title, original.title);
      expect(synced.priority, original.priority);
    });

    test('toggling completion twice returns to the original state', () {
      final original = buildTask(isCompleted: false);
      final toggled = original.copyWith(isCompleted: !original.isCompleted);
      final restored = toggled.copyWith(isCompleted: !toggled.isCompleted);

      expect(toggled.isCompleted, isTrue);
      expect(restored.isCompleted, isFalse);
    });

    test('a deadline can be set on a task that had none', () {
      final deadline = DateTime.utc(2026, 3, 1);
      final updated = buildTask().copyWith(deadline: deadline);

      expect(updated.deadLine, deadline);
    });

    test(
      'copyWith cannot clear an existing deadline (null falls through to the '
      'current value) — clearing requires constructing a new Task',
      () {
        final withDeadline = buildTask(deadline: DateTime.utc(2026, 3, 1));

        final attempted = withDeadline.copyWith(deadline: null);

        expect(attempted.deadLine, isNotNull);
        expect(attempted.deadLine, withDeadline.deadLine);
      },
    );
  });
}
