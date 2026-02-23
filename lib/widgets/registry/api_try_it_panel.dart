/// Try-it-out panel for the API Docs viewer.
///
/// Allows users to fill in endpoint parameters and execute a live request,
/// displaying the response status, headers, and body.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/openapi_spec.dart';
import '../../theme/colors.dart';

/// Interactive panel for testing an API endpoint.
///
/// Displays parameter input fields, an execute button, and the response.
/// Uses [Dio] to make the actual HTTP request.
class ApiTryItPanel extends StatefulWidget {
  /// The endpoint to test.
  final OpenApiEndpoint endpoint;

  /// Base URL for the request.
  final String baseUrl;

  /// Creates an [ApiTryItPanel].
  const ApiTryItPanel({
    super.key,
    required this.endpoint,
    required this.baseUrl,
  });

  @override
  State<ApiTryItPanel> createState() => _ApiTryItPanelState();
}

class _ApiTryItPanelState extends State<ApiTryItPanel> {
  final _paramControllers = <String, TextEditingController>{};
  final _bodyController = TextEditingController();
  bool _loading = false;
  int? _statusCode;
  String? _responseBody;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final param in widget.endpoint.parameters) {
      _paramControllers[param.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.endpoint;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Try It Out',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Parameter fields.
          if (ep.parameters.isNotEmpty)
            ...ep.parameters.map(_buildParamField),

          // Request body.
          if (ep.requestBody != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Request Body (JSON)',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 100,
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Fira Code',
                ),
                decoration: InputDecoration(
                  hintText: '{}',
                  hintStyle: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 12,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Execute button.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _execute,
              icon: _loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CodeOpsColors.textPrimary,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 16),
              label: Text(_loading ? 'Sending...' : 'Execute'),
              style: FilledButton.styleFrom(
                backgroundColor: CodeOpsColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          // Response display.
          if (_statusCode != null || _error != null) ...[
            const SizedBox(height: 12),
            const Divider(color: CodeOpsColors.divider, height: 1),
            const SizedBox(height: 8),
            _buildResponse(),
          ],
        ],
      ),
    );
  }

  Widget _buildParamField(OpenApiParameter param) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    param.name,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Fira Code',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (param.required)
                  const Text(' *',
                      style: TextStyle(
                          color: CodeOpsColors.error, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 30,
              child: TextField(
                controller: _paramControllers[param.name],
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: param.schema?.type ?? 'value',
                  hintStyle: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 12,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: CodeOpsColors.border),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponse() {
    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: CodeOpsColors.error, fontSize: 12),
      );
    }

    final statusColor = switch (_statusCode!) {
      >= 200 && < 300 => CodeOpsColors.success,
      >= 300 && < 400 => CodeOpsColors.secondary,
      >= 400 && < 500 => CodeOpsColors.warning,
      _ => CodeOpsColors.error,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Status: ',
              style: TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$_statusCode',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fira Code',
                ),
              ),
            ),
          ],
        ),
        if (_responseBody != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CodeOpsColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _responseBody!,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Fira Code',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _execute() async {
    setState(() {
      _loading = true;
      _statusCode = null;
      _responseBody = null;
      _error = null;
    });

    final ep = widget.endpoint;

    // Build URL with path parameters.
    var url = '${widget.baseUrl}${ep.path}';
    final queryParams = <String, String>{};

    for (final param in ep.parameters) {
      final value = _paramControllers[param.name]?.text ?? '';
      if (value.isEmpty) continue;

      if (param.location == 'path') {
        url = url.replaceAll('{${param.name}}', value);
      } else if (param.location == 'query') {
        queryParams[param.name] = value;
      }
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (_) => true,
    ));

    try {
      final Response<dynamic> response;
      final body = _bodyController.text.isNotEmpty
          ? jsonDecode(_bodyController.text)
          : null;

      response = await dio.request<dynamic>(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        data: body,
        options: Options(method: ep.method),
      );

      String formattedBody;
      try {
        final encoder = const JsonEncoder.withIndent('  ');
        formattedBody = encoder.convert(response.data);
      } catch (_) {
        formattedBody = response.data?.toString() ?? '';
      }

      if (mounted) {
        setState(() {
          _statusCode = response.statusCode;
          _responseBody = formattedBody;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Request failed: $e';
        });
      }
    } finally {
      dio.close();
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
