/// Collection runner page for the Courier module.
///
/// Configuration panel → live progress → run summary. Allows running an
/// entire collection or specific folder in sequence with configurable
/// iterations, delays, environment selection, and data-file-driven
/// parameterized testing.
///
/// Route: `/courier/runner`.
library;

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/courier_enums.dart';
import '../../models/courier_models.dart';
import '../../providers/courier_providers.dart';
import '../../providers/courier_ui_providers.dart';
import '../../providers/team_providers.dart';
import '../../services/courier/collection_runner_service.dart';
import '../../services/courier/data_file_parser.dart';
import '../../theme/colors.dart';
import '../../widgets/courier/run_summary_view.dart';
import '../../widgets/courier/runner_progress_view.dart';

/// View mode for the runner page.
enum _RunnerMode {
  /// Configuration panel — user sets up the run.
  config,

  /// Live progress view — run is executing.
  running,

  /// Summary view — run has completed.
  summary,
}

/// Full-page collection runner shown at `/courier/runner`.
///
/// Manages the complete lifecycle: configuration → execution → results.
class CollectionRunnerPage extends ConsumerStatefulWidget {
  /// Creates a [CollectionRunnerPage].
  const CollectionRunnerPage({super.key});

  @override
  ConsumerState<CollectionRunnerPage> createState() =>
      _CollectionRunnerPageState();
}

class _CollectionRunnerPageState extends ConsumerState<CollectionRunnerPage> {
  _RunnerMode _mode = _RunnerMode.config;

  // Config state
  String? _selectedCollectionId;
  String? _selectedFolderId;
  int _iterations = 1;
  int _delayMs = 0;
  bool _keepVariables = true;
  bool _saveResponses = false;
  String? _dataFileName;
  List<Map<String, String>>? _dataRows;

  // Run state
  CollectionRunnerService? _runner;
  StreamSubscription<RunProgress>? _runSubscription;
  RunProgress? _currentProgress;
  List<RequestRunResult> _finalResults = [];

  @override
  void dispose() {
    _runSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startRun() async {
    if (_selectedCollectionId == null) return;

    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null) return;

    setState(() => _mode = _RunnerMode.running);

    try {
      // Fetch collection tree to get request list
      final api = ref.read(courierApiProvider);
      final tree = await api.getCollectionTree(teamId, _selectedCollectionId!);

      // Flatten folder tree to get requests in order
      final requests = <RunnerRequest>[];
      for (final folder in tree) {
        if (_selectedFolderId != null && folder.id != _selectedFolderId) {
          continue;
        }
        if (folder.requests != null) {
          for (final req in folder.requests!) {
            requests.add(RunnerRequest(
              id: req.id ?? '',
              name: req.name ?? 'Unnamed',
              method: req.method ?? CourierHttpMethod.get,
              url: req.url ?? '',
            ));
          }
        }
      }

      if (requests.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No requests found in collection')),
          );
          setState(() => _mode = _RunnerMode.config);
        }
        return;
      }

      // Get environment variables
      final envId = ref.read(activeEnvironmentIdProvider);
      var envVars = <String, String>{};
      if (envId != null) {
        try {
          final vars = await api.getEnvironmentVariables(teamId, envId);
          for (final v in vars) {
            if (v.variableKey != null &&
                v.variableValue != null &&
                v.isEnabled == true) {
              envVars[v.variableKey!] = v.variableValue!;
            }
          }
        } catch (_) {}
      }

      // Get global variables
      var globalVars = <String, String>{};
      try {
        final globals = await api.getGlobalVariables(teamId);
        for (final g in globals) {
          if (g.variableKey != null &&
              g.variableValue != null &&
              g.isEnabled == true) {
            globalVars[g.variableKey!] = g.variableValue!;
          }
        }
      } catch (_) {}

      // Start server-side tracking
      try {
        await api.startRun(
          teamId,
          StartCollectionRunRequest(
            collectionId: _selectedCollectionId!,
            environmentId: envId,
            iterationCount: _iterations,
            delayBetweenRequestsMs: _delayMs,
            dataFilename: _dataFileName,
          ),
        );
      } catch (_) {
        // Non-fatal — client can still run locally
      }

