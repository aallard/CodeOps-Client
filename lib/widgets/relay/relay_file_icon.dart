/// File type icon utility for the Relay module.
///
/// Maps content types and file extensions to appropriate Material
/// icons for display in attachment cards and file messages.
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Maps file content types and extensions to Material icons.
///
/// Used by [RelayMessageBubble] attachment cards and
/// [RelayFileUploadIndicator] to show contextual file type icons.
/// Accepts either a MIME content type (`image/png`) or a file name
/// (`report.pdf`) and returns the best-matching icon.
class RelayFileIcon extends StatelessWidget {
  /// MIME content type (e.g. `image/png`, `application/pdf`).
  final String? contentType;

  /// File name used as fallback when [contentType] is null or generic.
  final String? fileName;

  /// Icon size. Defaults to 20.
  final double size;

  /// Icon color. Defaults to [CodeOpsColors.textTertiary].
  final Color? color;

  /// Creates a [RelayFileIcon].
  const RelayFileIcon({
    this.contentType,
    this.fileName,
    this.size = 20,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconForFile(contentType: contentType, fileName: fileName),
      size: size,
      color: color ?? CodeOpsColors.textTertiary,
    );
  }

  /// Returns the best-matching [IconData] for a file.
  ///
  /// Checks MIME content type first, then falls back to file extension.
  /// Returns [Icons.insert_drive_file] if no match is found.
  static IconData iconForFile({String? contentType, String? fileName}) {
    // Check content type first.
    if (contentType != null) {
      final ct = contentType.toLowerCase();
      if (ct.startsWith('image/')) return Icons.image;
      if (ct.startsWith('video/')) return Icons.videocam;
      if (ct.startsWith('audio/')) return Icons.audiotrack;
      if (ct == 'application/pdf') return Icons.picture_as_pdf;
      if (ct == 'application/zip' ||
          ct == 'application/x-tar' ||
          ct == 'application/gzip' ||
          ct == 'application/x-7z-compressed' ||
          ct == 'application/x-rar-compressed') {
        return Icons.folder_zip;
      }
      if (ct == 'application/json' ||
          ct == 'application/xml' ||
          ct == 'application/javascript' ||
          ct == 'text/html' ||
          ct == 'text/css') {
        return Icons.code;
      }
    }

    // Fall back to file extension.
    if (fileName != null) {
      final ext = _extension(fileName);
      return _iconForExtension(ext);
    }

    return Icons.insert_drive_file;
  }

  /// Extracts the lowercase file extension from a file name.
  static String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// Maps a file extension to an icon.
  static IconData _iconForExtension(String ext) {
    return switch (ext) {
      // Images
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'svg' || 'bmp' ||
      'ico' =>
        Icons.image,

      // Video
      'mp4' || 'mov' || 'avi' || 'mkv' || 'webm' => Icons.videocam,

      // Audio
      'mp3' || 'wav' || 'aac' || 'flac' || 'ogg' => Icons.audiotrack,

      // PDF
      'pdf' => Icons.picture_as_pdf,

      // Archives
      'zip' || 'tar' || 'gz' || '7z' || 'rar' => Icons.folder_zip,

      // Code
      'dart' || 'java' || 'py' || 'ts' || 'js' || 'json' || 'yaml' ||
      'yml' || 'xml' || 'html' || 'css' || 'go' || 'rs' || 'c' || 'cpp' ||
      'h' || 'swift' || 'kt' || 'rb' || 'sh' =>
        Icons.code,

      // Text / Documents
      'md' || 'txt' || 'csv' || 'log' || 'rtf' => Icons.description,

      // Spreadsheets
      'xls' || 'xlsx' => Icons.table_chart,

      // Presentations
      'ppt' || 'pptx' => Icons.slideshow,

      // Word docs
      'doc' || 'docx' => Icons.article,

      // Default
      _ => Icons.insert_drive_file,
    };
  }
}
