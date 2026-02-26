/// Tests for [RelayFileUploadIndicator] — upload progress display.
///
/// Verifies rendering of progress bars, status labels, complete/failed
/// states, and empty-state behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/widgets/relay/relay_file_upload_indicator.dart';

Widget _createIndicator({Map<String, FileUploadProgress>? uploads}) {
  return ProviderScope(
    overrides: [
      if (uploads != null)
        uploadProgressProvider.overrideWith((ref) => uploads),
    ],
    child: const MaterialApp(
      home: Scaffold(body: RelayFileUploadIndicator()),
    ),
  );
}

void main() {
  group('RelayFileUploadIndicator', () {
    testWidgets('renders nothing when no uploads', (tester) async {
      await tester.pumpWidget(_createIndicator());
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('renders progress card for each uploading file',
        (tester) async {
      await tester.pumpWidget(_createIndicator(uploads: {
        'photo.png': const FileUploadProgress(
          fileName: 'photo.png',
          bytesSent: 500,
          totalBytes: 1000,
        ),
        'doc.pdf': const FileUploadProgress(
          fileName: 'doc.pdf',
          bytesSent: 0,
          totalBytes: 2000,
        ),
      }));
      await tester.pumpAndSettle();

      expect(find.text('photo.png'), findsOneWidget);
      expect(find.text('doc.pdf'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('shows percentage for in-progress uploads', (tester) async {
      await tester.pumpWidget(_createIndicator(uploads: {
        'data.csv': const FileUploadProgress(
          fileName: 'data.csv',
          bytesSent: 750,
          totalBytes: 1000,
        ),
      }));
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('shows "Complete" for completed uploads', (tester) async {
      await tester.pumpWidget(_createIndicator(uploads: {
        'done.txt': const FileUploadProgress(
          fileName: 'done.txt',
          bytesSent: 500,
          totalBytes: 500,
          isComplete: true,
        ),
      }));
      await tester.pumpAndSettle();

      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('shows "Failed" for failed uploads', (tester) async {
      await tester.pumpWidget(_createIndicator(uploads: {
        'broken.zip': const FileUploadProgress(
          fileName: 'broken.zip',
          bytesSent: 100,
          totalBytes: 1000,
          isFailed: true,
        ),
      }));
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsOneWidget);
    });
  });
}
