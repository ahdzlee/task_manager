import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  // ─── Helper: build TaskTile in a test harness ──────────────────
  Widget buildTile({
    required Task task,
    VoidCallback? onToggle,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TaskTile(
          task: task,
          onToggle: onToggle ?? () {},
          onDelete: onDelete ?? () {},
        ),
      ),
    );
  }

  Task sampleTask({bool isCompleted = false}) => Task(
    id: 'w1',
    title: 'Buy groceries',
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    isCompleted: isCompleted,
  );

  // ─────────────────────────────────────────────────────────────────
  // GROUP 1: TaskTile — Rendering
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Rendering', () {
    testWidgets('displays the task title text', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.text('Buy groceries'), findsOneWidget);
    });

    testWidgets('displays priority label as uppercase subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('checkbox value matches task isCompleted (false)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: false)));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('delete icon button is present', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 2: TaskTile — Checkbox Interaction
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Checkbox Interaction', () {
    testWidgets('calls onToggle callback when checkbox is tapped', (
      tester,
    ) async {
      bool toggled = false;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onToggle: () => toggled = true),
      );
      await tester.tap(find.byKey(const Key('checkbox_w1')));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('onToggle is called exactly once per tap', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onToggle: () => count++),
      );
      await tester.tap(find.byKey(const Key('checkbox_w1')));
      await tester.pump();
      expect(count, equals(1));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 3: TaskTile — Delete Interaction
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Delete Interaction', () {
    testWidgets('calls onDelete when delete icon button is tapped', (
      tester,
    ) async {
      bool deleted = false;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onDelete: () => deleted = true),
      );
      await tester.tap(find.byKey(const Key('delete_w1')));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('onDelete is called exactly once per tap', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onDelete: () => count++),
      );
      await tester.tap(find.byKey(const Key('delete_w1')));
      await tester.pump();
      expect(count, equals(1));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 4: TaskTile — Completed State UI
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Completed State UI', () {
    testWidgets('title has lineThrough decoration when task is completed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: true)));
      final text = tester.widget<Text>(find.byKey(const Key('title_w1')));
      expect(text.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('title has no decoration when task is active', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: false)));
      final text = tester.widget<Text>(find.byKey(const Key('title_w1')));
      expect(text.style?.decoration, equals(TextDecoration.none));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 5: TaskTile — Key Assertions
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Key Assertions', () {
    testWidgets('ListTile has ValueKey matching task.id', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.byKey(const ValueKey('w1')), findsOneWidget);
    });

    testWidgets('Checkbox key follows naming convention checkbox_{id}', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.byKey(const Key('checkbox_w1')), findsOneWidget);
    });
  });
}
