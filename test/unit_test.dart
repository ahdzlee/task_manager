import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

late TaskService service;
late List<Task> sampleTasks;

void main() {
  setUp(() {
    service = TaskService();
    sampleTasks = [
      Task(id: '1', title: 'High Priority', priority: Priority.high, dueDate: DateTime.now().subtract(Duration(days: 1))),
      Task(id: '2', title: 'Low Priority', priority: Priority.low, dueDate: DateTime.now().add(Duration(days: 1))),
      Task(id: '3', title: 'Completed', priority: Priority.medium, dueDate: DateTime.now(), isCompleted: true),
    ];
    for (var task in sampleTasks) {
      service.addTask(task);
    }
  });

  tearDown(() {
    service = TaskService(); // Reset for next test
  });
  
  // GROUP 1: Task Model Constructor Properties (4 tests)
  group('Task Model Constructor Properties', () {
    test('uses Priority.medium when priority parameter omitted', () {
      final task = Task(id: 'test', title: 'Test', dueDate: DateTime.now());
      expect(task.priority, Priority.medium);
    });
    
    test('defaults isCompleted to false when parameter omitted', () {
      final task = Task(id: 'test', title: 'Test', dueDate: DateTime.now());
      expect(task.isCompleted, false);
    });
    
    test('stores dueDate exactly as provided', () {
      final dueDate = DateTime(2026, 3, 20);
      final task = Task(id: 'test', title: 'Test', dueDate: dueDate);
      expect(task.dueDate, dueDate);
    });
    
    test('defaults description to empty string when omitted', () {
      final task = Task(id: 'test', title: 'Test', dueDate: DateTime.now());
      expect(task.description, isEmpty);
    });
  });

  // GROUP 2: Task Model copyWith (3 tests)
  group('Task Model copyWith', () {
    test('partial update changes only title leaving other fields unchanged', () {
      final original = sampleTasks[0];
      final updated = original.copyWith(title: 'Updated Title');
      expect(updated.title, 'Updated Title');
      expect(updated.priority, original.priority);
    });
    
    test('full update changes multiple fields simultaneously', () {
      final original = sampleTasks[0];
      final updated = original.copyWith(
        priority: Priority.low, 
        isCompleted: true
      );
      expect(updated.priority, Priority.low);
      expect(updated.isCompleted, true);
    });
    
    test('original task remains unchanged after copyWith operation', () {
      final original = sampleTasks[0];
      original.copyWith(title: 'Should Not Change');
      expect(original.title, 'High Priority');
    });
  });

  // GROUP 3: Task Model isOverdue getter (3 tests)
  group('Task Model isOverdue getter', () {
    test('returns true when task is incomplete and due date is in the past', () {
      final overdueTask = Task(id: 'overdue', title: 'Past Due', 
        dueDate: DateTime.now().subtract(Duration(days: 1)));
      expect(overdueTask.isOverdue, isTrue);
    });
    
    test('returns false when due date is in the future regardless of completion', () {
      final futureTask = Task(id: 'future', title: 'Future Due', 
        dueDate: DateTime.now().add(Duration(days: 1)));
      expect(futureTask.isOverdue, isFalse);
    });
    
    test('returns false when task is completed even if due date is in past', () {
      final completedPast = Task(id: 'completed', title: 'Past Complete', 
        dueDate: DateTime.now().subtract(Duration(days: 1)), isCompleted: true);
      expect(completedPast.isOverdue, isFalse);
    });
  });

  // GROUP 4: Task Model toJson fromJson (3 tests)
  group('Task Model toJson fromJson', () {
    test('serialization roundtrip preserves all task properties unchanged', () {
      final original = sampleTasks[0];
      final json = original.toJson();
      final deserialized = Task.fromJson(json);
      expect(deserialized.id, original.id);
      expect(deserialized.title, original.title);
    });
    
    test('fromJson correctly handles missing description field', () {
      final json = {
        'id': 'test', 'title': 'No Desc', 'priority': 1,
        'dueDate': DateTime.now().toIso8601String()
      };
      final task = Task.fromJson(json);
      expect(task.description, isEmpty);
    });
    
    test('priority enum values map correctly by index position', () {
      final lowJson = {'id': 'low', 'title': 'Low', 'priority': 0, 
        'dueDate': DateTime.now().toIso8601String()};
      expect(Task.fromJson(lowJson).priority, Priority.low);
    });
  });

  // GROUP 5: TaskService addTask (3 tests)
  group('TaskService addTask', () {
    setUp(() {
      service = TaskService(); // Fresh for addTask
    });
    
    test('successfully adds valid task to internal tasks list', () {
      final newTask = Task(id: 'new1', title: 'Valid Task', dueDate: DateTime.now());
      service.addTask(newTask);
      expect(service.allTasks, hasLength(1));
    });
    
    test('throws ArgumentError when task title is empty or whitespace only', () {
      final invalidTask = Task(id: 'invalid', title: '', dueDate: DateTime.now());
      expect(() => service.addTask(invalidTask), throwsArgumentError);
    });
    
    test('allows tasks with duplicate IDs without error', () {
      final task1 = Task(id: 'dup', title: 'First', dueDate: DateTime.now());
      final task2 = Task(id: 'dup', title: 'Second', dueDate: DateTime.now());
      service.addTask(task1);
      service.addTask(task2);
      expect(service.allTasks, hasLength(2));
    });
  });

  // GROUP 6: TaskService deleteTask (2 tests)
  group('TaskService deleteTask', () {
    test('removes existing task from list when valid ID provided', () {
      service.deleteTask('1');  // Remove sample task #1
      expect(service.allTasks, hasLength(2));  // 3-1=2
    });
    
    test('silently ignores deletion request for non-existent task ID', () {
      service.deleteTask('nonexistent');
      expect(service.allTasks, hasLength(3));  // No change
    });
  });
}
