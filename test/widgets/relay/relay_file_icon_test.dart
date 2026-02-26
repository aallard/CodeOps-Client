/// Tests for [RelayFileIcon] — file type icon mapping utility.
///
/// Verifies icon resolution from content types and file extensions,
/// including images, code files, PDFs, archives, and fallback behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/relay/relay_file_icon.dart';

void main() {
  group('RelayFileIcon.iconForFile', () {
    test('image content type returns Icons.image', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'image/png'),
        Icons.image,
      );
      expect(
        RelayFileIcon.iconForFile(contentType: 'image/jpeg'),
        Icons.image,
      );
    });

    test('video content type returns Icons.videocam', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'video/mp4'),
        Icons.videocam,
      );
    });

    test('audio content type returns Icons.audiotrack', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'audio/mpeg'),
        Icons.audiotrack,
      );
    });

    test('PDF content type returns Icons.picture_as_pdf', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'application/pdf'),
        Icons.picture_as_pdf,
      );
    });

    test('archive content type returns Icons.folder_zip', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'application/zip'),
        Icons.folder_zip,
      );
      expect(
        RelayFileIcon.iconForFile(contentType: 'application/gzip'),
        Icons.folder_zip,
      );
    });

    test('code content types return Icons.code', () {
      expect(
        RelayFileIcon.iconForFile(contentType: 'application/json'),
        Icons.code,
      );
      expect(
        RelayFileIcon.iconForFile(contentType: 'text/html'),
        Icons.code,
      );
    });

    test('file extension fallback for images', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'photo.jpg'),
        Icons.image,
      );
      expect(
        RelayFileIcon.iconForFile(fileName: 'screen.PNG'),
        Icons.image,
      );
    });

    test('file extension fallback for code files', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'main.dart'),
        Icons.code,
      );
      expect(
        RelayFileIcon.iconForFile(fileName: 'config.yaml'),
        Icons.code,
      );
    });

    test('file extension fallback for text files', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'README.md'),
        Icons.description,
      );
      expect(
        RelayFileIcon.iconForFile(fileName: 'data.csv'),
        Icons.description,
      );
    });

    test('file extension fallback for PDF', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'report.pdf'),
        Icons.picture_as_pdf,
      );
    });

    test('file extension fallback for archives', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'bundle.zip'),
        Icons.folder_zip,
      );
      expect(
        RelayFileIcon.iconForFile(fileName: 'backup.tar'),
        Icons.folder_zip,
      );
    });

    test('file extension fallback for spreadsheets', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'data.xlsx'),
        Icons.table_chart,
      );
    });

    test('file extension fallback for presentations', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'slides.pptx'),
        Icons.slideshow,
      );
    });

    test('file extension fallback for Word docs', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'doc.docx'),
        Icons.article,
      );
    });

    test('unknown extension returns default icon', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'data.xyz'),
        Icons.insert_drive_file,
      );
    });

    test('no extension returns default icon', () {
      expect(
        RelayFileIcon.iconForFile(fileName: 'Makefile'),
        Icons.insert_drive_file,
      );
    });

    test('no content type and no file name returns default icon', () {
      expect(
        RelayFileIcon.iconForFile(),
        Icons.insert_drive_file,
      );
    });

    test('content type takes precedence over file name', () {
      // Content type says PDF, file name says .txt — PDF wins.
      expect(
        RelayFileIcon.iconForFile(
            contentType: 'application/pdf', fileName: 'readme.txt'),
        Icons.picture_as_pdf,
      );
    });
  });

  group('RelayFileIcon widget', () {
    testWidgets('renders correct icon for PDF', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RelayFileIcon(fileName: 'report.pdf', size: 24),
          ),
        ),
      );

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('renders correct icon for image content type',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RelayFileIcon(contentType: 'image/png', size: 24),
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('renders default icon when no info provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RelayFileIcon(size: 24)),
        ),
      );

      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
    });
  });
}
