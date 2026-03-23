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

void main() {

  late Task task;

  setUp(() {
    task = Task(
      id: '1',
      title: 'Test Task',
      priority: Priority.high,
      dueDate: DateTime.now(),
    );
  });

  Widget createWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('TaskTile — Rendering', () {

    testWidgets('title displayed', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('priority label shown', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('checkbox reflects completion state', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('delete icon present', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  group('TaskTile — Checkbox Interaction', () {

    testWidgets('onToggle called on tap', (tester) async {

      bool called = false;

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () { called = true; },
            onDelete: () {},
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onToggle called exactly once', (tester) async {

      int count = 0;

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () { count++; },
            onDelete: () {},
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(count, equals(1));
    });
  });

  group('TaskTile — Delete Interaction', () {

    testWidgets('onDelete called on tap', (tester) async {

      bool called = false;

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () { called = true; },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onDelete called once', (tester) async {

      int count = 0;

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () { count++; },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(count, equals(1));
    });
  });

  group('TaskTile — Completed State UI', () {

    testWidgets('lineThrough when completed', (tester) async {

      final completed = task.copyWith(isCompleted: true);

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: completed,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test Task'));

      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('no decoration when active', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test Task'));

      expect(text.style?.decoration, TextDecoration.none);
    });
  });

  group('TaskTile — Key Assertions', () {

    testWidgets('ValueKey matches task id', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.byKey(ValueKey('1')), findsOneWidget);
    });

    testWidgets('checkbox and delete keys exist', (tester) async {

      await tester.pumpWidget(
        createWidget(
          TaskTile(
            task: task,
            onToggle: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.byKey(Key('checkbox_1')), findsOneWidget);
      expect(find.byKey(Key('delete_1')), findsOneWidget);
    });
  });

}
