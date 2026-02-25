/// Dialog for creating a new Relay channel.
///
/// Provides fields for channel name, description, type (public/private),
/// and optional topic. Shows a slug preview derived from the name field.
/// Validates name uniqueness via API on submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_enums.dart';
import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../theme/colors.dart';
import '../shared/notification_toast.dart';

/// Dialog for creating a new Relay channel.
///
/// Provides fields for channel name, description, type (public/private),
/// and optional topic. Validates name uniqueness via API.
class CreateChannelDialog extends ConsumerStatefulWidget {
  /// The team ID to create the channel in.
  final String teamId;

  /// Creates a [CreateChannelDialog].
  const CreateChannelDialog({required this.teamId, super.key});

  @override
  ConsumerState<CreateChannelDialog> createState() =>
      _CreateChannelDialogState();
}

class _CreateChannelDialogState extends ConsumerState<CreateChannelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicController = TextEditingController();

  ChannelType _channelType = ChannelType.public;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  /// Generates a URL-safe slug from the channel name.
  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  /// Submits the form and creates the channel via API.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(relayApiProvider);
      final request = CreateChannelRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        channelType: _channelType,
        topic: _topicController.text.trim().isEmpty
            ? null
            : _topicController.text.trim(),
      );
      final result = await api.createChannel(widget.teamId, request);
      ref.invalidate(teamChannelsProvider(widget.teamId));
      if (mounted) {
        showToast(
          context,
          message: 'Created #${result.name ?? 'channel'}',
          type: ToastType.success,
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = e.toString().contains('already exists')
              ? 'Channel name already exists'
              : 'Failed to create channel: $e';
        });
      }
    }
  }

  /// Validates the channel name input.
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 80) {
      return 'Name must be 80 characters or fewer';
    }
    if (RegExp(r'[^a-zA-Z0-9\s\-]').hasMatch(value.trim())) {
      return 'Only letters, numbers, spaces, and hyphens allowed';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final slug = _generateSlug(_nameController.text);

    return Dialog(
      backgroundColor: CodeOpsColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    const Icon(Icons.tag,
                        size: 20, color: CodeOpsColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Create Channel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CodeOpsColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: CodeOpsColors.textTertiary),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: CodeOpsColors.border),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          hintText: 'e.g. engineering',
                          isDense: true,
                        ),
                        maxLength: 80,
                        validator: _validateName,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (slug.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Will be created as #$slug',
                            style: const TextStyle(
                              fontSize: 11,
                              color: CodeOpsColors.textTertiary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Channel type selector
                      const Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CodeOpsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ChannelType>(
                        segments: const [
                          ButtonSegment(
                            value: ChannelType.public,
                            label: Text('Public'),
                            icon: Icon(Icons.tag, size: 16),
                          ),
                          ButtonSegment(
                            value: ChannelType.private,
                            label: Text('Private'),
                            icon: Icon(Icons.lock_outline, size: 16),
                          ),
                        ],
                        selected: {_channelType},
                        onSelectionChanged: (selection) {
                          setState(() => _channelType = selection.first);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        child: Text(
                          _channelType == ChannelType.public
                              ? 'Anyone on the team can join'
                              : 'Invite only — members must be added',
                          style: const TextStyle(
                            fontSize: 11,
                            color: CodeOpsColors.textTertiary,
                          ),
                        ),
                      ),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What is this channel about?',
                          isDense: true,
                        ),
                        maxLength: 500,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),

                      // Topic field
                      TextFormField(
                        controller: _topicController,
                        decoration: const InputDecoration(
                          labelText: 'Topic',
                          hintText: 'Set a topic for the channel',
                          isDense: true,
                        ),
                        maxLength: 250,
                      ),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CodeOpsColors.error,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _submitting ||
                                    _nameController.text.trim().length < 2
                                ? null
                                : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
