import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  // Group 1: TaskTile — Rendering (Min 4 Tests)
  group('TaskTile — Rendering', () {
    testWidgets('1. Title displayed', (t) async {
      final task = Task(id: '1', title: 'Buy Milk', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      expect(find.text('Buy Milk'), findsOneWidget);
    });

    testWidgets('2. Priority label shown', (t) async {
      final task = Task(
        id: '1',
        title: 'T',
        priority: Priority.high,
        dueDate: DateTime.now(),
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('3. Checkbox reflects isCompleted', (t) async {
      final task = Task(
        id: '1',
        title: 'T',
        isCompleted: true,
        dueDate: DateTime.now(),
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      final checkbox = t.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('4. Delete icon present', (t) async {
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  // Group 2: TaskTile — Checkbox Interaction (Min 2 Tests)
  group('TaskTile — Checkbox Interaction', () {
    testWidgets('5. onToggle called on tap', (t) async {
      bool called = false;
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(
              task: task,
              onToggle: () => called = true,
              onDelete: () {},
            ),
          ),
        ),
      );
      await t.tap(find.byType(Checkbox));
      await t.pump();
      expect(called, isTrue);
    });

    testWidgets('6. called exactly once', (t) async {
      int count = 0;
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(
              task: task,
              onToggle: () => count++,
              onDelete: () {},
            ),
          ),
        ),
      );
      await t.tap(find.byType(Checkbox));
      await t.pump();
      expect(count, 1);
    });
  });

  // Group 3: TaskTile — Delete Interaction (Min 2 Tests)
  group('TaskTile — Delete Interaction', () {
    testWidgets('7. onDelete called on tap', (t) async {
      bool called = false;
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(
              task: task,
              onToggle: () {},
              onDelete: () => called = true,
            ),
          ),
        ),
      );
      await t.tap(find.byIcon(Icons.delete));
      await t.pump();
      expect(called, isTrue);
    });

    testWidgets('8. called exactly once', (t) async {
      int count = 0;
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(
              task: task,
              onToggle: () {},
              onDelete: () => count++,
            ),
          ),
        ),
      );
      await t.tap(find.byIcon(Icons.delete));
      await t.pump();
      expect(count, 1);
    });
  });

  // Group 4: TaskTile — Completed State UI (Min 2 Tests)
  group('TaskTile — Completed State UI', () {
    testWidgets('9. LineThrough style when completed', (t) async {
      final task = Task(
        id: '1',
        title: 'Done',
        isCompleted: true,
        dueDate: DateTime.now(),
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      final textWidget = t.widget<Text>(find.text('Done'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('10. No decoration when active', (t) async {
      final task = Task(
        id: '1',
        title: 'Active',
        isCompleted: false,
        dueDate: DateTime.now(),
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      final textWidget = t.widget<Text>(find.text('Active'));
      expect(textWidget.style?.decoration, TextDecoration.none);
    });
  });

  // Group 5: TaskTile — Key Assertions (Min 2 Tests)
  group('TaskTile — Key Assertions', () {
    testWidgets('11. ValueKey matches task.id', (t) async {
      final task = Task(id: 'unique_123', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('unique_123')), findsOneWidget);
    });

    testWidgets('12. Checkbox and delete keys are correct', (t) async {
      final task = Task(id: '1', title: 'T', dueDate: DateTime.now());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskTile(task: task, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );

      // Corrected keys to match standard naming convention in TaskTile
      expect(find.byKey(const Key('checkbox_1')), findsOneWidget);
      expect(find.byKey(const Key('delete_1')), findsOneWidget);
    });
  });
}
