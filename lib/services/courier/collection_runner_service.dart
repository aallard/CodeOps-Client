/// Orchestrates sequential execution of all requests in a collection.
///
/// Streams [RunProgress] events as each request completes. Supports
/// multiple iterations with data-file variable injection, delay between
/// requests, pause/resume, and cancel.
library;

import 'dart:async';

import '../courier/http_execution_service.dart';
import '../courier/script_engine.dart';
import '../../models/courier_enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Current status of the collection run.
enum RunProgressStatus {
  /// Preparing to run.
  preparing,

  /// Actively running requests.
  running,

  /// User paused the run.
  paused,

  /// Run completed successfully.
  completed,

  /// Run was cancelled by user.
  cancelled,

  /// Run encountered an error.
  error,
}

/// Progress snapshot emitted during a collection run.
class RunProgress {
  /// 1-based index of the current iteration.
  final int currentIteration;

  /// Total number of iterations.
  final int totalIterations;

  /// 1-based index of the current request within the iteration.
  final int currentRequest;

  /// Total number of requests per iteration.
  final int totalRequests;

  /// Name of the request currently being executed.
  final String requestName;

  /// Result of the last completed request, or null.
  final RequestRunResult? lastResult;

  /// Current run status.
  final RunProgressStatus status;

  /// All results accumulated so far.
  final List<RequestRunResult> results;

  /// Creates a [RunProgress].
  const RunProgress({
    required this.currentIteration,
    required this.totalIterations,
    required this.currentRequest,
    required this.totalRequests,
    required this.requestName,
    this.lastResult,
    required this.status,
    this.results = const [],
  });
}

/// Result of executing a single request in a collection run.
class RequestRunResult {
  /// Server-side request ID.
  final String requestId;

  /// Display name of the request.
  final String requestName;

  /// HTTP method used.
  final String method;

  /// Fully resolved URL.
  final String url;

  /// HTTP response status code, or null on connection failure.
  final int? statusCode;

  /// Round-trip duration in milliseconds.
  final int? durationMs;

  /// Response body size in bytes.
  final int? responseSizeBytes;

  /// Whether all test assertions passed.
  final bool passed;

  /// Total number of test assertions.
  final int testsTotal;

  /// Number of passing test assertions.
  final int testsPassed;

  /// Error message on failure, or null.
  final String? error;

  /// 1-based iteration number this result belongs to.
  final int iteration;

  /// Creates a [RequestRunResult].
  const RequestRunResult({
    required this.requestId,
    required this.requestName,
    required this.method,
    required this.url,
    this.statusCode,
    this.durationMs,
    this.responseSizeBytes,
    required this.passed,
    this.testsTotal = 0,
    this.testsPassed = 0,
    this.error,
    this.iteration = 1,
  });
}

/// A request definition for the runner to execute.
class RunnerRequest {
  /// Server-side request ID.
  final String id;

  /// Display name.
  final String name;

  /// HTTP method.
  final CourierHttpMethod method;

  /// URL (may contain `{{variables}}`).
  final String url;

  /// Request headers.
  final Map<String, String> headers;

  /// Request body (raw string).
  final String? body;

  /// Content type override.
  final String? contentType;

  /// Pre-request script source.
  final String? preRequestScript;

  /// Post-response / test script source.
  final String? postResponseScript;

