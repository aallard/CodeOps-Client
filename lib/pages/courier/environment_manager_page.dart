/// Environment manager page for the Courier module.
///
/// Two-pane layout with [EnvironmentListPanel] on the left and either
/// [EnvironmentEditorPanel] or [GlobalVariablesPanel] on the right.
/// Route: `/courier/environments`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../widgets/courier/environment_editor_panel.dart';
import '../../widgets/courier/environment_list_panel.dart';
import '../../widgets/courier/global_variables_panel.dart';

/// Selection mode for the right pane.
enum _PaneMode {
  /// No selection — show placeholder.
  none,

  /// Globals panel is displayed.
  globals,

  /// An environment editor is displayed.
  environment,
}

/// Full-page environment manager shown at `/courier/environments`.
///
/// Left pane: searchable list of environments + Globals shortcut.
/// Right pane: editor for the selected environment or global variables.
class EnvironmentManagerPage extends StatefulWidget {
  /// Creates an [EnvironmentManagerPage].
  const EnvironmentManagerPage({super.key});

  @override
  State<EnvironmentManagerPage> createState() => _EnvironmentManagerPageState();
}

class _EnvironmentManagerPageState extends State<EnvironmentManagerPage> {
  _PaneMode _mode = _PaneMode.none;
  String? _selectedEnvId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodeOpsColors.background,
      body: Column(
        children: [
          // Page header
          _buildPageHeader(context),
          const Divider(height: 1, color: CodeOpsColors.border),
          // Two-pane layout
          Expanded(
            child: Row(
              children: [
                // Left: environment list
                SizedBox(
                  width: 280,
                  child: EnvironmentListPanel(
                    selectedEnvironmentId: _selectedEnvId,
                    globalsSelected: _mode == _PaneMode.globals,
                    onSelectEnvironment: (id) {
                      setState(() {
                        _mode = _PaneMode.environment;
                        _selectedEnvId = id;
                      });
                    },
                    onSelectGlobals: () {
                      setState(() {
                        _mode = _PaneMode.globals;
                        _selectedEnvId = null;
                      });
                    },
                    onEnvironmentCreated: (id) {
                      setState(() {
                        _mode = _PaneMode.environment;
                        _selectedEnvId = id;
                      });
                    },
                    onEnvironmentDeleted: (id) {
                      if (_selectedEnvId == id) {
                        setState(() {
                          _mode = _PaneMode.none;
                          _selectedEnvId = null;
                        });
                      }
                    },
                  ),
                ),
                // Right: editor or placeholder
                Expanded(child: _buildRightPane()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Container(
      key: const Key('env_page_header'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: CodeOpsColors.surface,
      child: Row(
        children: [
          InkWell(
            key: const Key('env_back_button'),
            onTap: () => context.go('/courier'),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back,
                  size: 18, color: CodeOpsColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.tune_outlined,
              size: 18, color: CodeOpsColors.textSecondary),
          const SizedBox(width: 8),
          const Text(
            'Environment Manager',
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

  Widget _buildRightPane() {
    switch (_mode) {
      case _PaneMode.globals:
        return const GlobalVariablesPanel();
      case _PaneMode.environment:
        if (_selectedEnvId == null) return _buildPlaceholder();
        return EnvironmentEditorPanel(
          key: ValueKey(_selectedEnvId),
          environmentId: _selectedEnvId!,
        );
      case _PaneMode.none:
        return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Center(
      key: const Key('env_placeholder'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_outlined,
              size: 48, color: CodeOpsColors.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'Select an environment to edit',
            style: TextStyle(
              fontSize: 14,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Or click Globals to manage team-wide variables',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
