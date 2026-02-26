/// Tests for file attachment rendering in [RelayMessageBubble].
///
/// Verifies image thumbnail rendering, file type icon display,
/// formatted file sizes, download icon presence, and the
/// [_formatFileSize] helper via rendered output.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/widgets/relay/relay_message_bubble.dart';

Widget _createBubble(MessageResponse message, {bool isOwnMessage = false}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RelayMessageBubble(
            message: message,
            isOwnMessage: isOwnMessage,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('File attachment rendering', () {
    testWidgets('non-image attachment shows file type icon and download icon',
        (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-1',
        senderDisplayName: 'Alice',
        content: 'Check this out',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-1',
            fileName: 'report.pdf',
            contentType: 'application/pdf',
            fileSizeBytes: 2048,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('image attachment renders thumbnail container', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-2',
        senderDisplayName: 'Bob',
        content: 'A photo',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-2',
            fileName: 'photo.png',
            contentType: 'image/png',
            fileSizeBytes: 10240,
            // No thumbnail/download URL — will show fallback card
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      // Fallback card should show file name and icon
      expect(find.text('photo.png'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('formatted file size shows KB', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-3',
        senderDisplayName: 'Carol',
        content: 'File',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-3',
            fileName: 'data.json',
            contentType: 'application/json',
            fileSizeBytes: 3072,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.text('3.0 KB'), findsOneWidget);
    });

    testWidgets('formatted file size shows MB for large files', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-4',
        senderDisplayName: 'Dave',
        content: 'Big file',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-4',
            fileName: 'video.mp4',
            contentType: 'video/mp4',
            fileSizeBytes: 5242880, // 5 MB
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.text('5.0 MB'), findsOneWidget);
    });

    testWidgets('formatted file size shows B for tiny files', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-5',
        senderDisplayName: 'Eve',
        content: 'Tiny',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-5',
            fileName: 'note.txt',
            contentType: 'text/plain',
            fileSizeBytes: 42,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.text('42 B'), findsOneWidget);
    });

    testWidgets('code file uses code icon', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-6',
        senderDisplayName: 'Frank',
        content: 'Source code',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-6',
            fileName: 'main.dart',
            fileSizeBytes: 1024,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('zip file uses folder_zip icon', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-7',
        senderDisplayName: 'Grace',
        content: 'Archive',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-7',
            fileName: 'bundle.zip',
            contentType: 'application/zip',
            fileSizeBytes: 8192,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_zip), findsOneWidget);
    });

    testWidgets('multiple attachments render multiple cards', (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-8',
        senderDisplayName: 'Heidi',
        content: 'Multiple files',
        messageType: MessageType.text,
        attachments: [
          FileAttachmentResponse(
            id: 'att-8a',
            fileName: 'readme.md',
            fileSizeBytes: 512,
          ),
          FileAttachmentResponse(
            id: 'att-8b',
            fileName: 'config.yaml',
            fileSizeBytes: 256,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      expect(find.text('readme.md'), findsOneWidget);
      expect(find.text('config.yaml'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsNWidgets(2));
    });

    testWidgets('file message type with image attachment shows thumbnail',
        (tester) async {
      const msg = MessageResponse(
        id: 'att-msg-9',
        senderDisplayName: 'Ivan',
        content: '',
        messageType: MessageType.file,
        attachments: [
          FileAttachmentResponse(
            id: 'att-9',
            fileName: 'screenshot.png',
            contentType: 'image/png',
            fileSizeBytes: 20480,
          ),
        ],
      );
      await tester.pumpWidget(_createBubble(msg));
      await tester.pumpAndSettle();

      // Fallback image card with icon since no URL
      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('screenshot.png'), findsOneWidget);
    });
  });
}
