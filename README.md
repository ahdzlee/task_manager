# 📱 Task Manager: Enterprise-Grade Flutter Testing Suite

This repository contains a Flutter Task Manager application designed to showcase **Mastery in Unit Testing, Widget Testing, and State Management Testing**. 

While originally an intermediate Flutter testing exercise, this application's test suite has been elevated to an **Enterprise/Production-Grade** standard, boasting 76 robust assertions spanning across multiple testing paradigms.

---

## ✨ Application Features

A fully functional Task Manager allowing users to:
- **Create** tasks with titles, descriptions, priorities (low/medium/high), and due dates.
- **Toggle** task completion status.
- **Filter** task lists by status (All / Active / Completed).
- **Sort** tasks by Priority or Due Date.
- **Delete** tasks.
- **Track** live statistics (Total, Completed, and Overdue tasks).

---

## 🧪 Testing Architecture

This project achieves a **100% pass rate** across 76 individual test cases, utilizing standard and advanced Flutter testing architectures:

### 1. Robust Unit Testing (`test/unit_test.dart`)
- **Factory Patterns:** Utilizes `makeTask()` to DRY up test arrangements.
- **Deterministic Time Injection:** Uses `package:clock` and `withClock()` to freeze time. This enables down-to-the-millisecond precision testing for `isOverdue` boundaries and completely eliminates pipeline flakiness.
- **Immutability Checks:** Verifies identity rules (`identical()` assertions) confirming mathematically that `copyWith()` methods return new memory allocations.
- **Advanced Matchers:** Implements deep constraint property checks (e.g., verifying `ArgumentError` text messages via `.having()`).

### 2. Comprehensive Widget Testing (`test/widget_test.dart`)
- **Visual Golden Tests:** Uses `matchesGoldenFile()` to capture and compare pixel-perfect visual snapshots of active and completed TaskTiles.
- **UI Key Abstraction:** Hardcoded string keys are avoided via a centralized `TestKeys` builder pattern for UI element querying.
- **Simulated Interactions:** Mocks user taps, multi-taps, and validates UI visual states (like `TextDecoration.lineThrough`).

### 3. Isolated State Management Testing (`test/provider_test.dart`)
- **Mockito Integration:** Employs `@GenerateMocks([TaskService])` to isolate the `ChangeNotifier` state manager from actual business logic.
- **Event Delegation:** Verifies the `TaskProvider` successfully proxies logic to the `TaskService` and accurately dispatches `notifyListeners()` for UI redraws.

---

## 🛠️ Project Structure

```text
lib/
├── models/task.dart              # Task domain model (with clock-injected getters)
├── services/task_service.dart    # Pure business logic and array manipulations
├── providers/task_provider.dart  # UI State Management (ChangeNotifier)
├── screens/task_list_screen.dart # Main interactive UI screen
├── screens/add_task_screen.dart  # Form validation and input handling
└── widgets/task_tile.dart        # Individual, tappable task representations

test/
├── unit_test.dart                # Deep logic, model boundaries, and edge cases
├── widget_test.dart              # UI interactions, Golden visual tests, TestKeys
└── provider_test.dart            # Mocked provider/service interactions
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Mocks (Mockito)
Before running tests, ensure you build the mock classes required by the state management test suite:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the Test Suite
Execute the entire 76-test suite:
```bash
flutter test
```

### 4. Update Golden Visual Masters (Optional)
If you update the UI code (padding, colors, text styles in `TaskTile`), you must update the master comparison images:
```bash
flutter test --update-goldens
```

---

## 📈 Code Quality & Documentation

Further details about test coverage bounds, improvement tracking, and edge-cases are documented locally:
* `COMPREHENSIVE_IMPROVEMENTS_SUMMARY.md` 
* `DETAILED_IMPROVEMENTS_BREAKDOWN.md`
* `CHANGELOG_CODE_CHANGES.md`
