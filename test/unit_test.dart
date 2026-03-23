import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

void main() {

  late TaskService service;
  late Task task1;
  late Task task2;
  late Task task3;

  setUp(() {
    service = TaskService();

    task1 = Task(
      id: '1',
      title: 'Task One',
      priority: Priority.high,
      dueDate: DateTime.now().add(Duration(days: 1)),
    );

    task2 = Task(
      id: '2',
      title: 'Task Two',
      priority: Priority.low,
      dueDate: DateTime.now().add(Duration(days: 3)),
    );

    task3 = Task(
      id: '3',
      title: 'Task Three',
      priority: Priority.medium,
      dueDate: DateTime.now().subtract(Duration(days: 1)),
    );
  });

  // =========================
  // Task Model Tests
  // =========================

  group('Task Model — Constructor & Properties', () {

    test('creates task with required fields', () {
      expect(task1.title, equals('Task One'));
    });

    test('default description is empty', () {
      expect(task1.description, equals(''));
    });

    test('priority assignment works', () {
      expect(task1.priority, equals(Priority.high));
    });

    test('dueDate stored correctly', () {
      expect(task1.dueDate, isNotNull);
    });
  });

  group('Task Model — copyWith()', () {

    test('updates title only', () {
      final updated = task1.copyWith(title: 'Updated');

      expect(updated.title, equals('Updated'));
      expect(updated.priority, equals(task1.priority));
    });

    test('full update works', () {
      final updated = task1.copyWith(
        title: 'New',
        description: 'Desc',
        priority: Priority.low,
      );

      expect(updated.title, equals('New'));
      expect(updated.description, equals('Desc'));
    });

    test('original task remains unchanged', () {
      final updated = task1.copyWith(title: 'Changed');

      expect(task1.title, equals('Task One'));
      expect(updated.title, equals('Changed'));
    });
  });

  group('Task Model — isOverdue getter', () {

    test('past date incomplete returns true', () {
      final overdue = task3;

      expect(overdue.isOverdue, isTrue);
    });

    test('future date returns false', () {
      expect(task1.isOverdue, isFalse);
    });

    test('completed task not overdue', () {
      final completed = task3.copyWith(isCompleted: true);

      expect(completed.isOverdue, isFalse);
    });
  });

  group('Task Model — toJson / fromJson', () {

    test('serialization round trip', () {
      final json = task1.toJson();
      final result = Task.fromJson(json);

      expect(result.title, equals(task1.title));
    });

    test('priority index mapping works', () {
      final json = task1.toJson();

      expect(json['priority'], equals(task1.priority.index));
    });

    test('field types preserved', () {
      final json = task1.toJson();

      expect(json['title'], isA<String>());
      expect(json['isCompleted'], isA<bool>());
    });
  });

  // =========================
  // TaskService Tests
  // =========================

  group('TaskService — addTask()', () {

    test('adds task successfully', () {
      service.addTask(task1);

      expect(service.allTasks.length, equals(1));
    });

    test('empty title throws error', () {
      final badTask = Task(
        id: '4',
        title: '',
        dueDate: DateTime.now(),
      );

      expect(() => service.addTask(badTask), throwsArgumentError);
    });

    test('duplicate IDs allowed', () {
      service.addTask(task1);
      service.addTask(task1);

      expect(service.allTasks.length, equals(2));
    });
  });

  group('TaskService — deleteTask()', () {

    test('delete existing task', () {
      service.addTask(task1);
      service.deleteTask('1');

      expect(service.allTasks.isEmpty, isTrue);
    });

    test('delete non existent task does nothing', () {
      service.deleteTask('999');

      expect(service.allTasks.length, equals(0));
    });
  });

  group('TaskService — toggleComplete()', () {

    test('false to true', () {
      service.addTask(task1);

      service.toggleComplete('1');

      expect(service.allTasks.first.isCompleted, isTrue);
    });

    test('true to false', () {
      service.addTask(task1.copyWith(isCompleted: true));

      service.toggleComplete('1');

      expect(service.allTasks.first.isCompleted, isFalse);
    });

    test('unknown id throws error', () {
      expect(() => service.toggleComplete('999'), throwsStateError);
    });
  });

  group('TaskService — getByStatus()', () {

    test('filter active tasks', () {
      service.addTask(task1);
      service.addTask(task1.copyWith(isCompleted: true));

      final result = service.getByStatus(completed: false);

      expect(result.length, equals(1));
    });

    test('filter completed tasks', () {
      service.addTask(task1.copyWith(isCompleted: true));

      final result = service.getByStatus(completed: true);

      expect(result.length, equals(1));
    });
  });

  group('TaskService — sortByPriority()', () {

    test('high priority first', () {
      service.addTask(task2);
      service.addTask(task1);

      final sorted = service.sortByPriority();

      expect(sorted.first.priority, equals(Priority.high));
    });

    test('original list unchanged', () {
      service.addTask(task1);
      service.addTask(task2);

      service.sortByPriority();

      expect(service.allTasks.length, equals(2));
    });
  });

  group('TaskService — sortByDueDate()', () {

    test('earliest first', () {
      service.addTask(task1);
      service.addTask(task2);

      final sorted = service.sortByDueDate();

      expect(sorted.first.dueDate.isBefore(sorted.last.dueDate), isTrue);
    });

    test('original list unchanged', () {
      service.addTask(task1);
      service.addTask(task2);

      service.sortByDueDate();

      expect(service.allTasks.length, equals(2));
    });
  });

  group('TaskService — statistics getter', () {

    test('empty stats', () {
      final stats = service.statistics;

      expect(stats['total'], equals(0));
    });

    test('mixed tasks count', () {
      service.addTask(task1);
      service.addTask(task1.copyWith(isCompleted: true));

      final stats = service.statistics;

      expect(stats['completed'], equals(1));
    });

    test('overdue count accuracy', () {
      service.addTask(task3);

      final stats = service.statistics;

      expect(stats['overdue'], equals(1));
    });
  });

}