      _runner = CollectionRunnerService();
      final stream = _runner!.runCollection(
        requests: requests,
        iterations: _iterations,
        delayMs: _delayMs,
        environmentVars: envVars,
        globalVars: globalVars,
        dataRows: _dataRows,
        keepVariables: _keepVariables,
      );

      _runSubscription = stream.listen(
        (progress) {
          if (mounted) {
            setState(() => _currentProgress = progress);
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _finalResults = _currentProgress?.results ?? [];
              _mode = _RunnerMode.summary;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _finalResults = _currentProgress?.results ?? [];
              _mode = _RunnerMode.summary;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Runner error: $e')),
        );
        setState(() => _mode = _RunnerMode.config);
      }
    }
  }

  void _stopRun() {
    _runner?.cancel();
  }

  void _pauseRun() {
    _runner?.pause();
  }

  void _resumeRun() {
    _runner?.resume();
  }

  Future<void> _pickDataFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final content = String.fromCharCodes(file.bytes!);
    final ext = file.extension?.toLowerCase() ?? '';

    try {
      const parser = DataFileParser();
      final rows =
          ext == 'csv' ? parser.parseCsv(content) : parser.parseJson(content);
      setState(() {
        _dataFileName = file.name;
        _dataRows = rows;
        if (rows.length > _iterations) {
          _iterations = rows.length;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data file error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodeOpsColors.background,
      body: Column(
        children: [
          _buildPageHeader(context),
          const Divider(height: 1, color: CodeOpsColors.border),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Container(
      key: const Key('runner_page_header'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          InkWell(
            key: const Key('runner_back_button'),
            onTap: () => context.go('/courier'),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back,
                  size: 18, color: CodeOpsColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.play_circle_outline,
              size: 18, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 8),
          const Text(
            'Collection Runner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _RunnerMode.config:
        return _buildConfigPanel();
      case _RunnerMode.running:
        if (_currentProgress == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return RunnerProgressView(
          progress: _currentProgress!,
          onStop: _stopRun,
          onPause: _pauseRun,
          onResume: _resumeRun,
        );
      case _RunnerMode.summary:
        return RunSummaryView(
          results: _finalResults,
          iterations: _iterations,
          onRunAgain: () => setState(() => _mode = _RunnerMode.config),
        );
    }
  }

  Widget _buildConfigPanel() {
    final collectionsAsync = ref.watch(courierCollectionsProvider);
    final envsAsync = ref.watch(courierEnvironmentsProvider);

    return SingleChildScrollView(
      key: const Key('runner_config_panel'),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Collection selector
              _buildSectionHeader('Collection'),
              const SizedBox(height: 8),
              collectionsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e',
                    style:
                        const TextStyle(color: CodeOpsColors.error, fontSize: 12)),
                data: (collections) => _buildCollectionSelector(collections),
              ),

              const SizedBox(height: 20),

              // Environment selector
              _buildSectionHeader('Environment'),
              const SizedBox(height: 8),
              envsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e',
                    style:
                        const TextStyle(color: CodeOpsColors.error, fontSize: 12)),
                data: (envs) => _buildEnvironmentSelector(envs),
              ),

              const SizedBox(height: 20),

              // Iterations & Delay
              Row(
                children: [
                  Expanded(child: _buildIterationsField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDelayField()),
                ],
              ),

              const SizedBox(height: 20),

              // Data file
              _buildSectionHeader('Data File (optional)'),
              const SizedBox(height: 8),
              _buildDataFileSection(),

              const SizedBox(height: 20),

              // Toggles
              _buildToggles(),

              const SizedBox(height: 24),

              // Run button
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  key: const Key('run_collection_button'),
                  onPressed:
                      _selectedCollectionId != null ? _startRun : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text(
                    'Run Collection',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CodeOpsColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        CodeOpsColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: CodeOpsColors.textTertiary,
      ),
    );
  }

  Widget _buildCollectionSelector(
      List<CollectionSummaryResponse> collections) {
    return DropdownButtonFormField<String>(
      key: const Key('collection_selector'),
      initialValue: _selectedCollectionId,
      onChanged: (v) => setState(() => _selectedCollectionId = v),
      decoration: _fieldDecoration('Select a collection'),
      dropdownColor: CodeOpsColors.surfaceVariant,
      style: const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
      items: collections.map((c) {
        return DropdownMenuItem(
          value: c.id,
          child: Text(c.name ?? 'Unnamed'),
        );
      }).toList(),
    );
  }

  Widget _buildEnvironmentSelector(List<EnvironmentResponse> envs) {
    final activeId = ref.watch(activeEnvironmentIdProvider);
    return DropdownButtonFormField<String?>(
      key: const Key('environment_selector'),
      initialValue: activeId,
      onChanged: (v) =>
          ref.read(activeEnvironmentIdProvider.notifier).state = v,
      decoration: _fieldDecoration('No environment'),
      dropdownColor: CodeOpsColors.surfaceVariant,
      style: const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No environment',
              style: TextStyle(color: CodeOpsColors.textSecondary)),
        ),
        ...envs.map((e) => DropdownMenuItem<String?>(
              value: e.id,
              child: Text(e.name ?? 'Unnamed'),
            )),
      ],
    );
  }

  Widget _buildIterationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Iterations'),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('iterations_field'),
          initialValue: '$_iterations',
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null && n >= 1 && n <= 1000) {
              setState(() => _iterations = n);
            }
          },
          style:
              const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
          decoration: _fieldDecoration('1–1000'),
        ),
      ],
    );
  }

  Widget _buildDelayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Delay (ms)'),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('delay_field'),
          initialValue: '$_delayMs',
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null && n >= 0 && n <= 60000) {
              setState(() => _delayMs = n);
            }
          },
          style:
              const TextStyle(fontSize: 13, color: CodeOpsColors.textPrimary),
          decoration: _fieldDecoration('0–60000'),
        ),
      ],
    );
  }

  Widget _buildDataFileSection() {
    return InkWell(
      key: const Key('data_file_picker'),
      onTap: _pickDataFile,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: CodeOpsColors.border),
          borderRadius: BorderRadius.circular(8),
          color: CodeOpsColors.surface,
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file,
                size: 20, color: CodeOpsColors.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: _dataFileName != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dataFileName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CodeOpsColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_dataRows?.length ?? 0} data row(s)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Click to upload a CSV or JSON file',
                      style: TextStyle(
                        fontSize: 13,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
            ),
            if (_dataFileName != null)
              InkWell(
                onTap: () => setState(() {
                  _dataFileName = null;
                  _dataRows = null;
                }),
                child: const Icon(Icons.close,
                    size: 14, color: CodeOpsColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: CodeOpsColors.border),
        borderRadius: BorderRadius.circular(8),
        color: CodeOpsColors.surface,
      ),
      child: Column(
        children: [
          _buildToggleRow(
            key: const Key('keep_variables_toggle'),
            label: 'Keep variable values',
            subtitle: 'Persist variables set by scripts across requests',
            value: _keepVariables,
            onChanged: (v) => setState(() => _keepVariables = v),
          ),
          const Divider(height: 1, color: CodeOpsColors.border),
          _buildToggleRow(
            key: const Key('save_responses_toggle'),
            label: 'Save responses',
            subtitle: 'Store response bodies (off by default for large runs)',
            value: _saveResponses,
            onChanged: (v) => setState(() => _saveResponses = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required Key key,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: CodeOpsColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            key: key,
            value: value,
            onChanged: onChanged,
            activeTrackColor: CodeOpsColors.primary,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 13, color: CodeOpsColors.textTertiary),
      filled: true,
      fillColor: CodeOpsColors.surface,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CodeOpsColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CodeOpsColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CodeOpsColors.primary),
      ),
    );
  }
}
