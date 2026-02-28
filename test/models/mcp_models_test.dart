// Tests for MCP model classes.
//
// Verifies const constructors, field assignment, and type identity
// for all 13 MCP model classes.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/mcp_enums.dart';
import 'package:codeops/models/mcp_models.dart';

void main() {
  // ══════════════════════════════════════════════════════════════
  //  SESSION MODELS
  // ══════════════════════════════════════════════════════════════

  group('McpSession', () {
    test('const constructor with all null optional fields', () {
      const instance = McpSession();
      expect(instance, isA<McpSession>());
    });

    test('constructor with populated fields', () {
      final instance = McpSession(
        id: 'sess-1',
        status: SessionStatus.active,
        projectName: 'CodeOps-Server',
        developerName: 'Adam',
        environment: McpEnvironment.local,
        transport: McpTransport.http,
        startedAt: DateTime.utc(2026),
        completedAt: DateTime.utc(2026),
        totalToolCalls: 42,
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<McpSession>());
      expect(instance.id, 'sess-1');
      expect(instance.status, SessionStatus.active);
      expect(instance.projectName, 'CodeOps-Server');
      expect(instance.developerName, 'Adam');
      expect(instance.environment, McpEnvironment.local);
      expect(instance.transport, McpTransport.http);
      expect(instance.totalToolCalls, 42);
    });
  });

  group('McpSessionDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = McpSessionDetail();
      expect(instance, isA<McpSessionDetail>());
    });

    test('constructor with populated fields', () {
      final instance = McpSessionDetail(
        id: 'sess-1',
        status: SessionStatus.completed,
        projectName: 'CodeOps-Server',
        developerName: 'Adam',
        environment: McpEnvironment.development,
        transport: McpTransport.sse,
        startedAt: DateTime.utc(2026),
        completedAt: DateTime.utc(2026),
        lastActivityAt: DateTime.utc(2026),
        timeoutMinutes: 30,
        totalToolCalls: 10,
        errorMessage: null,
        toolCalls: const [],
        result: const SessionResult(),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<McpSessionDetail>());
      expect(instance.id, 'sess-1');
      expect(instance.status, SessionStatus.completed);
      expect(instance.environment, McpEnvironment.development);
      expect(instance.transport, McpTransport.sse);
      expect(instance.timeoutMinutes, 30);
      expect(instance.totalToolCalls, 10);
      expect(instance.toolCalls, isEmpty);
      expect(instance.result, isA<SessionResult>());
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  TOOL CALL & RESULT MODELS
  // ══════════════════════════════════════════════════════════════

  group('SessionToolCall', () {
    test('const constructor with all null optional fields', () {
      const instance = SessionToolCall();
      expect(instance, isA<SessionToolCall>());
    });

    test('constructor with populated fields', () {
      final instance = SessionToolCall(
        id: 'tc-1',
        toolName: 'registry.listServices',
        toolCategory: 'registry',
        requestJson: '{"teamId":"t1"}',
        responseJson: '{"services":[]}',
        status: ToolCallStatus.success,
        durationMs: 150,
        errorMessage: null,
        calledAt: DateTime.utc(2026),
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<SessionToolCall>());
      expect(instance.id, 'tc-1');
      expect(instance.toolName, 'registry.listServices');
      expect(instance.toolCategory, 'registry');
      expect(instance.status, ToolCallStatus.success);
      expect(instance.durationMs, 150);
    });
  });

  group('SessionResult', () {
    test('const constructor with all null optional fields', () {
      const instance = SessionResult();
      expect(instance, isA<SessionResult>());
    });

    test('constructor with populated fields', () {
      final instance = SessionResult(
        id: 'res-1',
        summary: 'Added user authentication',
        commitHashesJson: '["abc123"]',
        filesChangedJson: '["src/Auth.java"]',
        endpointsChangedJson: '["POST /auth/login"]',
        testsAdded: 5,
        testCoverage: 92.5,
        linesAdded: 200,
        linesRemoved: 50,
        dependencyChangesJson: '[]',
        durationMinutes: 15,
        tokenUsage: 25000,
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<SessionResult>());
      expect(instance.id, 'res-1');
      expect(instance.summary, 'Added user authentication');
      expect(instance.testsAdded, 5);
      expect(instance.testCoverage, 92.5);
      expect(instance.linesAdded, 200);
      expect(instance.linesRemoved, 50);
      expect(instance.durationMinutes, 15);
      expect(instance.tokenUsage, 25000);
    });
  });

  group('ToolCallSummary', () {
    test('const constructor with all null optional fields', () {
      const instance = ToolCallSummary();
      expect(instance, isA<ToolCallSummary>());
    });

    test('constructor with populated fields', () {
      const instance = ToolCallSummary(
        toolName: 'fleet.startContainer',
        callCount: 7,
      );
      expect(instance, isA<ToolCallSummary>());
      expect(instance.toolName, 'fleet.startContainer');
      expect(instance.callCount, 7);
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  DEVELOPER PROFILE & TOKEN MODELS
  // ══════════════════════════════════════════════════════════════

  group('DeveloperProfile', () {
    test('const constructor with all null optional fields', () {
      const instance = DeveloperProfile();
      expect(instance, isA<DeveloperProfile>());
    });

    test('constructor with populated fields', () {
      final instance = DeveloperProfile(
        id: 'dp-1',
        displayName: 'Adam Allard',
        bio: 'Full-stack engineer',
        defaultEnvironment: McpEnvironment.local,
        preferencesJson: '{"theme":"dark"}',
        timezone: 'America/Chicago',
        isActive: true,
        teamId: 'team-1',
        userId: 'user-1',
        userDisplayName: 'Adam',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<DeveloperProfile>());
      expect(instance.id, 'dp-1');
      expect(instance.displayName, 'Adam Allard');
      expect(instance.defaultEnvironment, McpEnvironment.local);
      expect(instance.isActive, true);
      expect(instance.timezone, 'America/Chicago');
      expect(instance.teamId, 'team-1');
      expect(instance.userId, 'user-1');
    });
  });

  group('McpApiToken', () {
    test('const constructor with all null optional fields', () {
      const instance = McpApiToken();
      expect(instance, isA<McpApiToken>());
    });

    test('constructor with populated fields', () {
      final instance = McpApiToken(
        id: 'tok-1',
        name: 'CI Token',
        tokenPrefix: 'mcp_a1b2',
        status: TokenStatus.active,
        lastUsedAt: DateTime.utc(2026),
        expiresAt: DateTime.utc(2026, 12, 31),
        scopesJson: '["registry","fleet"]',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<McpApiToken>());
      expect(instance.id, 'tok-1');
      expect(instance.name, 'CI Token');
      expect(instance.tokenPrefix, 'mcp_a1b2');
      expect(instance.status, TokenStatus.active);
      expect(instance.scopesJson, '["registry","fleet"]');
    });
  });

  group('McpApiTokenCreated', () {
    test('const constructor with all null optional fields', () {
      const instance = McpApiTokenCreated();
      expect(instance, isA<McpApiTokenCreated>());
    });

    test('constructor with populated fields', () {
      final instance = McpApiTokenCreated(
        id: 'tok-1',
        name: 'CI Token',
        tokenPrefix: 'mcp_a1b2',
        rawToken: 'mcp_a1b2c3d4e5f6g7h8i9j0',
        status: TokenStatus.active,
        expiresAt: DateTime.utc(2026, 12, 31),
        scopesJson: '["registry"]',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<McpApiTokenCreated>());
      expect(instance.id, 'tok-1');
      expect(instance.rawToken, 'mcp_a1b2c3d4e5f6g7h8i9j0');
      expect(instance.status, TokenStatus.active);
      expect(instance.tokenPrefix, 'mcp_a1b2');
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  PROJECT DOCUMENT MODELS
  // ══════════════════════════════════════════════════════════════

  group('ProjectDocument', () {
    test('const constructor with all null optional fields', () {
      const instance = ProjectDocument();
      expect(instance, isA<ProjectDocument>());
    });

    test('constructor with populated fields', () {
      final instance = ProjectDocument(
        id: 'doc-1',
        documentType: DocumentType.claudeMd,
        customName: null,
        lastAuthorType: AuthorType.ai,
        lastSessionId: 'sess-1',
        isFlagged: false,
        flagReason: null,
        projectId: 'proj-1',
        lastUpdatedByName: 'Claude',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<ProjectDocument>());
      expect(instance.id, 'doc-1');
      expect(instance.documentType, DocumentType.claudeMd);
      expect(instance.lastAuthorType, AuthorType.ai);
      expect(instance.isFlagged, false);
      expect(instance.projectId, 'proj-1');
    });
  });

  group('ProjectDocumentDetail', () {
    test('const constructor with all null optional fields', () {
      const instance = ProjectDocumentDetail();
      expect(instance, isA<ProjectDocumentDetail>());
    });

    test('constructor with populated fields', () {
      final instance = ProjectDocumentDetail(
        id: 'doc-1',
        documentType: DocumentType.conventionsMd,
        customName: null,
        currentContent: '# Conventions\n\nUse camelCase.',
        lastAuthorType: AuthorType.human,
        lastSessionId: null,
        isFlagged: true,
        flagReason: 'Stale after refactor',
        projectId: 'proj-1',
        lastUpdatedByName: 'Adam',
        versions: const [],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(instance, isA<ProjectDocumentDetail>());
      expect(instance.id, 'doc-1');
      expect(instance.documentType, DocumentType.conventionsMd);
      expect(instance.currentContent, contains('camelCase'));
      expect(instance.lastAuthorType, AuthorType.human);
      expect(instance.isFlagged, true);
      expect(instance.flagReason, 'Stale after refactor');
      expect(instance.versions, isEmpty);
    });
  });

  group('ProjectDocumentVersion', () {
    test('const constructor with all null optional fields', () {
      const instance = ProjectDocumentVersion();
      expect(instance, isA<ProjectDocumentVersion>());
    });

    test('constructor with populated fields', () {
      final instance = ProjectDocumentVersion(
        id: 'ver-1',
        versionNumber: 3,
        content: '# Updated content',
        authorType: AuthorType.ai,
        commitHash: 'abc123def456',
        changeDescription: 'Added error handling section',
        authorName: 'Claude',
        sessionId: 'sess-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<ProjectDocumentVersion>());
      expect(instance.id, 'ver-1');
      expect(instance.versionNumber, 3);
      expect(instance.authorType, AuthorType.ai);
      expect(instance.commitHash, 'abc123def456');
      expect(instance.changeDescription, 'Added error handling section');
      expect(instance.authorName, 'Claude');
      expect(instance.sessionId, 'sess-1');
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  ACTIVITY FEED MODEL
  // ══════════════════════════════════════════════════════════════

  group('ActivityFeedEntry', () {
    test('const constructor with all null optional fields', () {
      const instance = ActivityFeedEntry();
      expect(instance, isA<ActivityFeedEntry>());
    });

    test('constructor with populated fields', () {
      final instance = ActivityFeedEntry(
        id: 'act-1',
        activityType: ActivityType.sessionCompleted,
        title: 'Session completed',
        detail: 'Added 5 tests and 200 lines',
        sourceModule: 'mcp',
        sourceEntityId: 'sess-1',
        projectName: 'CodeOps-Server',
        impactedServiceIdsJson: '["svc-1","svc-2"]',
        relayMessageId: 'msg-1',
        actorName: 'Adam',
        projectId: 'proj-1',
        sessionId: 'sess-1',
        createdAt: DateTime.utc(2026),
      );
      expect(instance, isA<ActivityFeedEntry>());
      expect(instance.id, 'act-1');
      expect(instance.activityType, ActivityType.sessionCompleted);
      expect(instance.title, 'Session completed');
      expect(instance.sourceModule, 'mcp');
      expect(instance.projectName, 'CodeOps-Server');
      expect(instance.actorName, 'Adam');
      expect(instance.projectId, 'proj-1');
      expect(instance.sessionId, 'sess-1');
    });
  });

  // ══════════════════════════════════════════════════════════════
  //  TOOL DEFINITION MODEL
  // ══════════════════════════════════════════════════════════════

  group('McpToolDefinition', () {
    test('const constructor with all null optional fields', () {
      const instance = McpToolDefinition();
      expect(instance, isA<McpToolDefinition>());
    });

    test('constructor with populated fields', () {
      const instance = McpToolDefinition(
        name: 'registry.listServices',
        description: 'Lists all registered services for a team',
        category: 'registry',
        inputSchema: '{"type":"object","properties":{"teamId":{"type":"string"}}}',
      );
      expect(instance, isA<McpToolDefinition>());
      expect(instance.name, 'registry.listServices');
      expect(instance.description, contains('registered services'));
      expect(instance.category, 'registry');
      expect(instance.inputSchema, contains('teamId'));
    });
  });
}
