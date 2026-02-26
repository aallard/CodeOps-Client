/// Message composer widget for the Relay module.
///
/// Provides a text input area at the bottom of the center column for
/// sending new messages and editing existing ones. Supports Enter to
/// send, Shift+Enter for newline, @mention autocomplete with channel
/// member filtering, file attachment via file picker and drag-and-drop,
/// and an edit banner when editing an existing message.
library;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/relay_models.dart';
import '../../providers/relay_providers.dart';
import '../../providers/team_providers.dart';
import '../../services/cloud/relay_api.dart';
import '../../theme/colors.dart';
import 'relay_file_icon.dart';
import 'relay_file_upload_indicator.dart';

/// Message composer for sending and editing channel messages.
///
/// When [editingMessageProvider] contains a message, the composer enters
/// edit mode: an edit banner appears, the text field pre-populates with
/// the message content, and submitting calls [RelayApiService.editMessage]
/// instead of [RelayApiService.sendMessage].
///
/// Typing `@` triggers an autocomplete overlay that filters channel
/// members by display name. Selecting a member inserts `@DisplayName`
/// and tracks their UUID for the `mentionedUserIds` field.
///
/// Files can be attached via the paperclip button (opens a file picker)
/// or by dragging files onto the composer area. Pending files appear as
/// removable chips below the text field. After send, files are uploaded
/// to the message via [RelayApiService.uploadFile].
class RelayMessageComposer extends ConsumerStatefulWidget {
  /// UUID of the channel to send messages to.
  final String channelId;

  /// Creates a [RelayMessageComposer].
  const RelayMessageComposer({required this.channelId, super.key});

  @override
  ConsumerState<RelayMessageComposer> createState() =>
      _RelayMessageComposerState();
}

