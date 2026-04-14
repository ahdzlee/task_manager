import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

void main() {
  // ─── Helper factory ───────────────────────────────────────────────
  Task makeTask({
    String id = 't1',
    String title = 'Buy groceries',
    Priority priority = Priority.medium,
    DateTime? dueDate,
    bool isCompleted = false,
  }) {
    return Task(
      id: id,
      title: title,
      priority: priority,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
      isCompleted: isCompleted,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // GROUP 1: Task Model — Constructor & Properties
  // ─────────────────────────────────────────────────────────────────
  group('Task Model — Constructor & Properties', () {
    test('stores id and title correctly', () {
      final task = makeTask(id: 'abcd', title: 'Walk the cat');
      expect(task.id, equals('abcd'));
      expect(task.title, equals('Walk the cat'));
    });

    test('defaults isCompleted to false', () {
      final task = makeTask();
      expect(task.isCompleted, isFalse);
    });

    test('defaults priority to medium when not specified', () {
      final task = makeTask();
      expect(task.priority, equals(Priority.medium));
    });

    test('stores assigned priority correctly', () {
      final task = makeTask(priority: Priority.high);
      expect(task.priority, equals(Priority.high));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 2: Task Model — copyWith()
  // ─────────────────────────────────────────────────────────────────
  group('Task Model — copyWith()', () {
    late Task original;
    setUp(() {
      original = makeTask(title: 'Original title', isCompleted: false);
    });

    test('returns new task with updated title only', () {
      final updated = original.copyWith(title: 'New title');
      expect(updated.title, equals('New title'));
      expect(updated.isCompleted, equals(original.isCompleted));
    });

    test('original task is not mutated after copyWith', () {
      original.copyWith(title: 'Different');
      expect(original.title, equals('Original title'));
    });

    test('can update multiple fields simultaneously', () {
      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
        priority: Priority.high,
      );
      expect(updated.title, equals('Updated'));
      expect(updated.isCompleted, isTrue);
      expect(updated.priority, equals(Priority.high));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 3: Task Model — isOverdue getter
  // ─────────────────────────────────────────────────────────────────
  group('Task Model — isOverdue getter', () {
    test(
      'returns true when task is incomplete and due date is in the past',
      () {
        final task = makeTask(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: false,
        );
        expect(task.isOverdue, isTrue);
      },
    );

    test('returns false when due date is in the future', () {
      final task = makeTask(
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isCompleted: false,
      );
      expect(task.isOverdue, isFalse);
    });

    test('returns false when task is completed even if past due', () {
      final task = makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        isCompleted: true,
      );
      expect(task.isOverdue, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 4: Task Model — toJson() / fromJson()
  // ─────────────────────────────────────────────────────────────────
  group('Task Model — toJson() / fromJson()', () {
    late Task task;
    setUp(() {
      task = makeTask(
        id: 'j1',
        title: 'JSON task',
        priority: Priority.high,
        dueDate: DateTime(2025, 6, 15),
        isCompleted: true,
      );
    });

    test('toJson produces correct key-value pairs', () {
      final json = task.toJson();
      expect(json['id'], equals('j1'));
      expect(json['title'], equals('JSON task'));
      expect(json['isCompleted'], isTrue);
      expect(json['priority'], equals(Priority.high.index));
    });

    test('fromJson reconstructs task with identical fields', () {
      final json = task.toJson();
      final rebuilt = Task.fromJson(json);
      expect(rebuilt.id, equals(task.id));
      expect(rebuilt.title, equals(task.title));
      expect(rebuilt.priority, equals(task.priority));
      expect(rebuilt.isCompleted, equals(task.isCompleted));
    });

    test('round-trip serialization preserves dueDate', () {
      final json = task.toJson();
      final rebuilt = Task.fromJson(json);
      expect(
        rebuilt.dueDate.toIso8601String(),
        equals(task.dueDate.toIso8601String()),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 5–11: TaskService Tests
  // ─────────────────────────────────────────────────────────────────
  group('TaskService — addTask()', () {
    late TaskService service;
    setUp(() => service = TaskService());

    test('adds a valid task to the list', () {
      service.addTask(makeTask(id: '1', title: 'Valid task'));
      expect(service.allTasks.length, equals(1));
      expect(service.allTasks.first.title, equals('Valid task'));
    });

    test('throws ArgumentError when title is empty', () {
      expect(
        () => service.addTask(makeTask(title: '')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when title is only whitespace', () {
      expect(
        () => service.addTask(makeTask(title: '   ')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('TaskService — deleteTask()', () {
    late TaskService service;
    setUp(() {
      service = TaskService();
      service.addTask(makeTask(id: 'del1'));
    });

    test('removes a task by id', () {
      service.deleteTask('del1');
      expect(service.allTasks, isEmpty);
    });

    test('does nothing silently when id does not exist', () {
      service.deleteTask('nonexistent');
      expect(service.allTasks.length, equals(1));
    });
  });

  group('TaskService — toggleComplete()', () {
    late TaskService service;
    setUp(() {
      service = TaskService();
      service.addTask(makeTask(id: 'tog1', isCompleted: false));
    });

    test('marks an incomplete task as complete', () {
      service.toggleComplete('tog1');
      expect(service.allTasks.first.isCompleted, isTrue);
    });

    test('marks a complete task as incomplete', () {
      service.toggleComplete('tog1'); // now complete
      service.toggleComplete('tog1'); // back to incomplete
      expect(service.allTasks.first.isCompleted, isFalse);
    });

    test('throws StateError for unknown task id', () {
      expect(() => service.toggleComplete('ghost'), throwsA(isA<StateError>()));
    });
  });

  group('TaskService — getByStatus()', () {
    late TaskService service;
    setUp(() {
      service = TaskService();
      service.addTask(
        makeTask(id: 'a1', title: 'Active 1', isCompleted: false),
      );
      service.addTask(
        makeTask(id: 'a2', title: 'Active 2', isCompleted: false),
      );
      service.addTask(makeTask(id: 'c1', title: 'Done 1', isCompleted: true));
    });

    test('returns only active tasks when completed: false', () {
      final result = service.getByStatus(completed: false);
      expect(result.length, equals(2));
      expect(result.every((t) => !t.isCompleted), isTrue);
    });

    test('returns only completed tasks when completed: true', () {
      final result = service.getByStatus(completed: true);
      expect(result.length, equals(1));
      expect(result.first.id, equals('c1'));
    });
  });

  group('TaskService — sortByPriority()', () {
    late TaskService service;
    setUp(() {
      service = TaskService();
      service.addTask(makeTask(id: 'low', priority: Priority.low));
      service.addTask(makeTask(id: 'high', priority: Priority.high));
      service.addTask(makeTask(id: 'med', priority: Priority.medium));
    });

    test('returns tasks in descending priority order (high first)', () {
      final sorted = service.sortByPriority();
      expect(sorted[0].priority, equals(Priority.high));
      expect(sorted[1].priority, equals(Priority.medium));
      expect(sorted[2].priority, equals(Priority.low));
    });

    test('sortByPriority does not mutate the original list', () {
      final originalFirst = service.allTasks.first.id;
      service.sortByPriority();
      expect(service.allTasks.first.id, equals(originalFirst));
    });
  });

  group('TaskService — sortByDueDate()', () {
    late TaskService service;
    final now = DateTime.now();
    setUp(() {
      service = TaskService();
      service.addTask(
        makeTask(id: 'far', dueDate: now.add(const Duration(days: 30))),
      );
      service.addTask(
        makeTask(id: 'near', dueDate: now.add(const Duration(days: 1))),
      );
      service.addTask(
        makeTask(id: 'mid', dueDate: now.add(const Duration(days: 10))),
      );
    });

    test('returns tasks sorted by earliest due date first', () {
      final sorted = service.sortByDueDate();
      expect(sorted[0].id, equals('near'));
      expect(sorted[2].id, equals('far'));
    });

    test('sortByDueDate does not mutate the original list', () {
      final originalFirst = service.allTasks.first.id;
      service.sortByDueDate();
      expect(service.allTasks.first.id, equals(originalFirst));
    });
  });

  group('TaskService — statistics getter', () {
    late TaskService service;
    setUp(() => service = TaskService());

    test('returns zeros when service has no tasks', () {
      expect(service.statistics['total'], equals(0));
      expect(service.statistics['completed'], equals(0));
      expect(service.statistics['overdue'], equals(0));
    });

    test('counts total, completed and active correctly', () {
      service.addTask(makeTask(id: 's1', isCompleted: false));
      service.addTask(makeTask(id: 's2', isCompleted: true));
      service.addTask(makeTask(id: 's3', isCompleted: true));
      expect(service.statistics['total'], equals(3));
      expect(service.statistics['completed'], equals(2));
    });

    test('counts overdue tasks accurately (incomplete + past due)', () {
      service.addTask(
        makeTask(
          id: 'ov1',
          isCompleted: false,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
      service.addTask(
        makeTask(
          id: 'ov2',
          isCompleted: true, // completed — NOT overdue
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
      service.addTask(
        makeTask(
          id: 'ov3',
          isCompleted: false, // future — NOT overdue
          dueDate: DateTime.now().add(const Duration(days: 5)),
        ),
      );
      expect(service.statistics['overdue'], equals(1));
    });
  });
}
