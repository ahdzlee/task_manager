import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

void main() {
  // ─── Named Constants for Testing ───────────────────────────────────
  /// Future due date for testing pending tasks (reduces flakiness)
  final defaultFutureDate = DateTime.now().add(const Duration(days: 7));
  
  /// Past due date for testing overdue scenarios
  final pastDueDate = DateTime.now().subtract(const Duration(days: 3));
  
  /// Today's date for boundary testing
  final todayDate = DateTime.now();
  
  const String testTitle = 'Buy groceries';
  const String testId = 't1';
  const String emptyString = '';
  const String whitespaceString = '   ';

  // ─── Helper factory ───────────────────────────────────────────────
  /// Factory function for creating test tasks with sensible defaults.
  /// Reduces code duplication and makes tests more maintainable.
  /// Supports partial overrides for focused test scenarios.
  Task makeTask({
    String id = testId,
    String title = testTitle,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    bool isCompleted = false,
  }) {
    return Task(
      id: id,
      title: title,
      priority: priority,
      dueDate: dueDate ?? defaultFutureDate,
      isCompleted: isCompleted,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // GROUP 1: Task Model — Constructor & Properties
  // Tests: Default value initialization, field storage correctness
  // Edge Cases: Verify immutability, type safety, valid state transitions
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
    
    /// Edge case: Verify all three priority levels work correctly
    test('correctly stores all priority levels', () {
      final lowTask = makeTask(priority: Priority.low);
      final mediumTask = makeTask(priority: Priority.medium);
      final highTask = makeTask(priority: Priority.high);
      
      expect(lowTask.priority, equals(Priority.low));
      expect(mediumTask.priority, equals(Priority.medium));
      expect(highTask.priority, equals(Priority.high));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 2: Task Model — copyWith()
  // Tests: Immutability guarantees, field-level updates, identity checks
  // Edge Cases: Partial updates, null coalescing, nested data preservation
  // Performance: copyWith() should create new instance, not modify original
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
    
    /// Advanced pattern: Verify copyWith returns a distinct object
    /// This is critical for immutability patterns used in state management
    test('creates a new Task instance (identity check)', () {
      final updated = original.copyWith(title: 'Same');
      expect(identical(updated, original), isFalse);
    });
    
    /// Edge case: Updating with same values should still create new instance
    test('creates new instance even when no changes provided', () {
      final copy = original.copyWith();
      expect(identical(copy, original), isFalse);
      expect(copy.id, equals(original.id));
      expect(copy.title, equals(original.title));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 3: Task Model — isOverdue getter
  // Tests: Overdue logic correctness, completion state interactions
  // Edge Cases: Boundary dates (today, yesterday, tomorrow), timezone safety
  // Business Logic: Completed tasks are never overdue regardless of date
  // Production Pattern: Uses clock.now() injection to prevent flakiness
  // ─────────────────────────────────────────────────────────────────
  group('Task Model — isOverdue getter (Time Injected)', () {
    // We freeze time to exactly Jan 1, 2026, 12:00 PM for predictable testing
    final fixedNow = DateTime(2026, 1, 1, 12, 0);

    test(
      'returns true when task is incomplete and due date is in the past',
      () {
        withClock(Clock.fixed(fixedNow), () {
          final task = makeTask(
            dueDate: fixedNow.subtract(const Duration(days: 1)),
            isCompleted: false,
          );
          expect(task.isOverdue, isTrue);
        });
      },
    );

    test('returns false when due date is in the future', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow.add(const Duration(days: 5)),
          isCompleted: false,
        );
        expect(task.isOverdue, isFalse);
      });
    });

    test('returns false when task is completed even if past due', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow.subtract(const Duration(days: 3)),
          isCompleted: true,
        );
        expect(task.isOverdue, isFalse);
      });
    });
    
    /// Edge case: Boundary testing - task due far in future
    /// Verify incomplete future task is never overdue
    test('returns false when due date is far in future', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow.add(const Duration(days: 365)),
          isCompleted: false,
        );
        expect(task.isOverdue, isFalse);
      });
    });
    
    /// Advanced case: Recently completed tasks should not be overdue
    test('returns false for recently completed overdue task', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow.subtract(const Duration(days: 3)),
          isCompleted: true, // Just completed
        );
        expect(task.isOverdue, isFalse);
      });
    });
    
    /// Advanced case: Extremely precise boundary condition testing
    test('returns false exactly AT the due date millisecond', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow,  // Due exactly right now
          isCompleted: false,
        );
        expect(task.isOverdue, isFalse); // isBefore is strictly less-than
      });
    });
    
    test('returns true 1 millisecond past the due date', () {
      withClock(Clock.fixed(fixedNow), () {
        final task = makeTask(
          dueDate: fixedNow.subtract(const Duration(milliseconds: 1)),
          isCompleted: false,
        );
        expect(task.isOverdue, isTrue); 
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 4: Task Model — toJson() / fromJson()
  // Tests: Serialization round-trip, type preservation, data integrity
  // Edge Cases: All priority levels, boolean states, date precision
  // Performance: JSON operations should preserve all data without loss
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
    
    /// Advanced pattern: Verify JSON structure is correct
    /// Ensures API compatibility and prevents accidental schema changes
    test('JSON contains all required keys for API compatibility', () {
      final json = task.toJson();
      final requiredKeys = ['id', 'title', 'description', 'priority', 'dueDate', 'isCompleted'];
      for (final key in requiredKeys) {
        expect(json.containsKey(key), isTrue,
          reason: 'Missing required key: $key');
      }
    });
    
    /// Edge case: Test with low priority (index 0) to catch off-by-one errors
    test('correctly serializes all priority levels', () {
      for (final priority in Priority.values) {
        final testTask = makeTask(priority: priority);
        final json = testTask.toJson();
        final rebuilt = Task.fromJson(json);
        expect(rebuilt.priority, equals(priority),
          reason: 'Failed for priority: $priority');
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 5–11: TaskService Tests
  // Tests: CRUD operations, filtering, sorting, business logic
  // Pattern: Each test exercises one specific behavior
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
        () => service.addTask(makeTask(title: emptyString)),
        throwsA(isA<ArgumentError>().having(
          (e) => e.toString(),
          'error message',
          contains('title'),
        )),
      );
    });

    test('throws ArgumentError when title is only whitespace', () {
      expect(
        () => service.addTask(makeTask(title: whitespaceString)),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    /// Edge case: Multiple valid tasks can be added
    test('successfully adds multiple tasks sequentially', () {
      service.addTask(makeTask(id: 'a', title: 'Task A'));
      service.addTask(makeTask(id: 'b', title: 'Task B'));
      service.addTask(makeTask(id: 'c', title: 'Task C'));
      expect(service.allTasks.length, equals(3));
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
    
    /// Edge case: Deleting from empty service should not throw
    test('handles deletion gracefully on empty service', () {
      final emptyService = TaskService();
      expect(() => emptyService.deleteTask('any-id'), returnsNormally);
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
      expect(
        () => service.toggleComplete('ghost'),
        throwsA(isA<StateError>()),
      );
    });
    
    /// Advanced pattern: Verify toggle is idempotent over pairs
    test('returns to original state after two toggles', () {
      final original = service.allTasks.first.isCompleted;
      service.toggleComplete('tog1');
      service.toggleComplete('tog1');
      expect(service.allTasks.first.isCompleted, equals(original));
    });
    
    /// Edge case: Multiple toggles preserve other fields
    test('preserves all other fields when toggling completion', () {
      final before = service.allTasks.first;
      service.toggleComplete('tog1');
      final after = service.allTasks.first;
      
      expect(after.id, equals(before.id));
      expect(after.title, equals(before.title));
      expect(after.priority, equals(before.priority));
      expect(after.dueDate, equals(before.dueDate));
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
    
    /// Edge case: Filter with no matches
    test('returns empty list when no tasks match status', () {
      final service2 = TaskService();
      service2.addTask(makeTask(id: 'only', isCompleted: true));
      final active = service2.getByStatus(completed: false);
      expect(active, isEmpty);
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
    
    /// Edge case: Single task sort
    test('handles single-task list correctly', () {
      final single = TaskService();
      single.addTask(makeTask(priority: Priority.medium));
      final sorted = single.sortByPriority();
      expect(sorted.length, equals(1));
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
    
    /// Edge case: Tasks with same due date maintain relative order (stable sort)
    test('maintains relative order for tasks with identical due dates', () {
      final sameDay = now.add(const Duration(days: 5));
      final service2 = TaskService();
      service2.addTask(makeTask(id: 'first', dueDate: sameDay));
      service2.addTask(makeTask(id: 'second', dueDate: sameDay));
      
      final sorted = service2.sortByDueDate();
      // Both have same date, so original order should be preserved (stable)
      expect(sorted[0].id, equals('first'));
      expect(sorted[1].id, equals('second'));
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
    
    /// Advanced pattern: Statistics are computed live (not cached)
    /// Verify statistics update as tasks change
    test('statistics update dynamically as tasks are added', () {
      expect(service.statistics['total'], equals(0));
      
      service.addTask(makeTask(id: 'dyn1'));
      expect(service.statistics['total'], equals(1));
      
      service.addTask(makeTask(id: 'dyn2'));
      expect(service.statistics['total'], equals(2));
    });
    
    /// Edge case: Comprehensive statistics scenario
    test('accurately counts mixed task scenarios', () {
      // Add 3 incomplete, 2 complete
      service.addTask(makeTask(id: 't1', isCompleted: false));
      service.addTask(makeTask(id: 't2', isCompleted: false));
      service.addTask(makeTask(id: 't3', isCompleted: false));
      service.addTask(makeTask(id: 't4', isCompleted: true));
      service.addTask(makeTask(id: 't5', isCompleted: true));
      
      // Add 1 overdue incomplete
      service.addTask(makeTask(
        id: 'overdue',
        isCompleted: false,
        dueDate: pastDueDate,
      ));
      
      final stats = service.statistics;
      expect(stats['total'], equals(6));
      expect(stats['completed'], equals(2));
      expect(stats['overdue'], equals(1));
    });
  });
}
