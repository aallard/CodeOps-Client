import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/remediation_task.dart';
import 'package:codeops/widgets/tasks/task_card.dart';
import 'package:codeops/widgets/tasks/task_list.dart';

void main() {
  group('TaskListWidget', () {
    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: [],
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no tasks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: [],
            ),
          ),
        ),
      );

      expect(find.text('No Tasks'), findsOneWidget);
    });

    testWidgets('renders task cards for each task', (tester) async {
      final tasks = [
        _makeTask(id: '1', title: 'Task One', taskNumber: 1),
        _makeTask(id: '2', title: 'Task Two', taskNumber: 2),
        _makeTask(id: '3', title: 'Task Three', taskNumber: 3),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListWidget(tasks: tasks),
          ),
        ),
      );

      expect(find.byType(TaskCard), findsNWidgets(3));
      expect(find.text('Task One'), findsOneWidget);
      expect(find.text('Task Two'), findsOneWidget);
      expect(find.text('Task Three'), findsOneWidget);
    });

    testWidgets('shows task count', (tester) async {
      final tasks = [
        _makeTask(id: '1', taskNumber: 1),
        _makeTask(id: '2', taskNumber: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: tasks,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('2 tasks'), findsOneWidget);
    });

    testWidgets('shows selected count when items selected', (tester) async {
      final tasks = [
        _makeTask(id: '1', taskNumber: 1),
        _makeTask(id: '2', taskNumber: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: tasks,
              selectedIds: const {'1'},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('calls onTaskTap when task card tapped', (tester) async {
      RemediationTask? tappedTask;
      final tasks = [
        _makeTask(id: '1', title: 'Task One', taskNumber: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: tasks,
              onTaskTap: (t) => tappedTask = t,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TaskCard));
      expect(tappedTask?.id, '1');
    });
  });
}

RemediationTask _makeTask({
  String id = 'task-1',
  int taskNumber = 1,
  String title = 'Test Task',
  TaskStatus status = TaskStatus.pending,
}) {
  return RemediationTask(
    id: id,
    jobId: 'job-1',
    taskNumber: taskNumber,
    title: title,
    status: status,
  );
}
