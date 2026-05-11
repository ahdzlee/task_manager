import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/providers/task_provider.dart';

import 'provider_test.mocks.dart';

/// Generate mock class for TaskService using Mockito.
/// Requires running: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([TaskService])
void main() {
  late MockTaskService mockService;
  late TaskProvider provider;

  /// Helper to create dummy tasks for provider tests
  Task makeTestTask({String id = '1', bool isCompleted = false}) {
    return Task(
      id: id,
      title: 'Mock Task',
      priority: Priority.medium,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: isCompleted,
    );
  }

  setUp(() {
    mockService = MockTaskService();
    // Inject the mocked service into the provider
    provider = TaskProvider(service: mockService);
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 1: TaskProvider — Delegation & Notifications
  // Tests: Ensures business logic is delegated correctly to TaskService
  // Pattern: Mockito verify() and ChangeNotifier addListener() flags
  // ─────────────────────────────────────────────────────────────────
  group('TaskProvider — Delegation & Notifications', () {
    test('addTask delegates to TaskService and notifies listeners', () {
      final task = makeTestTask();
      bool notified = false;
      provider.addListener(() => notified = true);
      
      provider.addTask(task);
      
      // Verify the mock was called exactly once with the expected task
      verify(mockService.addTask(task)).called(1);
      // Verify listeners were notified to update UI
      expect(notified, isTrue);
    });

    test('deleteTask delegates to TaskService & triggers listener', () {
      bool notified = false;
      provider.addListener(() => notified = true);
      
      provider.deleteTask('id_123');
      
      verify(mockService.deleteTask('id_123')).called(1);
      expect(notified, isTrue);
    });

    test('toggleComplete delegates to TaskService & triggers listener', () {
      bool notified = false;
      provider.addListener(() => notified = true);
      
      provider.toggleComplete('id_123');
      
      verify(mockService.toggleComplete('id_123')).called(1);
      expect(notified, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 2: TaskProvider — State Management (Filters & Sorts)
  // Tests: UI state configurations are persisted and trigger rebuilds
  // ─────────────────────────────────────────────────────────────────
  group('TaskProvider — State Management (Filters & Sorts)', () {
    test('initializes with default filter (All) and SortMode (DueDate)', () {
      expect(provider.filter, equals(FilterStatus.all));
      expect(provider.sortMode, equals(SortMode.dueDate));
    });

    test('setFilter updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() => notified = true);
      
      provider.setFilter(FilterStatus.active);
      
      expect(provider.filter, equals(FilterStatus.active));
      expect(notified, isTrue);
    });

    test('setSortMode updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() => notified = true);
      
      provider.setSortMode(SortMode.priority);
      
      expect(provider.sortMode, equals(SortMode.priority));
      expect(notified, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 3: TaskProvider — Derived Data Retrieval
  // Tests: Complex getters properly chain service calls
  // ─────────────────────────────────────────────────────────────────
  group('TaskProvider — Derived Data Retrieval', () {
    test('statistics getter proxies accurately to TaskService', () {
      final mockStats = {'total': 5, 'completed': 2, 'overdue': 1};
      when(mockService.statistics).thenReturn(mockStats);
      
      expect(provider.statistics, equals(mockStats));
      verify(mockService.statistics).called(1);
    });
  });
}