  /// Creates a [RunnerRequest].
  const RunnerRequest({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.contentType,
    this.preRequestScript,
    this.postResponseScript,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Executes a list of requests sequentially with optional iterations.
///
/// Each request goes through the full pipeline: variable resolution →
/// pre-request script → HTTP execution → post-response script → result
/// collection. Emits [RunProgress] events via a [Stream].
class CollectionRunnerService {
  final HttpExecutionService _httpService;
  final ScriptEngine _scriptEngine;

  bool _cancelled = false;
  bool _paused = false;
  final Completer<void> _resumeCompleter = Completer<void>();

  /// Creates a [CollectionRunnerService].
  CollectionRunnerService({
    HttpExecutionService? httpService,
    ScriptEngine? scriptEngine,
  })  : _httpService = httpService ?? HttpExecutionService(),
        _scriptEngine = scriptEngine ?? ScriptEngine();

  /// Executes the given [requests] sequentially over [iterations] iterations.
  ///
  /// Emits [RunProgress] events as each request completes. Data rows
  /// from [dataRows] are injected as variables per iteration.
  Stream<RunProgress> runCollection({
    required List<RunnerRequest> requests,
    required int iterations,
    required int delayMs,
    Map<String, String> environmentVars = const {},
    Map<String, String> globalVars = const {},
    List<Map<String, String>>? dataRows,
    bool keepVariables = true,
  }) async* {
    _cancelled = false;
    _paused = false;

    final allResults = <RequestRunResult>[];
    final carriedEnv = Map<String, String>.from(environmentVars);
    final carriedGlobals = Map<String, String>.from(globalVars);

    for (int iter = 1; iter <= iterations; iter++) {
      // Per-iteration variable context (data row merged in)
      final iterEnv = Map<String, String>.from(
          keepVariables ? carriedEnv : environmentVars);
      final iterGlobals = Map<String, String>.from(
          keepVariables ? carriedGlobals : globalVars);

      // Merge data row variables if available
      if (dataRows != null && iter - 1 < dataRows.length) {
        iterEnv.addAll(dataRows[iter - 1]);
      }

      for (int reqIdx = 0; reqIdx < requests.length; reqIdx++) {
        if (_cancelled) {
          yield RunProgress(
            currentIteration: iter,
            totalIterations: iterations,
            currentRequest: reqIdx + 1,
            totalRequests: requests.length,
            requestName: requests[reqIdx].name,
            status: RunProgressStatus.cancelled,
            results: List.unmodifiable(allResults),
          );
          return;
        }

        // Handle pause
        if (_paused) {
          yield RunProgress(
            currentIteration: iter,
            totalIterations: iterations,
            currentRequest: reqIdx + 1,
            totalRequests: requests.length,
            requestName: requests[reqIdx].name,
            status: RunProgressStatus.paused,
            results: List.unmodifiable(allResults),
          );
          await _waitForResume();
          if (_cancelled) return;
        }

        final req = requests[reqIdx];

        // Emit running status
        yield RunProgress(
          currentIteration: iter,
          totalIterations: iterations,
          currentRequest: reqIdx + 1,
          totalRequests: requests.length,
          requestName: req.name,
          status: RunProgressStatus.running,
          results: List.unmodifiable(allResults),
        );

        // Execute single request
        final result = await _executeRequest(
          request: req,
          envVars: iterEnv,
          globalVars: iterGlobals,
          iteration: iter,
        );

        // Update carried variables
        if (keepVariables) {
          carriedEnv.addAll(iterEnv);
          carriedGlobals.addAll(iterGlobals);
        }

        allResults.add(result);

        // Emit progress with result
        yield RunProgress(
          currentIteration: iter,
          totalIterations: iterations,
          currentRequest: reqIdx + 1,
          totalRequests: requests.length,
          requestName: req.name,
          lastResult: result,
          status: RunProgressStatus.running,
          results: List.unmodifiable(allResults),
        );

        // Delay between requests
        if (delayMs > 0 &&
            !(iter == iterations && reqIdx == requests.length - 1)) {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    // Completed
    yield RunProgress(
      currentIteration: iterations,
      totalIterations: iterations,
      currentRequest: requests.length,
      totalRequests: requests.length,
      requestName: requests.isNotEmpty ? requests.last.name : '',
      status: RunProgressStatus.completed,
      results: List.unmodifiable(allResults),
    );
  }

  /// Cancels the currently running collection.
  void cancel() {
    _cancelled = true;
    _httpService.cancel();
    if (_paused) resume();
  }

  /// Pauses the run after the current request completes.
  void pause() {
    _paused = true;
  }

  /// Resumes a paused run.
  void resume() {
    _paused = false;
    if (!_resumeCompleter.isCompleted) {
      _resumeCompleter.complete();
    }
  }

  /// Whether the run is currently paused.
  bool get isPaused => _paused;

  /// Whether the run has been cancelled.
  bool get isCancelled => _cancelled;

  Future<void> _waitForResume() async {
    while (_paused && !_cancelled) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<RequestRunResult> _executeRequest({
    required RunnerRequest request,
    required Map<String, String> envVars,
    required Map<String, String> globalVars,
    required int iteration,
  }) async {
    try {
      // Resolve variables in URL, headers, body
      var url = _resolveVariables(request.url, envVars, globalVars);
      final headers = request.headers.map(
        (k, v) => MapEntry(k, _resolveVariables(v, envVars, globalVars)),
      );
      final body = request.body != null
          ? _resolveVariables(request.body!, envVars, globalVars)
          : null;

      final reqContext = RequestContext(url: url, headers: headers);
      final varContext = VariableContext(
        environment: envVars,
        globals: globalVars,
      );

      // Execute pre-request script
      if (request.preRequestScript != null &&
          request.preRequestScript!.isNotEmpty) {
        final preResult = await _scriptEngine.executePreRequest(
          script: request.preRequestScript!,
          requestContext: reqContext,
          variables: varContext,
        );
        // Apply variable updates
        envVars.addAll(preResult.variableUpdates);
        // Apply header updates
        reqContext.headers.addAll(preResult.headerUpdates);
        // Apply URL updates
        url = reqContext.url;
      }

      // Execute HTTP request
      final httpResult = await _httpService.execute(HttpExecutionRequest(
        method: request.method,
        url: url,
        headers: reqContext.headers,
        body: body,
        contentType: request.contentType,
      ));

      // Execute post-response script (tests)
      var testsTotal = 0;
      var testsPassed = 0;

      if (request.postResponseScript != null &&
          request.postResponseScript!.isNotEmpty &&
          httpResult.isSuccess) {
        final respContext = ResponseContext(
          statusCode: httpResult.statusCode ?? 0,
          body: httpResult.body ?? '',
          headers: httpResult.responseHeaders,
          responseTimeMs: httpResult.durationMs,
        );

        final postResult = await _scriptEngine.executePostResponse(
          script: request.postResponseScript!,
          requestContext: reqContext,
          responseContext: respContext,
          variables: varContext,
        );

        envVars.addAll(postResult.variableUpdates);
        testsTotal = postResult.testResults.length;
        testsPassed =
            postResult.testResults.where((t) => t.passed).length;
      }

      final allPassed = httpResult.isSuccess &&
          (testsTotal == 0 || testsPassed == testsTotal);

      return RequestRunResult(
        requestId: request.id,
        requestName: request.name,
        method: request.method.toJson(),
        url: url,
        statusCode: httpResult.statusCode,
        durationMs: httpResult.durationMs,
        responseSizeBytes: httpResult.responseSize,
        passed: allPassed,
        testsTotal: testsTotal,
        testsPassed: testsPassed,
        error: httpResult.error,
        iteration: iteration,
      );
    } catch (e) {
      return RequestRunResult(
        requestId: request.id,
        requestName: request.name,
        method: request.method.toJson(),
        url: request.url,
        passed: false,
        error: e.toString(),
        iteration: iteration,
      );
    }
  }

  /// Replaces `{{variableName}}` tokens with values from env/global maps.
  String _resolveVariables(
    String input,
    Map<String, String> envVars,
    Map<String, String> globalVars,
  ) {
    return input.replaceAllMapped(
      RegExp(r'\{\{(\w+)\}\}'),
      (match) {
        final name = match.group(1)!;
        return envVars[name] ?? globalVars[name] ?? match.group(0)!;
      },
    );
  }
}
