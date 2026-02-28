// Tests for MCP enum types.
//
// Verifies serialization (toJson), deserialization (fromJson),
// invalid value handling, and display names for all MCP enums.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SessionStatus
  // ---------------------------------------------------------------------------
  group('SessionStatus', () {
    test('has 7 values', () {
      expect(SessionStatus.values.length, 7);
    });

    group('toJson', () {
      test('maps initializing to INITIALIZING', () {
        expect(SessionStatus.initializing.toJson(), 'INITIALIZING');
      });

      test('maps active to ACTIVE', () {
        expect(SessionStatus.active.toJson(), 'ACTIVE');
      });

      test('maps completing to COMPLETING', () {
        expect(SessionStatus.completing.toJson(), 'COMPLETING');
      });

      test('maps completed to COMPLETED', () {
        expect(SessionStatus.completed.toJson(), 'COMPLETED');
      });

      test('maps failed to FAILED', () {
        expect(SessionStatus.failed.toJson(), 'FAILED');
      });

      test('maps timedOut to TIMED_OUT', () {
        expect(SessionStatus.timedOut.toJson(), 'TIMED_OUT');
      });

      test('maps cancelled to CANCELLED', () {
        expect(SessionStatus.cancelled.toJson(), 'CANCELLED');
      });
    });

    group('fromJson', () {
      test('maps INITIALIZING to initializing', () {
        expect(
          SessionStatus.fromJson('INITIALIZING'),
          SessionStatus.initializing,
        );
      });

      test('maps ACTIVE to active', () {
        expect(SessionStatus.fromJson('ACTIVE'), SessionStatus.active);
      });

      test('maps COMPLETING to completing', () {
        expect(
          SessionStatus.fromJson('COMPLETING'),
          SessionStatus.completing,
        );
      });

      test('maps COMPLETED to completed', () {
        expect(SessionStatus.fromJson('COMPLETED'), SessionStatus.completed);
      });

      test('maps FAILED to failed', () {
        expect(SessionStatus.fromJson('FAILED'), SessionStatus.failed);
      });

      test('maps TIMED_OUT to timedOut', () {
        expect(SessionStatus.fromJson('TIMED_OUT'), SessionStatus.timedOut);
      });

      test('maps CANCELLED to cancelled', () {
        expect(SessionStatus.fromJson('CANCELLED'), SessionStatus.cancelled);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => SessionStatus.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('initializing returns Initializing', () {
        expect(SessionStatus.initializing.displayName, 'Initializing');
      });

      test('active returns Active', () {
        expect(SessionStatus.active.displayName, 'Active');
      });

      test('timedOut returns Timed Out', () {
        expect(SessionStatus.timedOut.displayName, 'Timed Out');
      });
    });

    group('JsonConverter', () {
      test('SessionStatusConverter round-trips', () {
        const converter = SessionStatusConverter();
        for (final value in SessionStatus.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // DocumentType
  // ---------------------------------------------------------------------------
  group('DocumentType', () {
    test('has 6 values', () {
      expect(DocumentType.values.length, 6);
    });

    group('toJson / fromJson round-trip', () {
      test('all values round-trip correctly', () {
        for (final value in DocumentType.values) {
          expect(DocumentType.fromJson(value.toJson()), value);
        }
      });
    });

    group('fromJson', () {
      test('maps CLAUDE_MD to claudeMd', () {
        expect(DocumentType.fromJson('CLAUDE_MD'), DocumentType.claudeMd);
      });

      test('maps CONVENTIONS_MD to conventionsMd', () {
        expect(
          DocumentType.fromJson('CONVENTIONS_MD'),
          DocumentType.conventionsMd,
        );
      });

      test('maps ARCHITECTURE_MD to architectureMd', () {
        expect(
          DocumentType.fromJson('ARCHITECTURE_MD'),
          DocumentType.architectureMd,
        );
      });

      test('maps AUDIT_MD to auditMd', () {
        expect(DocumentType.fromJson('AUDIT_MD'), DocumentType.auditMd);
      });

      test('maps OPENAPI_YAML to openapiYaml', () {
        expect(
          DocumentType.fromJson('OPENAPI_YAML'),
          DocumentType.openapiYaml,
        );
      });

      test('maps CUSTOM to custom', () {
        expect(DocumentType.fromJson('CUSTOM'), DocumentType.custom);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => DocumentType.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('claudeMd returns CLAUDE.md', () {
        expect(DocumentType.claudeMd.displayName, 'CLAUDE.md');
      });

      test('custom returns Custom', () {
        expect(DocumentType.custom.displayName, 'Custom');
      });
    });

    group('JsonConverter', () {
      test('DocumentTypeConverter round-trips', () {
        const converter = DocumentTypeConverter();
        for (final value in DocumentType.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ToolCallStatus
  // ---------------------------------------------------------------------------
  group('ToolCallStatus', () {
    test('has 4 values', () {
      expect(ToolCallStatus.values.length, 4);
    });

    group('toJson', () {
      test('maps success to SUCCESS', () {
        expect(ToolCallStatus.success.toJson(), 'SUCCESS');
      });

      test('maps failure to FAILURE', () {
        expect(ToolCallStatus.failure.toJson(), 'FAILURE');
      });

      test('maps timeout to TIMEOUT', () {
        expect(ToolCallStatus.timeout.toJson(), 'TIMEOUT');
      });

      test('maps unauthorized to UNAUTHORIZED', () {
        expect(ToolCallStatus.unauthorized.toJson(), 'UNAUTHORIZED');
      });
    });

    group('fromJson', () {
      test('maps SUCCESS to success', () {
        expect(ToolCallStatus.fromJson('SUCCESS'), ToolCallStatus.success);
      });

      test('maps FAILURE to failure', () {
        expect(ToolCallStatus.fromJson('FAILURE'), ToolCallStatus.failure);
      });

      test('maps TIMEOUT to timeout', () {
        expect(ToolCallStatus.fromJson('TIMEOUT'), ToolCallStatus.timeout);
      });

      test('maps UNAUTHORIZED to unauthorized', () {
        expect(
          ToolCallStatus.fromJson('UNAUTHORIZED'),
          ToolCallStatus.unauthorized,
        );
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => ToolCallStatus.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('success returns Success', () {
        expect(ToolCallStatus.success.displayName, 'Success');
      });

      test('unauthorized returns Unauthorized', () {
        expect(ToolCallStatus.unauthorized.displayName, 'Unauthorized');
      });
    });

    group('JsonConverter', () {
      test('ToolCallStatusConverter round-trips', () {
        const converter = ToolCallStatusConverter();
        for (final value in ToolCallStatus.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ActivityType
  // ---------------------------------------------------------------------------
  group('ActivityType', () {
    test('has 6 values', () {
      expect(ActivityType.values.length, 6);
    });

    group('toJson / fromJson round-trip', () {
      test('all values round-trip correctly', () {
        for (final value in ActivityType.values) {
          expect(ActivityType.fromJson(value.toJson()), value);
        }
      });
    });

    group('fromJson', () {
      test('maps SESSION_COMPLETED to sessionCompleted', () {
        expect(
          ActivityType.fromJson('SESSION_COMPLETED'),
          ActivityType.sessionCompleted,
        );
      });

      test('maps IMPACT_DETECTED to impactDetected', () {
        expect(
          ActivityType.fromJson('IMPACT_DETECTED'),
          ActivityType.impactDetected,
        );
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => ActivityType.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('sessionCompleted returns Session Completed', () {
        expect(ActivityType.sessionCompleted.displayName, 'Session Completed');
      });

      test('impactDetected returns Impact Detected', () {
        expect(ActivityType.impactDetected.displayName, 'Impact Detected');
      });
    });

    group('JsonConverter', () {
      test('ActivityTypeConverter round-trips', () {
        const converter = ActivityTypeConverter();
        for (final value in ActivityType.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // TokenStatus
  // ---------------------------------------------------------------------------
  group('TokenStatus', () {
    test('has 3 values', () {
      expect(TokenStatus.values.length, 3);
    });

    group('toJson', () {
      test('maps active to ACTIVE', () {
        expect(TokenStatus.active.toJson(), 'ACTIVE');
      });

      test('maps revoked to REVOKED', () {
        expect(TokenStatus.revoked.toJson(), 'REVOKED');
      });

      test('maps expired to EXPIRED', () {
        expect(TokenStatus.expired.toJson(), 'EXPIRED');
      });
    });

    group('fromJson', () {
      test('maps ACTIVE to active', () {
        expect(TokenStatus.fromJson('ACTIVE'), TokenStatus.active);
      });

      test('maps REVOKED to revoked', () {
        expect(TokenStatus.fromJson('REVOKED'), TokenStatus.revoked);
      });

      test('maps EXPIRED to expired', () {
        expect(TokenStatus.fromJson('EXPIRED'), TokenStatus.expired);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => TokenStatus.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('active returns Active', () {
        expect(TokenStatus.active.displayName, 'Active');
      });

      test('revoked returns Revoked', () {
        expect(TokenStatus.revoked.displayName, 'Revoked');
      });

      test('expired returns Expired', () {
        expect(TokenStatus.expired.displayName, 'Expired');
      });
    });

    group('JsonConverter', () {
      test('TokenStatusConverter round-trips', () {
        const converter = TokenStatusConverter();
        for (final value in TokenStatus.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // McpTransport
  // ---------------------------------------------------------------------------
  group('McpTransport', () {
    test('has 3 values', () {
      expect(McpTransport.values.length, 3);
    });

    group('toJson', () {
      test('maps sse to SSE', () {
        expect(McpTransport.sse.toJson(), 'SSE');
      });

      test('maps http to HTTP', () {
        expect(McpTransport.http.toJson(), 'HTTP');
      });

      test('maps stdio to STDIO', () {
        expect(McpTransport.stdio.toJson(), 'STDIO');
      });
    });

    group('fromJson', () {
      test('maps SSE to sse', () {
        expect(McpTransport.fromJson('SSE'), McpTransport.sse);
      });

      test('maps HTTP to http', () {
        expect(McpTransport.fromJson('HTTP'), McpTransport.http);
      });

      test('maps STDIO to stdio', () {
        expect(McpTransport.fromJson('STDIO'), McpTransport.stdio);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => McpTransport.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('sse returns SSE', () {
        expect(McpTransport.sse.displayName, 'SSE');
      });

      test('http returns HTTP', () {
        expect(McpTransport.http.displayName, 'HTTP');
      });

      test('stdio returns STDIO', () {
        expect(McpTransport.stdio.displayName, 'STDIO');
      });
    });

    group('JsonConverter', () {
      test('McpTransportConverter round-trips', () {
        const converter = McpTransportConverter();
        for (final value in McpTransport.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // AuthorType
  // ---------------------------------------------------------------------------
  group('AuthorType', () {
    test('has 2 values', () {
      expect(AuthorType.values.length, 2);
    });

    group('toJson', () {
      test('maps human to HUMAN', () {
        expect(AuthorType.human.toJson(), 'HUMAN');
      });

      test('maps ai to AI', () {
        expect(AuthorType.ai.toJson(), 'AI');
      });
    });

    group('fromJson', () {
      test('maps HUMAN to human', () {
        expect(AuthorType.fromJson('HUMAN'), AuthorType.human);
      });

      test('maps AI to ai', () {
        expect(AuthorType.fromJson('AI'), AuthorType.ai);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => AuthorType.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('human returns Human', () {
        expect(AuthorType.human.displayName, 'Human');
      });

      test('ai returns AI', () {
        expect(AuthorType.ai.displayName, 'AI');
      });
    });

    group('JsonConverter', () {
      test('AuthorTypeConverter round-trips', () {
        const converter = AuthorTypeConverter();
        for (final value in AuthorType.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // McpEnvironment
  // ---------------------------------------------------------------------------
  group('McpEnvironment', () {
    test('has 4 values', () {
      expect(McpEnvironment.values.length, 4);
    });

    group('toJson', () {
      test('maps local to LOCAL', () {
        expect(McpEnvironment.local.toJson(), 'LOCAL');
      });

      test('maps development to DEVELOPMENT', () {
        expect(McpEnvironment.development.toJson(), 'DEVELOPMENT');
      });

      test('maps staging to STAGING', () {
        expect(McpEnvironment.staging.toJson(), 'STAGING');
      });

      test('maps production to PRODUCTION', () {
        expect(McpEnvironment.production.toJson(), 'PRODUCTION');
      });
    });

    group('fromJson', () {
      test('maps LOCAL to local', () {
        expect(McpEnvironment.fromJson('LOCAL'), McpEnvironment.local);
      });

      test('maps DEVELOPMENT to development', () {
        expect(
          McpEnvironment.fromJson('DEVELOPMENT'),
          McpEnvironment.development,
        );
      });

      test('maps STAGING to staging', () {
        expect(McpEnvironment.fromJson('STAGING'), McpEnvironment.staging);
      });

      test('maps PRODUCTION to production', () {
        expect(
          McpEnvironment.fromJson('PRODUCTION'),
          McpEnvironment.production,
        );
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => McpEnvironment.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('local returns Local', () {
        expect(McpEnvironment.local.displayName, 'Local');
      });

      test('development returns Development', () {
        expect(McpEnvironment.development.displayName, 'Development');
      });

      test('staging returns Staging', () {
        expect(McpEnvironment.staging.displayName, 'Staging');
      });

      test('production returns Production', () {
        expect(McpEnvironment.production.displayName, 'Production');
      });
    });

    group('JsonConverter', () {
      test('McpEnvironmentConverter round-trips', () {
        const converter = McpEnvironmentConverter();
        for (final value in McpEnvironment.values) {
          expect(converter.fromJson(converter.toJson(value)), value);
        }
      });
    });
  });
}