class _RelayMessageComposerState extends ConsumerState<RelayMessageComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _mentionedUserIds = <String>{};
  bool _mentionsEveryone = false;
  bool _isDragging = false;

  // @mention autocomplete state
  bool _showMentionOverlay = false;
  String _mentionQuery = '';
  int _mentionStartIndex = -1;

  /// Resolves the current team ID from the selected team provider.
  String? get _teamId => ref.read(selectedTeamIdProvider);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Monitors text changes for @mention trigger and typing state.
  void _onTextChanged() {
    final text = _controller.text;
    final selection = _controller.selection;

    // Update typing state
    ref.read(isTypingProvider.notifier).state = text.isNotEmpty;

    if (!selection.isValid || !selection.isCollapsed) {
      _dismissMentionOverlay();
      return;
    }

    final cursorPos = selection.baseOffset;
    final textBefore = text.substring(0, cursorPos);

    // Find the last '@' before the cursor that isn't preceded by a word char
    final atIndex = textBefore.lastIndexOf('@');
    if (atIndex >= 0) {
      // '@' must be at start or preceded by whitespace
      if (atIndex == 0 || textBefore[atIndex - 1] == ' ' || textBefore[atIndex - 1] == '\n') {
        final query = textBefore.substring(atIndex + 1);
        // Only show if the query has no spaces (still typing a single mention)
        if (!query.contains(' ') && !query.contains('\n')) {
          setState(() {
            _showMentionOverlay = true;
            _mentionQuery = query;
            _mentionStartIndex = atIndex;
          });
          return;
        }
      }
    }

    _dismissMentionOverlay();
  }

  /// Dismisses the @mention autocomplete overlay.
  void _dismissMentionOverlay() {
    if (_showMentionOverlay) {
      setState(() {
        _showMentionOverlay = false;
        _mentionQuery = '';
        _mentionStartIndex = -1;
      });
    }
  }

  /// Opens the system file picker and adds selected files to pending.
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;

    final pending = ref.read(pendingAttachmentsProvider);
    final newFiles = <PendingFile>[];

    for (final pf in result.files) {
      if (pf.bytes != null) {
        newFiles.add(PendingFile(
          name: pf.name,
          bytes: Uint8List.fromList(pf.bytes!),
          contentType: _mimeFromName(pf.name),
        ));
      }
    }

    ref.read(pendingAttachmentsProvider.notifier).state = [
      ...pending,
      ...newFiles,
    ];
  }

  /// Handles files dropped onto the composer via drag-and-drop.
  Future<void> _onFilesDropped(DropDoneDetails details) async {
    final pending = ref.read(pendingAttachmentsProvider);
    final newFiles = <PendingFile>[];

    for (final xFile in details.files) {
      final bytes = await xFile.readAsBytes();
      newFiles.add(PendingFile(
        name: xFile.name,
        bytes: Uint8List.fromList(bytes),
        contentType: _mimeFromName(xFile.name),
      ));
    }

    ref.read(pendingAttachmentsProvider.notifier).state = [
      ...pending,
      ...newFiles,
    ];

    setState(() => _isDragging = false);
  }

  /// Removes a pending file by index.
  void _removePendingFile(int index) {
    final pending = [...ref.read(pendingAttachmentsProvider)];
    pending.removeAt(index);
    ref.read(pendingAttachmentsProvider.notifier).state = pending;
  }

  /// Sends a new message or submits an edit.
  ///
  /// When pending files exist and the message is new (not an edit),
  /// the message is sent first to obtain its ID, then each file is
  /// uploaded to that message with progress tracking.
  Future<void> _submit() async {
    final text = _controller.text.trim();
    final pendingFiles = ref.read(pendingAttachmentsProvider);
    if (text.isEmpty && pendingFiles.isEmpty) return;

    final teamId = _teamId;
    if (teamId == null) return;

    final api = ref.read(relayApiProvider);
    final editingMessage = ref.read(editingMessageProvider);

    try {
      if (editingMessage != null && editingMessage.id != null) {
        // Edit mode — no file uploads
        await api.editMessage(
          widget.channelId,
          editingMessage.id!,
          UpdateMessageRequest(content: text),
        );
        _cancelEdit();
      } else {
        // Send mode
        final sentMessage = await api.sendMessage(
          widget.channelId,
          SendMessageRequest(
            content: text.isNotEmpty ? text : '',
            mentionedUserIds:
                _mentionedUserIds.isNotEmpty ? _mentionedUserIds.toList() : null,
            mentionsEveryone: _mentionsEveryone ? true : null,
          ),
          teamId,
        );
        _controller.clear();
        _mentionedUserIds.clear();
        _mentionsEveryone = false;

        // Upload pending files
        if (pendingFiles.isNotEmpty && sentMessage.id != null) {
          ref.read(pendingAttachmentsProvider.notifier).state = [];
          await _uploadFiles(api, sentMessage.id!, pendingFiles);
        }
      }

      // Refresh the message feed
      ref
          .read(accumulatedMessagesProvider(
            (channelId: widget.channelId, teamId: teamId),
          ).notifier)
          .refresh();
    } catch (_) {
      // Error handling — show a snackbar if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: CodeOpsColors.error,
          ),
        );
      }
    }
  }

  /// Uploads each pending file to the given message.
  ///
  /// Tracks per-file progress via [uploadProgressProvider] and
  /// clears the progress map when all uploads are done.
  Future<void> _uploadFiles(
    RelayApiService api,
    String messageId,
    List<PendingFile> files,
  ) async {
    // Initialize progress entries.
    final progressMap = <String, FileUploadProgress>{};
    for (final f in files) {
      progressMap[f.name] = FileUploadProgress(
        fileName: f.name,
        totalBytes: f.size,
      );
    }
    ref.read(uploadProgressProvider.notifier).state = {...progressMap};

    for (final file in files) {
      try {
        await api.uploadFile(
          messageId,
          file.bytes,
          file.name,
          file.contentType,
          onSendProgress: (sent, total) {
            final current = ref.read(uploadProgressProvider);
            ref.read(uploadProgressProvider.notifier).state = {
              ...current,
              file.name: current[file.name]!.copyWith(
                bytesSent: sent,
                totalBytes: total,
              ),
            };
          },
        );

        // Mark complete.
        final current = ref.read(uploadProgressProvider);
        ref.read(uploadProgressProvider.notifier).state = {
          ...current,
          file.name: current[file.name]!.copyWith(isComplete: true),
        };
      } catch (_) {
        // Mark failed.
        final current = ref.read(uploadProgressProvider);
        ref.read(uploadProgressProvider.notifier).state = {
          ...current,
          file.name: current[file.name]!.copyWith(isFailed: true),
        };
      }
    }

    // Clear progress after a brief delay so the user sees the result.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      ref.read(uploadProgressProvider.notifier).state = {};

      // Refresh feed to show attachments.
      final teamId = _teamId;
      if (teamId != null) {
        ref
            .read(accumulatedMessagesProvider(
              (channelId: widget.channelId, teamId: teamId),
            ).notifier)
            .refresh();
      }
    }
  }

  /// Cancels edit mode and clears the composer.
  void _cancelEdit() {
    ref.read(editingMessageProvider.notifier).state = null;
    _controller.clear();
    _mentionedUserIds.clear();
    _mentionsEveryone = false;
  }

  /// Inserts a @mention for a channel member.
  void _insertMention(ChannelMemberResponse member) {
    final displayName = member.userDisplayName ?? 'Unknown';
    final mentionText = '@$displayName';

    final text = _controller.text;
    final before = text.substring(0, _mentionStartIndex);
    final cursorPos = _controller.selection.baseOffset;
    final after = text.substring(cursorPos);

    _controller.text = '$before$mentionText $after';
    _controller.selection = TextSelection.collapsed(
      offset: before.length + mentionText.length + 1,
    );

    if (member.userId != null) {
      _mentionedUserIds.add(member.userId!);
    }

    _dismissMentionOverlay();
    _focusNode.requestFocus();
  }

  /// Inserts @everyone mention.
  void _insertEveryoneMention() {
    final text = _controller.text;
    final before = text.substring(0, _mentionStartIndex);
    final cursorPos = _controller.selection.baseOffset;
    final after = text.substring(cursorPos);

    const mentionText = '@everyone';
    _controller.text = '$before$mentionText $after';
    _controller.selection = TextSelection.collapsed(
      offset: before.length + mentionText.length + 1,
    );

    _mentionsEveryone = true;

    _dismissMentionOverlay();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final editingMessage = ref.watch(editingMessageProvider);
    final isEditing = editingMessage != null;
    final pendingFiles = ref.watch(pendingAttachmentsProvider);
    final uploads = ref.watch(uploadProgressProvider);

    // Pre-populate text field when entering edit mode
    if (isEditing && _controller.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.text = editingMessage.content ?? '';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        _focusNode.requestFocus();
      });
    }

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: _onFilesDropped,
      child: Container(
        decoration: _isDragging
            ? BoxDecoration(
                border: Border.all(color: CodeOpsColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isDragging)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload_outlined,
                        size: 16, color: CodeOpsColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Drop files here',
                      style: TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (isEditing) _buildEditBanner(editingMessage),
            if (uploads.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: RelayFileUploadIndicator(),
              ),
            if (pendingFiles.isNotEmpty)
              _buildPendingFilesChips(pendingFiles),
            if (_showMentionOverlay) _buildMentionList(),
            _buildComposerRow(isEditing, pendingFiles.isNotEmpty),
          ],
        ),
      ),
    );
  }

  /// Builds the row of removable chips for pending file attachments.
  Widget _buildPendingFilesChips(List<PendingFile> files) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: List.generate(files.length, (i) {
          final file = files[i];
          return Chip(
            avatar: RelayFileIcon(
              fileName: file.name,
              size: 14,
              color: CodeOpsColors.textSecondary,
            ),
            label: Text(
              file.name,
              style: const TextStyle(
                  fontSize: 11, color: CodeOpsColors.textPrimary),
            ),
            deleteIcon: const Icon(Icons.close, size: 14),
            deleteIconColor: CodeOpsColors.textTertiary,
            onDeleted: () => _removePendingFile(i),
            backgroundColor: CodeOpsColors.surfaceVariant,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }),
      ),
    );
  }

  /// Builds the edit mode banner above the text field.
  Widget _buildEditBanner(MessageResponse message) {
    final preview = message.content ?? '';
    final truncated =
        preview.length > 80 ? '${preview.substring(0, 80)}...' : preview;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: CodeOpsColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 14, color: CodeOpsColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Editing message',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              truncated,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: CodeOpsColors.textTertiary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: CodeOpsColors.textTertiary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
            tooltip: 'Cancel edit',
            onPressed: _cancelEdit,
          ),
        ],
      ),
    );
  }

  /// Builds the main composer row with attachment button, text field, and send.
  Widget _buildComposerRow(bool isEditing, bool hasAttachments) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file, size: 20),
            color: CodeOpsColors.textTertiary,
            tooltip: 'Attach file',
            onPressed: _pickFiles,
          ),
          const SizedBox(width: 4),

          // Text input
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontSize: 13,
                  color: CodeOpsColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: CodeOpsColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Send / submit button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final hasText = value.text.trim().isNotEmpty || hasAttachments;

              return IconButton(
                icon: Icon(
                  isEditing ? Icons.check : Icons.send,
                  size: 20,
                ),
                color: hasText
                    ? CodeOpsColors.primary
                    : CodeOpsColors.textTertiary,
                tooltip: isEditing ? 'Save edit' : 'Send message',
                onPressed: hasText ? _submit : null,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Handles key events for Enter/Shift+Enter and Escape.
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Escape cancels edit mode or dismisses @mention overlay
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_showMentionOverlay) {
        _dismissMentionOverlay();
      } else if (ref.read(editingMessageProvider) != null) {
        _cancelEdit();
      }
      return;
    }

    // Enter sends, Shift+Enter inserts newline
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      if (!isShiftPressed) {
        // Prevent the default newline insertion
        _submit();
      }
      // Shift+Enter: let the TextField handle the newline naturally
    }
  }

  /// Builds the @mention autocomplete list above the composer row.
  Widget _buildMentionList() {
    final teamId = _teamId;
    if (teamId == null) return const SizedBox.shrink();

    final membersAsync = ref.watch(
      channelMembersProvider(
        (channelId: widget.channelId, teamId: teamId),
      ),
    );

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: membersAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Could not load members',
            style: TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
        ),
        data: (members) {
          final query = _mentionQuery.toLowerCase();
          final filtered = members
              .where((m) =>
                  m.userDisplayName != null &&
                  m.userDisplayName!.toLowerCase().contains(query))
              .toList();

          final items = <Widget>[
            // @everyone option
            if ('everyone'.contains(query) || query.isEmpty)
              _buildMentionItem(
                displayName: '@everyone',
                subtitle: 'Notify all members',
                onTap: _insertEveryoneMention,
              ),
            ...filtered.map((m) => _buildMentionItem(
                  displayName: m.userDisplayName ?? 'Unknown',
                  subtitle: m.role?.displayName,
                  onTap: () => _insertMention(m),
                )),
          ];

          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No members found',
                style: TextStyle(
                  fontSize: 12,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            );
          }

          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: items,
          );
        },
      ),
    );
  }

  /// Builds a single item in the @mention dropdown.
  Widget _buildMentionItem({
    required String displayName,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  CodeOpsColors.primary.withValues(alpha: 0.3),
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CodeOpsColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
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
          ],
        ),
      ),
    );
  }

  /// Returns a MIME type for a file name based on extension.
  static String _mimeFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'application/octet-stream';

    final ext = name.substring(dot + 1).toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'bmp' => 'image/bmp',
      'ico' => 'image/x-icon',
      'pdf' => 'application/pdf',
      'zip' => 'application/zip',
      'tar' => 'application/x-tar',
      'gz' => 'application/gzip',
      '7z' => 'application/x-7z-compressed',
      'rar' => 'application/x-rar-compressed',
      'json' => 'application/json',
      'xml' => 'application/xml',
      'yaml' || 'yml' => 'text/yaml',
      'html' => 'text/html',
      'css' => 'text/css',
      'js' => 'application/javascript',
      'txt' || 'log' || 'md' || 'csv' => 'text/plain',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'avi' => 'video/x-msvideo',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      _ => 'application/octet-stream',
    };
  }
}
