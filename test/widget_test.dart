// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart'; 
import 'package:task_manager/widgets/task_tile.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  final testTask = Task(
    id: 't1',
    title: 'Complete Flutter Exercise',
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    isCompleted: false,
  );
  // GROUP 1: TaskTile Rendering (4 tests)
  group('TaskTile — Rendering', () {
    
    testWidgets('displays title text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // Finding by text and by key as defined in the source [cite: 38, 148]
      expect(find.text('Complete Flutter Exercise'), findsOneWidget);
      expect(find.byKey(const Key('title_t1')), findsOneWidget);
    });

    testWidgets('shows priority label in subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // The widget uses task.priority.name.toUpperCase() [cite: 153]
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('renders checkbox reflecting isCompleted false', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask.copyWith(isCompleted: false),
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // Verify checkbox state using the defined key [cite: 143, 144]
      final checkboxFinder = find.byKey(const Key('checkbox_t1'));
      final checkbox = tester.widget<Checkbox>(checkboxFinder);
      
      expect(checkbox.value, isFalse);
    });

    testWidgets('displays delete icon in trailing', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // Verify the Icon exists within the IconButton trailing widget [cite: 155, 156]
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byKey(const Key('delete_t1')), findsOneWidget);
    });
  });


  // GROUP 2: TaskTile — Checkbox Interaction (2 tests)
  group('TaskTile — Checkbox Interaction', () {
    testWidgets('should call onToggle exactly once when checkbox is tapped', (WidgetTester tester) async {
      int toggleCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () => toggleCount++,
            onDelete: () {},
          ),
        ),
      ));

      await tester.tap(find.byType(Checkbox));
      await tester.pump(); // Re-render after interaction [cite: 40]

      expect(toggleCount, equals(1));
    });

    testWidgets('should call onToggle when the checkbox is tapped using its unique Key', (WidgetTester tester) async {
      int toggleCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () => toggleCount++,
            onDelete: () {},
          ),
        ),
      ));

      // Finds the checkbox using the Key defined in task_tile.dart 
      final checkboxFinder = find.byKey(Key('checkbox_${testTask.id}'));
      
      await tester.tap(checkboxFinder);
      await tester.pump(); 

      expect(toggleCount, equals(1));
    });
  });

  // GROUP 3: TaskTile — Delete Interaction (2 tests)
  group('TaskTile — Delete Interaction', () {
    
    // 1. Find by Icon
    testWidgets('should call onDelete when the delete icon is tapped', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () => deleteCalled = true,
          ),
        ),
      ));

      // Find the button using the delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(deleteCalled, isTrue, reason: 'The onDelete callback should be triggered on tap');
    });

    // 2. Find by Key (Ensures specific interaction and "Appropriate finders" points)
    testWidgets('should call onDelete exactly once using the specific delete Key', (WidgetTester tester) async {
      int deleteCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () => deleteCount++,
          ),
        ),
      ));

      // Find the specific button using the Key defined in the TaskTile source: Key('delete_$id')
      final deleteKey = Key('delete_${testTask.id}');
      await tester.tap(find.byKey(deleteKey));
      await tester.pump();

      expect(deleteCount, equals(1), reason: 'The callback must be executed exactly once');
    });
  });

  // GROUP 4: TaskTile — Completed State UI (2 tests)
  group('TaskTile — Completed State UI', () {
    
    testWidgets('should apply line-through decoration when task is completed', (WidgetTester tester) async {
      final completedTask = testTask.copyWith(isCompleted: true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: completedTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // Finds the text widget by a specific Key 'title_t1'
      final titleTextFinder = find.byKey(const Key('title_t1'));
      final textWidget = tester.widget<Text>(titleTextFinder);

      // Verifies the decoration if it is lineThrough
      expect(textWidget.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('should have no text decoration when task is active (not completed)', (WidgetTester tester) async {
      final activeTask = testTask.copyWith(isCompleted: false);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: activeTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      final titleTextFinder = find.byKey(const Key('title_t1'));
      final textWidget = tester.widget<Text>(titleTextFinder);

      // Verifies if the decoration is either null or TextDecoration.none
      expect(textWidget.style?.decoration, equals(TextDecoration.none));
    });
  });

  // GROUP 5: TaskTile — Key Assertions (2 tests)
  group('TaskTile — Key Assertions', () {
    
    testWidgets('should have a ValueKey that matches the task ID', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            key: ValueKey(testTask.id),
            task: testTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // Fix: Find the TaskTile by type first, then verify its key property
      final taskTileFinder = find.byType(TaskTile);
      final taskTile = tester.widget<TaskTile>(taskTileFinder);
      
      expect(taskTile.key, equals(ValueKey(testTask.id)));
    });

    testWidgets('should have correct keys for checkbox and delete button components', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: testTask,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      ));

      // These sub-elements usually don't have duplicate keys, 
      // so find.byKey works safely here.
      final checkboxKey = Key('checkbox_${testTask.id}');
      expect(find.byKey(checkboxKey), findsOneWidget);

      final deleteKey = Key('delete_${testTask.id}');
      expect(find.byKey(deleteKey), findsOneWidget);
    });
  });
}
