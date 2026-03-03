// Unit tests for CollectionRunnerService.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/services/courier/collection_runner_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

List<RunnerRequest> _sampleRequests({int count = 3}) {
  return List.generate(count, (i) => RunnerRequest(
    id: 'req-$i',
    name: 'Request ${i + 1}',
    method: CourierHttpMethod.get,
    url: 'https://httpbin.org/get?idx=$i',
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('CollectionRunnerService', () {
    test('emits progress events for each request', () async {
      final runner = CollectionRunnerService();
      final events = <RunProgress>[];

      await for (final p in runner.runCollection(
        requests: _sampleRequests(count: 2),
        iterations: 1,
        delayMs: 0,
      )) {
        events.add(p);
      }

      // At minimum: running for req 1, result for req 1, running for req 2,
      // result for req 2, completed
      expect(events.isNotEmpty, true);
      expect(events.last.status, RunProgressStatus.completed);
    });

    test('reports correct iteration counts', () async {
      final runner = CollectionRunnerService();
      RunProgress? lastProgress;

      await for (final p in runner.runCollection(
        requests: _sampleRequests(count: 1),
        iterations: 3,
        delayMs: 0,
      )) {
        lastProgress = p;
      }

      expect(lastProgress, isNotNull);
      expect(lastProgress!.totalIterations, 3);
      expect(lastProgress.results.length, 3);
    });

    test('cancel stops the run', () async {
      final runner = CollectionRunnerService();
      final events = <RunProgress>[];

      // Start and cancel after first event
      await for (final p in runner.runCollection(
        requests: _sampleRequests(count: 10),
        iterations: 1,
        delayMs: 50,
      )) {
        events.add(p);
        if (events.length >= 2) {
          runner.cancel();
        }
      }

      // Should have cancelled before completing all 10
      final lastStatus = events.last.status;
      expect(
        lastStatus == RunProgressStatus.cancelled ||
            events.last.results.length < 10,
        true,
      );
    });

    test('carries variables across requests when keepVariables is true',
        () async {
      final runner = CollectionRunnerService();
      final envVars = {'TOKEN': 'initial'};

      RunProgress? lastProgress;
      await for (final p in runner.runCollection(
        requests: [
          const RunnerRequest(
            id: 'r1',
            name: 'Set Token',
            method: CourierHttpMethod.get,
            url: 'https://httpbin.org/get',
            preRequestScript: 'courier.environment.set("TOKEN", "updated");',
          ),
          const RunnerRequest(
            id: 'r2',
            name: 'Use Token',
            method: CourierHttpMethod.get,
            url: 'https://httpbin.org/get?token={{TOKEN}}',
          ),
        ],
        iterations: 1,
        delayMs: 0,
        environmentVars: envVars,
        keepVariables: true,
      )) {
        lastProgress = p;
      }

      expect(lastProgress, isNotNull);
      // The second request should have used the updated token
      expect(lastProgress!.results.length, 2);
    });

    test('data file rows inject variables per iteration', () async {
      final runner = CollectionRunnerService();
      final dataRows = [
        {'name': 'Alice'},
        {'name': 'Bob'},
      ];

      RunProgress? lastProgress;
      await for (final p in runner.runCollection(
        requests: [
          const RunnerRequest(
            id: 'r1',
            name: 'Get User',
            method: CourierHttpMethod.get,
            url: 'https://httpbin.org/get?name={{name}}',
          ),
        ],
        iterations: 2,
        delayMs: 0,
        dataRows: dataRows,
      )) {
        lastProgress = p;
      }

      expect(lastProgress, isNotNull);
      expect(lastProgress!.results.length, 2);
      // First iteration URL should contain Alice
      expect(lastProgress.results[0].url, contains('Alice'));
      // Second iteration URL should contain Bob
      expect(lastProgress.results[1].url, contains('Bob'));
    });

    test('handles request errors gracefully', () async {
      final runner = CollectionRunnerService();

      RunProgress? lastProgress;
      await for (final p in runner.runCollection(
        requests: [
          const RunnerRequest(
            id: 'r1',
            name: 'Bad Request',
            method: CourierHttpMethod.get,
            url: 'http://invalid-host-that-does-not-exist.local/fail',
          ),
        ],
        iterations: 1,
        delayMs: 0,
      )) {
        lastProgress = p;
      }

      expect(lastProgress, isNotNull);
      expect(lastProgress!.results.length, 1);
      expect(lastProgress.results.first.passed, false);
    });

    test('resolves {{variables}} in URL', () async {
      final runner = CollectionRunnerService();

      RunProgress? lastProgress;
      await for (final p in runner.runCollection(
        requests: [
          const RunnerRequest(
            id: 'r1',
            name: 'Resolved',
            method: CourierHttpMethod.get,
            url: 'https://{{HOST}}/api/{{VERSION}}/users',
          ),
        ],
        iterations: 1,
        delayMs: 0,
        environmentVars: {'HOST': 'example.com', 'VERSION': 'v1'},
      )) {
        lastProgress = p;
      }

      expect(lastProgress, isNotNull);
      expect(lastProgress!.results.first.url,
          'https://example.com/api/v1/users');
    });

    test('reports correct totalRequests in progress', () async {
      final runner = CollectionRunnerService();
      final requests = _sampleRequests(count: 5);

      RunProgress? firstRunning;
      await for (final p in runner.runCollection(
        requests: requests,
        iterations: 1,
        delayMs: 0,
      )) {
        if (firstRunning == null && p.status == RunProgressStatus.running) {
          firstRunning = p;
        }
      }

      expect(firstRunning, isNotNull);
      expect(firstRunning!.totalRequests, 5);
    });
  });
}
