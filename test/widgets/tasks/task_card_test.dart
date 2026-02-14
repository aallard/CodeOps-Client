import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/remediation_task.dart';
import 'package:codeops/widgets/tasks/task_card.dart';

void main() {
  group('TaskCard', () {
    testWidgets('displays task number and title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(taskNumber: 42, title: 'Fix auth bug'),
            ),
          ),
        ),
      );

      expect(find.text('#42'), findsOneWidget);
      expect(find.text('Fix auth bug'), findsOneWidget);
    });

    testWidgets('displays status chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(status: TaskStatus.completed),
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('displays Jira badge when jiraKey present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(jiraKey: 'PAY-123'),
            ),
          ),
        ),
      );

      expect(find.text('PAY-123'), findsOneWidget);
    });

    testWidgets('does not show Jira badge when jiraKey null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(),
            ),
          ),
        ),
      );

      expect(find.text('PAY-123'), findsNothing);
    });

    testWidgets('shows checkbox when onCheckboxChanged provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(),
              onCheckboxChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('hides checkbox when onCheckboxChanged null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(),
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: _makeTask(),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TaskCard));
      expect(tapped, isTrue);
    });
  });
}

RemediationTask _makeTask({
  String id = 'task-1',
  int taskNumber = 1,
  String title = 'Test Task',
  TaskStatus status = TaskStatus.pending,
  Priority? priority,
  String? jiraKey,
}) {
  return RemediationTask(
    id: id,
    jobId: 'job-1',
    taskNumber: taskNumber,
    title: title,
    status: status,
    priority: priority,
    jiraKey: jiraKey,
  );
}
