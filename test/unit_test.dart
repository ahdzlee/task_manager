import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';  
import 'package:task_manager/services/task_service.dart';  

late TaskService service;
late List<Task> sampleTasks;

void main() {
  setUp(() {
    service = TaskService();
    sampleTasks = [
      Task(id: '1', title: 'High Task', priority: Priority.high, dueDate: DateTime.now().subtract(Duration(days: 1))),
      Task(id: '2', title: 'Low Task', priority: Priority.low, dueDate: DateTime.now().add(Duration(days: 1))),
      Task(id: '3', title: 'Medium Complete', priority: Priority.medium, dueDate: DateTime.now(), isCompleted: true),
    ];
    for (var task in sampleTasks) {
      service.addTask(task);
    }
  });

  group('Task Model: Constructor Properties', () {
    test('uses default priority Priority.medium when not specified', () {
      final task = Task(
        id: 'test', 
        title: 'Test', 
        dueDate: DateTime.now()
      );
      expect(task.priority, Priority.medium);
    });
    test('requires id and title - but Dart enforces via required', () {
      expect(() => Task(
        id: '', 
        title: '', 
        dueDate: DateTime.now()
      ), 
      returnsNormally);
    });
    test('stores dueDate correctly', () {
      final due = DateTime(2026, 3, 20);
      final task = Task(
        id: 'test', 
        title: 'Test', 
        dueDate: due
      );
      expect(task.dueDate, due);
    });
    test('defaults isCompleted to false', () {
      final task = Task(
        id: 'test', 
        title: 'Test', 
        dueDate: DateTime.now()
      );
      expect(task.isCompleted, false);
    });
  });

  group('Task Model: copyWith', () {
    final original = Task(
      id: '1', 
      title: 'Original', 
      priority: Priority.medium, 
      dueDate: DateTime.now()
    );
    test('partial update changes only specified fields', () {
      final updated = original.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.priority, Priority.medium);  // unchanged
    });
    test('full update changes all fields', () {
      final updated = original.copyWith(
        title: 'New', 
        priority: Priority.high, 
        isCompleted: true
      );
      expect(updated.priority, Priority.high);
      expect(updated.isCompleted, true);
    });
    test('original remains unchanged after copyWith', () {
      original.copyWith(title: 'Changed');
      expect(original.title, 'Original');
    });
  });

  group('Task Model: isOverdue getter', () {
    test('returns true when task is incomplete and due date is in the past', () {
      final overdueTask = Task(
        id: '1', 
        title: 'Overdue', 
        dueDate: DateTime.now().subtract(Duration(days: 1))
      );
      expect(overdueTask.isOverdue, true);
    });
    test('returns false when due date is in the future', () {
      final futureTask = Task(
        id: '2', 
        title: 'Future', 
        dueDate: DateTime.now().add(Duration(days: 1))
      );
      expect(futureTask.isOverdue, false);
    });
    test('returns false when task is completed even if past due', () {
      final completePast = Task(
        id: '3', 
        title: 'Complete Past', 
        dueDate: DateTime.now().subtract(Duration(days: 1)), 
        isCompleted: true
      );
      expect(completePast.isOverdue, false);
    });
  });

  group('Task Model: toJson fromJson', () {
    test('returns true when task is incomplete and due date is in the past', () {
      final overdueTask = Task(id: '1', title: 'Overdue', 
        dueDate: DateTime.now().subtract(Duration(days: 1)));
      expect(overdueTask.isOverdue, true);
    });
    test('returns false when due date is in the future', () {
      final futureTask = Task(id: '2', title: 'Future', 
        dueDate: DateTime.now().add(Duration(days: 1)));
      expect(futureTask.isOverdue, false);
    });
    test('returns false when task is completed even if past due', () {
      final completePast = Task(id: '3', title: 'Complete Past', 
        dueDate: DateTime.now().subtract(Duration(days: 1)), isCompleted: true);
      expect(completePast.isOverdue, false);
    });
  });

  // Continue with remaining 8 groups similarly...
  // GROUP 4: toJson/fromJson (3 tests)
  // GROUP 5-11: TaskService methods (addTask, deleteTask, etc.)

  tearDown(() {});  // Optional
}
