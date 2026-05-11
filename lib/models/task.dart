import 'package:clock/clock.dart';

enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    required this.dueDate,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get isOverdue => !isCompleted && dueDate.isBefore(clock.now());

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.index,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    priority: Priority.values[json['priority']],
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'] ?? false,
  );
}
