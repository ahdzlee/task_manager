import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

@GenerateMocks([TaskService])
import 'unit_test.mocks.dart';

void main() {
  late TaskService taskService;
  late MockTaskService mockService;

  setUp(() {
    taskService = TaskService();
    mockService = MockTaskService();
  });

  // Group: Dependency Isolation (2 Tests)
  group('TaskService - Mocking', () {
    test('verify service interaction using mockito', () {
      final task = Task(id: '1', title: 'Mock', dueDate: DateTime.now());
      when(mockService.allTasks).thenReturn([task]);
      expect(mockService.allTasks.length, 1);
      verify(mockService.allTasks).called(1);
    });

    test('verify addTask interaction using mock', () {
      final task = Task(id: '2', title: 'New', dueDate: DateTime.now());
      mockService.addTask(task);
      verify(mockService.addTask(task)).called(1);
    });
  });

  // Group 1: Constructor (5 Tests)
  group('Task Model - Constructor & Properties', () {
    final now = DateTime.now();
    final task = Task(
      id: '1',
      title: 'Test',
      description: 'Desc',
      dueDate: now,
    );
    test(
      'default isCompleted is false',
      () => expect(task.isCompleted, isFalse),
    );
    test('assigns correct id', () => expect(task.id, '1'));
    test('assigns correct title', () => expect(task.title, 'Test'));
    test('assigns correct description', () => expect(task.description, 'Desc'));
    test('stores dueDate correctly', () => expect(task.dueDate, now));
  });

  // Group 2: isOverdue Logic (3 Tests)
  group('Task Model - isOverdue Logic', () {
    test('returns true for past date', () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.isOverdue, isTrue);
    });
    test('returns false for future date', () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(task.isOverdue, isFalse);
    });
    test('completed tasks are never overdue', () {
      final task = Task(
        id: '1',
        title: 'T',
        isCompleted: true,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.isOverdue, isFalse);
    });
  });

  // Group 3: addTask (2 Tests)
  group('TaskService - addTask()', () {
    test('adds task to list', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      expect(taskService.allTasks.length, 1);
    });
    test('throws exception for empty title', () {
      final task = Task(id: '1', title: '', dueDate: DateTime.now());
      expect(() => taskService.addTask(task), throwsArgumentError);
    });
  });

  // Group 4: toggleComplete (2 Tests)
  group('TaskService - toggleComplete()', () {
    test('flips completion status', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      taskService.toggleComplete('1');
      expect(taskService.allTasks.first.isCompleted, isTrue);
    });
    test('throws StateError for unknown ID', () {
      expect(() => taskService.toggleComplete('999'), throwsStateError);
    });
  });

  // Group 5: deleteTask (2 Tests)
  group('TaskService - deleteTask()', () {
    test('removes task from list', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      taskService.deleteTask('1');
      expect(taskService.allTasks, isEmpty);
    });
    test('handles non-existent ID gracefully', () {
      expect(() => taskService.deleteTask('non_existent'), returnsNormally);
      expect(taskService.allTasks.length, 0);
    });
  });

  // Group 6: getByStatus (4 Tests)
  group('TaskService - getByStatus()', () {
    setUp(() {
      taskService.addTask(
        Task(id: '1', title: 'A', isCompleted: false, dueDate: DateTime.now()),
      );
      taskService.addTask(
        Task(id: '2', title: 'C', isCompleted: true, dueDate: DateTime.now()),
      );
    });
    test(
      'returns only active',
      () => expect(taskService.getByStatus(completed: false).length, 1),
    );
    test(
      'returns only completed',
      () => expect(taskService.getByStatus(completed: true).length, 1),
    );
    test('returns empty if no tasks match status', () {
      taskService.deleteTask('2');
      expect(taskService.getByStatus(completed: true), isEmpty);
    });
    test(
      'allTasks getter returns both',
      () => expect(taskService.allTasks.length, 2),
    );
  });

  // Group 7: sortByPriority (2 Tests)
  group('TaskService - sortByPriority()', () {
    test('high priority comes first', () {
      taskService.addTask(
        Task(
          id: '1',
          title: 'L',
          priority: Priority.low,
          dueDate: DateTime.now(),
        ),
      );
      taskService.addTask(
        Task(
          id: '2',
          title: 'H',
          priority: Priority.high,
          dueDate: DateTime.now(),
        ),
      );
      expect(taskService.sortByPriority().first.priority, Priority.high);
    });
    test('immutability: original list is unchanged', () {
      taskService.addTask(
        Task(
          id: '1',
          title: 'L',
          priority: Priority.low,
          dueDate: DateTime.now(),
        ),
      );
      taskService.sortByPriority();
      expect(taskService.allTasks.first.priority, Priority.low);
    });
  });

  // Group 8: sortByDueDate (2 Tests)
  group('TaskService - sortByDueDate()', () {
    test('earliest first', () {
      taskService.addTask(Task(id: '1', title: 'L', dueDate: DateTime(2026)));
      taskService.addTask(Task(id: '2', title: 'S', dueDate: DateTime(2025)));
      expect(taskService.sortByDueDate().first.title, 'S');
    });
    test('original list unchanged', () {
      taskService.addTask(Task(id: '1', title: 'L', dueDate: DateTime(2026)));
      taskService.sortByDueDate();
      expect(taskService.allTasks.first.title, 'L');
    });
  });

  // Group 9: statistics (1 Test)
  group('TaskService - statistics getter', () {
    test('mixed tasks count', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      expect(taskService.statistics['total'], 1);
    });
  });

  // Group 10: statistics (1 Test)
  group('TaskService - statistics getter', () {
    test('completed count accuracy', () {
      taskService.addTask(
        Task(id: '1', title: 'T', isCompleted: true, dueDate: DateTime.now()),
      );
      expect(taskService.statistics['completed'], 1);
    });
  });

  // Group 11: statistics (4 Tests)
  group('TaskService - statistics getter', () {
    test('overdue count accuracy', () {
      taskService.addTask(
        Task(
          id: '1',
          title: 'T',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
      expect(taskService.statistics['overdue'], 1);
    });
    test('total reflects all additions', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      taskService.addTask(Task(id: '2', title: 'T', dueDate: DateTime.now()));
      expect(taskService.statistics['total'], 2);
    });
    test('completed reflects toggles', () {
      taskService.addTask(Task(id: '1', title: 'T', dueDate: DateTime.now()));
      taskService.toggleComplete('1');
      expect(taskService.statistics['completed'], 1);
    });
    test('returns zeros for stats on empty list', () {
      expect(taskService.statistics['total'], 0);
      expect(taskService.statistics['completed'], 0);
      expect(taskService.statistics['overdue'], 0);
    });
  });
}
