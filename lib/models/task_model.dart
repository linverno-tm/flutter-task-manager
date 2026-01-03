import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, Timestamp;

class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadLine;
  final bool isCompleted;
  final String category;
  final int priority;
  final String userId;
  final bool isSynced;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.deadLine,
    this.isCompleted = false,
    this.category = "Personal",
    this.priority = 2,
    required this.userId,
    this.isSynced = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isCompleted,
    String? category,
    int? priority,
    String? userId,
    bool? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadLine: deadline ?? this.deadLine,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadLine?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'priority': priority,
      'userId': userId,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      deadLine: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      isCompleted: map['isCompleted'] == 1,
      category: map['category'] ?? 'Personal',
      priority: map['priority'] ?? 2,
      userId: map['userId'],
      isSynced: map['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadLine != null ? Timestamp.fromDate(deadLine!) : null,
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
      'userId': userId,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadLine: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] ?? false,
      category: data['category'] ?? 'Personal',
      priority: data['priority'] ?? 2,
      userId: data['userId'],
      isSynced: true,
    );
  }
}
