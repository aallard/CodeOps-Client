/// Dialog for configuring a Jira Cloud connection.
///
/// Supports creating a new connection or editing an existing one.
/// Validates all fields, allows testing the connection before saving,
/// and persists the API token to secure storage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/health_snapshot.dart';
import '../../providers/auth_providers.dart';
import '../../providers/jira_providers.dart';
import '../../providers/task_providers.dart';
import '../../providers/team_providers.dart';
import '../../services/jira/jira_service.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for creating or editing a Jira Cloud connection.
///
/// When [existingConnection] is provided the dialog pre-fills name, URL,
/// and email from that connection (the API token is never returned from
/// the server so it must always be re-entered when editing).
///
/// On save the dialog:
/// 1. Creates or updates the connection via [IntegrationApi].
/// 2. Stores the API token in [SecureStorageService] keyed by connection ID.
/// 3. Invalidates [jiraConnectionsProvider] so the list refreshes.
class JiraConnectionDialog extends ConsumerStatefulWidget {
  /// An existing connection to edit. When `null` a new connection is created.
  final JiraConnection? existingConnection;

  /// Creates a [JiraConnectionDialog].
  const JiraConnectionDialog({super.key, this.existingConnection});

  @override
  ConsumerState<JiraConnectionDialog> createState() =>
      _JiraConnectionDialogState();
}

class _JiraConnectionDialogState extends ConsumerState<JiraConnectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _obscureToken = true;
  bool _testing = false;
  bool _saving = false;
  _TestResult? _testResult;

  bool get _isEditing => widget.existingConnection != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final conn = widget.existingConnection!;
      _nameController.text = conn.name;
      _urlController.text = conn.instanceUrl;
      _emailController.text = conn.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  /// Validates the connection name field.
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Connection name is required';
    }
    if (value.trim().length > 100) {
      return 'Name must be 100 characters or fewer';
    }
    return null;
  }

  /// Validates the Jira instance URL field.
  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Instance URL is required';
    }
    if (!value.trim().startsWith('https://')) {
      return 'URL must start with https://';
    }
    if (value.trim().length > 500) {
      return 'URL must be 500 characters or fewer';
    }
    return null;
  }

  /// Validates the email field.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates the API token field.
  String? _validateToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'API token is required';
    }
    return null;
  }

  /// Tests the connection using a temporary [JiraService] instance.
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final service = JiraService();
    service.configure(
      instanceUrl: _urlController.text.trim(),
      email: _emailController.text.trim(),
      apiToken: _tokenController.text.trim(),
    );

    try {
      final success = await service.testConnection();
      if (!mounted) return;
      setState(() {
        _testResult =
            success ? _TestResult.success : _TestResult.failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _testResult = _TestResult.failure);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  /// Saves the connection to the backend and stores the API token locally.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final teamId = ref.read(selectedTeamIdProvider);
    if (teamId == null) {
      if (mounted) {
        showToast(context, message: 'No team selected', type: ToastType.error);
      }
      return;
    }

    setState(() => _saving = true);

    try {
      final integrationApi = ref.read(integrationApiProvider);
      final secureStorage = ref.read(secureStorageProvider);

      final connection = await integrationApi.createJiraConnection(
        teamId,
        name: _nameController.text.trim(),
        instanceUrl: _urlController.text.trim(),
        email: _emailController.text.trim(),
        apiToken: _tokenController.text.trim(),
      );

      await saveJiraApiToken(
        secureStorage,
        connection.id,
        _tokenController.text.trim(),
      );

      ref.invalidate(jiraConnectionsProvider);

      if (!mounted) return;
      showToast(
        context,
        message: 'Jira connection saved',
        type: ToastType.success,
      );
      Navigator.of(context).pop(connection);
    } catch (e) {
      if (!mounted) return;
      showToast(
        context,
        message: 'Failed to save connection: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CodeOpsColors.surface,
      title: Text(_isEditing ? 'Edit Jira Connection' : 'New Jira Connection'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connect to a Jira Cloud instance using an API token. '
                  'Tokens can be generated at id.atlassian.com.',
                  style: TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Connection Name',
                  hint: 'e.g. Production Jira',
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _urlController,
                  label: 'Instance URL',
                  hint: 'https://your-domain.atlassian.net',
                  prefixText: null,
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@company.com',
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _tokenController,
                  label: 'API Token',
                  hint: 'Enter your Jira API token',
                  validator: _validateToken,
                  obscure: _obscureToken,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureToken ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: CodeOpsColors.textTertiary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureToken = !_obscureToken),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTestConnectionRow(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_testing || _saving)
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: CodeOpsColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: (_testing || _saving) ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  /// Builds a styled text form field matching the CodeOps theme.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    String? prefixText,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: CodeOpsColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: CodeOpsColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CodeOpsColors.error),
        ),
      ),
    );
  }

  /// Builds the test connection row with button and status indicator.
  Widget _buildTestConnectionRow() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: (_testing || _saving) ? null : _testConnection,
          icon: _testing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CodeOpsColors.primary,
                  ),
                )
              : const Icon(Icons.wifi_tethering, size: 18),
          label: const Text('Test Connection'),
          style: OutlinedButton.styleFrom(
            foregroundColor: CodeOpsColors.textPrimary,
            side: const BorderSide(color: CodeOpsColors.border),
          ),
        ),
        const SizedBox(width: 12),
        if (_testResult == _TestResult.success)
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 18, color: CodeOpsColors.success),
              SizedBox(width: 6),
              Text(
                'Connection successful',
                style: TextStyle(
                  color: CodeOpsColors.success,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        if (_testResult == _TestResult.failure)
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, size: 18, color: CodeOpsColors.error),
              SizedBox(width: 6),
              Text(
                'Connection failed',
                style: TextStyle(
                  color: CodeOpsColors.error,
                  fontSize: 13,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Result of a connection test.
enum _TestResult { success, failure }
