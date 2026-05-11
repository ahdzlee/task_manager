import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

class TestKeys {
  static Key checkbox(String id) => Key('checkbox_$id');
  static Key title(String id) => Key('title_$id');
  static Key delete(String id) => Key('delete_$id');
}

void main() {
  // ─── Named Constants for Widget Tests ──────────────────────────────
  /// Standard task ID used for widget testing
  const String widgetTestId = 'w1';
  
  /// Default task title for rendering tests
  const String widgetTestTitle = 'Buy groceries';

  // ─── Helper: build TaskTile in a test harness ──────────────────
  /// Wraps TaskTile in the necessary Material context (MaterialApp + Scaffold).
  /// This ensures the widget can access Material theming and scaffold context.
  /// Default callbacks prevent null reference errors in tests.
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

  /// Factory for creating sample tasks for widget tests.
  /// Uses consistent ID for key-based finder queries.
  Task sampleTask({bool isCompleted = false}) => Task(
    id: widgetTestId,
    title: widgetTestTitle,
    priority: Priority.high,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    isCompleted: isCompleted,
  );

  // ─────────────────────────────────────────────────────────────────
  // GROUP 1: TaskTile — Rendering
  // Tests: Widget rendering, content display, icon presence
  // Pattern: Verify UI components render according to task state
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Rendering', () {
    testWidgets('displays the task title text', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.text(widgetTestTitle), findsOneWidget);
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
    
    /// Advanced: Verify checkbox reflects completed state (true)
    testWidgets('checkbox value matches task isCompleted (true)', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: true)));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 2: TaskTile — Checkbox Interaction
  // Tests: Callback invocation, tap handling, event count verification
  // Pattern: Use counters/flags to verify callback behavior
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
    
    /// Advanced: Verify multiple taps invoke callback multiple times
    testWidgets('calls onToggle multiple times for multiple taps', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onToggle: () => count++),
      );
      
      // First tap
      await tester.tap(find.byKey(const Key('checkbox_w1')));
      await tester.pump();
      expect(count, equals(1));
      
      // Second tap
      await tester.tap(find.byKey(const Key('checkbox_w1')));
      await tester.pump();
      expect(count, equals(2));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 3: TaskTile — Delete Interaction
  // Tests: Delete button callback, tap handling, action verification
  // Pattern: Similar callback verification as checkbox tests
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
    
    /// Advanced: Verify delete button is accessible via IconButton finder
    testWidgets('delete action is accessible via IconButton widget', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        buildTile(task: sampleTask(), onDelete: () => count++),
      );
      
      // Find all IconButtons and tap the one with delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(count, equals(1));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 4: TaskTile — Completed State UI
  // Tests: Visual feedback for task completion status
  // Pattern: Inspect widget properties to verify UI state
  // Important: UI should reflect task state (visual feedback)
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
    
    /// Advanced: Verify the TextDecoration is properly applied via TextStyle
    testWidgets('completed tasks have proper text styling', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: true)));
      final text = tester.widget<Text>(find.byKey(const Key('title_w1')));
      
      // Verify style is not null and has decoration
      expect(text.style, isNotNull);
      expect(text.style?.decoration, isNotNull);
      expect(text.style?.decoration, equals(TextDecoration.lineThrough));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 5: TaskTile — Key Assertions
  // Tests: Widget key naming conventions, finder strategy correctness
  // Pattern: Ensures keys match documented conventions for UI testing
  // Important: Proper keys enable reliable widget finding in tests
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
      expect(find.byKey(TestKeys.checkbox('w1')), findsOneWidget);
    });
    
    /// Advanced: Verify delete button key convention
    testWidgets('Delete button key follows naming convention delete_{id}', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.byKey(TestKeys.delete('w1')), findsOneWidget);
    });
    
    /// Advanced: Verify title text key convention
    testWidgets('Title text key follows naming convention title_{id}', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      expect(find.byKey(TestKeys.title('w1')), findsOneWidget);
    });
    
    /// Advanced: Verify all expected keys are present
    testWidgets('all required widget keys are present', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask()));
      
      expect(find.byKey(const ValueKey('w1')), findsOneWidget, reason: 'ListTile key missing');
      expect(find.byKey(TestKeys.checkbox('w1')), findsOneWidget, reason: 'Checkbox key missing');
      expect(find.byKey(TestKeys.title('w1')), findsOneWidget, reason: 'Title key missing');
      expect(find.byKey(TestKeys.delete('w1')), findsOneWidget, reason: 'Delete button key missing');
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GROUP 6: Golden Testing 
  // Tests: Absolute visual fidelity
  // ─────────────────────────────────────────────────────────────────
  group('TaskTile — Visual Regressions (Goldens)', () {
    testWidgets('matches golden file for active state', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: false)));
      await expectLater(
        find.byType(TaskTile),
        matchesGoldenFile('goldens/task_tile_active.png'),
      );
    });

    testWidgets('matches golden file for completed state', (tester) async {
      await tester.pumpWidget(buildTile(task: sampleTask(isCompleted: true)));
      await expectLater(
        find.byType(TaskTile),
        matchesGoldenFile('goldens/task_tile_completed.png'),
      );
    });
  });
}
