// Tests for task providers.
//
// Verifies that integrationApiProvider, taskApiProvider are accessible
// and create proper instances. FutureProviders are verified as existing
// by checking their type without triggering execution. Also tests
// TaskFilter, TaskSort, and filtered/sorted providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/remediation_task.dart';
import 'package:codeops/providers/task_providers.dart';
import 'package:codeops/services/cloud/integration_api.dart';
import 'package:codeops/services/cloud/task_api.dart';

void main() {
  group('Task providers', () {
    test('integrationApiProvider creates IntegrationApi instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final api = container.read(integrationApiProvider);

      expect(api, isA<IntegrationApi>());
    });

    test('taskApiProvider creates TaskApi instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final api = container.read(taskApiProvider);

      expect(api, isA<TaskApi>());
    });

    test('jobTasksProvider is defined as a family provider', () {
      expect(jobTasksProvider, isNotNull);
      expect(jobTasksProvider('any-id'), isNotNull);
    });

    test('myTasksProvider is defined', () {
      expect(myTasksProvider, isNotNull);
    });

    test('taskProvider is defined as a family provider', () {
      expect(taskProvider, isNotNull);
      expect(taskProvider('any-id'), isNotNull);
    });
  });

  group('TaskFilter', () {
    test('default has no active filters', () {
      const filter = TaskFilter();

      expect(filter.status, isNull);
      expect(filter.priority, isNull);
      expect(filter.searchQuery, '');
      expect(filter.hasActiveFilters, isFalse);
    });

    test('hasActiveFilters returns true when status set', () {
      const filter = TaskFilter(status: TaskStatus.pending);

      expect(filter.hasActiveFilters, isTrue);
    });

    test('hasActiveFilters returns true when priority set', () {
      const filter = TaskFilter(priority: Priority.p0);

      expect(filter.hasActiveFilters, isTrue);
    });

    test('hasActiveFilters returns true when searchQuery non-empty', () {
      const filter = TaskFilter(searchQuery: 'fix');

      expect(filter.hasActiveFilters, isTrue);
    });

    test('copyWith replaces fields', () {
      const filter = TaskFilter(status: TaskStatus.pending);
      final updated = filter.copyWith(priority: Priority.p1);

      expect(updated.status, TaskStatus.pending);
      expect(updated.priority, Priority.p1);
    });

    test('copyWith clearStatus removes status', () {
      const filter = TaskFilter(status: TaskStatus.pending);
      final updated = filter.copyWith(clearStatus: true);

      expect(updated.status, isNull);
    });

    test('copyWith clearPriority removes priority', () {
      const filter = TaskFilter(priority: Priority.p0);
      final updated = filter.copyWith(clearPriority: true);

      expect(updated.priority, isNull);
    });
  });

  group('TaskSort', () {
    test('has 3 values', () {
      expect(TaskSort.values.length, 3);
    });

    test('labels are correct', () {
      expect(TaskSort.priorityDesc.label, 'Priority');
      expect(TaskSort.taskNumberAsc.label, 'Task #');
      expect(TaskSort.createdAtDesc.label, 'Created');
    });
  });

  group('taskFilterProvider', () {
    test('default is empty filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(taskFilterProvider);

      expect(filter.hasActiveFilters, isFalse);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state =
          const TaskFilter(status: TaskStatus.assigned);
      final filter = container.read(taskFilterProvider);

      expect(filter.status, TaskStatus.assigned);
    });
  });

  group('taskSortProvider', () {
    test('default is priorityDesc', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(taskSortProvider), TaskSort.priorityDesc);
    });
  });

  group('selectedTaskIdsProvider', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedTaskIdsProvider), isEmpty);
    });

    test('can update', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedTaskIdsProvider.notifier).state = {'a', 'b'};

      expect(container.read(selectedTaskIdsProvider), {'a', 'b'});
    });
  });

  group('selectedTaskProvider', () {
    test('starts null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedTaskProvider), isNull);
    });
  });

  group('filteredJobTasksProvider', () {
    test('applies status filter', () async {
      final container = ProviderContainer(
        overrides: [
          jobTasksProvider('job1').overrideWith((ref) async => [
                _makeTask(id: '1', status: TaskStatus.pending),
                _makeTask(id: '2', status: TaskStatus.completed),
                _makeTask(id: '3', status: TaskStatus.pending),
              ]),
        ],
      );
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state =
          const TaskFilter(status: TaskStatus.pending);

      await container.read(jobTasksProvider('job1').future);

      final result = container.read(filteredJobTasksProvider('job1'));

      expect(result.valueOrNull?.length, 2);
    });

    test('applies priority sort', () async {
      final container = ProviderContainer(
        overrides: [
          jobTasksProvider('job1').overrideWith((ref) async => [
                _makeTask(id: '1', priority: Priority.p3, taskNumber: 1),
                _makeTask(id: '2', priority: Priority.p0, taskNumber: 2),
                _makeTask(id: '3', priority: Priority.p1, taskNumber: 3),
              ]),
        ],
      );
      addTearDown(container.dispose);

      container.read(taskSortProvider.notifier).state = TaskSort.priorityDesc;

      await container.read(jobTasksProvider('job1').future);

      final tasks =
          container.read(filteredJobTasksProvider('job1')).valueOrNull!;

      expect(tasks[0].priority, Priority.p0);
      expect(tasks[1].priority, Priority.p1);
      expect(tasks[2].priority, Priority.p3);
    });

    test('applies task number sort', () async {
      final container = ProviderContainer(
        overrides: [
          jobTasksProvider('job1').overrideWith((ref) async => [
                _makeTask(id: '1', taskNumber: 3),
                _makeTask(id: '2', taskNumber: 1),
                _makeTask(id: '3', taskNumber: 2),
              ]),
        ],
      );
      addTearDown(container.dispose);

      container.read(taskSortProvider.notifier).state = TaskSort.taskNumberAsc;

      await container.read(jobTasksProvider('job1').future);

      final tasks =
          container.read(filteredJobTasksProvider('job1')).valueOrNull!;

      expect(tasks[0].taskNumber, 1);
      expect(tasks[1].taskNumber, 2);
      expect(tasks[2].taskNumber, 3);
    });

    test('applies search query filter', () async {
      final container = ProviderContainer(
        overrides: [
          jobTasksProvider('job1').overrideWith((ref) async => [
                _makeTask(id: '1', title: 'Fix authentication bug'),
                _makeTask(id: '2', title: 'Update README'),
                _makeTask(id: '3', title: 'Fix null pointer'),
              ]),
        ],
      );
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state =
          const TaskFilter(searchQuery: 'fix');

      await container.read(jobTasksProvider('job1').future);

      final result = container.read(filteredJobTasksProvider('job1'));

      expect(result.valueOrNull?.length, 2);
    });
  });
}

RemediationTask _makeTask({
  required String id,
  String title = 'Test Task',
  TaskStatus status = TaskStatus.pending,
  Priority? priority,
  int taskNumber = 1,
}) {
  return RemediationTask(
    id: id,
    jobId: 'job1',
    taskNumber: taskNumber,
    title: title,
    status: status,
    priority: priority,
  );
}
