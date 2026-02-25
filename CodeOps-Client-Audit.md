# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-02-25T21:28:14Z
**Branch:** main
**Commit:** b29c08a18a8690ffa01b8bdb8b87ccee428573b9 RLF-002: Channel list + management — sidebar, dialogs, tests
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml (generated separately)

> This audit is the source of truth for the CodeOps-Client codebase structure, entities, services, and configuration.
> The OpenAPI spec (CodeOps-Client-OpenAPI.yaml) is the source of truth for all endpoints, DTOs, and API contracts.
> An AI reading this audit + the OpenAPI spec should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name: CodeOps-Client (codeops)
Repository URL: https://github.com/AI-CodeOps/CodeOps-Client.git
Primary Language / Framework: Dart / Flutter
Dart SDK Version: ^3.6.0
Flutter Version: >=3.27.0
Build Tool: Flutter + pub + build_runner (code generation)
Current Branch: main
Latest Commit Hash: b29c08a18a8690ffa01b8bdb8b87ccee428573b9
Latest Commit Message: RLF-002: Channel list + management — sidebar, dialogs, tests
Audit Timestamp: 2026-02-25T21:28:14Z
```

---

## 2. Directory Structure

Single-module Flutter desktop application (macOS, Linux, Windows). Source lives in `lib/` with a clean layered architecture:

```
CodeOps-Client/
├── lib/
│   ├── main.dart                 ← Entry point
│   ├── app.dart                  ← Root widget (CodeOpsApp)
│   ├── router.dart               ← GoRouter with 52 routes
│   ├── database/                 ← Local SQLite via Drift (2 files + generated)
│   ├── models/                   ← 32 model/enum files + 21 .g.dart
│   ├── pages/                    ← 52 page files (screens)
│   │   ├── registry/             ← 16 Service Registry sub-pages
│   │   └── relay/                ← Relay messaging page
│   ├── providers/                ← 29 Riverpod provider files
│   ├── services/                 ← 59 service files
│   │   ├── agent/                ← Agent config, persona manager, task gen
│   │   ├── analysis/             ← Dep scanner, health calc, tech debt tracker
│   │   ├── auth/                 ← AuthService + SecureStorage
│   │   ├── cloud/                ← 27 API client files (REST)
│   │   ├── data/                 ← Scribe persistence, sync, diff
│   │   ├── integration/          ← Export service
│   │   ├── jira/                 ← Jira REST client + mapper
│   │   ├── logging/              ← LogService + LogConfig + LogLevel
│   │   ├── openapi_parser.dart   ← OpenAPI YAML parser
│   │   ├── orchestration/        ← Job orchestrator, agent dispatch/monitor
│   │   ├── platform/             ← Claude Code detector, process manager
│   │   └── vcs/                  ← Git/GitHub service layer
│   ├── theme/                    ← 3 files (AppTheme, Colors, Typography)
│   ├── utils/                    ← 6 utility files
│   └── widgets/                  ← 268 widget files across 18 subdirectories
├── test/                         ← 359 test files (74,646 lines)
├── integration_test/             ← 5 integration test files
├── assets/
│   ├── personas/                 ← 12 agent persona .md files
│   └── templates/                ← 5 report template .md files
├── pubspec.yaml                  ← Build manifest
├── analysis_options.yaml         ← Linter config
└── macos/, linux/, windows/      ← Platform runners
```

**Stats:** 454 source files, 140,126 lines of Dart code. 359 test files, 74,646 lines of test code. 5 integration tests.

---

## 3. Build & Dependency Manifest

**Build file:** `pubspec.yaml`

### Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter | SDK | UI framework |
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Riverpod code generation annotations |
| go_router | ^14.8.1 | Declarative routing |
| drift | ^2.22.1 | Local SQLite database (ORM) |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native bindings |
| dio | ^5.7.0 | HTTP client |
| flutter_markdown | ^0.7.6 | Markdown rendering |
| flutter_highlight | ^0.7.0 | Code syntax highlighting |
| re_editor | ^0.8.0 | Code editor widget |
| re_highlight | ^0.0.3 | Syntax highlighting engine |
| fl_chart | ^0.70.2 | Charts and graphs |
| file_picker | ^8.1.7 | File selection dialogs |
| desktop_drop | ^0.5.0 | Drag-and-drop file support |
| window_manager | ^0.4.3 | Desktop window management |
| split_view | ^3.2.1 | Resizable split panes |
| diff_match_patch | ^0.4.1 | Text diff computation |
| path | ^1.9.0 | Path manipulation |
| path_provider | ^2.1.5 | App directory paths |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.20.1 | Internationalization/date formatting |
| yaml | ^3.1.3 | YAML parsing |
| archive | ^4.0.2 | ZIP/archive handling |
| url_launcher | ^6.3.1 | URL launching |
| shared_preferences | ^2.3.4 | Key-value persistence |
| crypto | ^3.0.6 | Hashing utilities |
| package_info_plus | ^8.1.2 | App version info |
| connectivity_plus | ^6.1.1 | Network connectivity |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| freezed_annotation | ^2.4.4 | Immutable model annotations |
| collection | ^1.19.0 | Collection utilities |
| equatable | ^2.0.7 | Value equality |
| pdf | ^3.11.2 | PDF generation |
| printing | ^5.13.4 | PDF printing/export |

### Dev Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.22.1 | Drift code generation |
| riverpod_generator | ^2.6.4 | Riverpod code generation |
| json_serializable | ^6.9.0 | JSON serialization code generation |
| freezed | ^2.5.7 | Immutable model code generation |
| flutter_test | SDK | Testing framework |
| mocktail | ^1.0.4 | Mocking framework |
| integration_test | SDK | Integration testing |
| flutter_lints | ^5.0.0 | Lint rules |

### Build Commands

```
Build: flutter build macos (or linux/windows)
Test: flutter test
Integration Test: flutter test integration_test/
Code Generation: dart run build_runner build --delete-conflicting-outputs
Run: flutter run -d macos
```

---

## 4. Configuration & Infrastructure Summary

### Application Configuration

- **`analysis_options.yaml`** — Uses `package:flutter_lints/flutter.yaml` base rules. No custom lint overrides active.
- **`pubspec.yaml`** — App name `codeops`, version `1.0.0+1`. Assets: `assets/personas/` (12 agent persona MD files), `assets/templates/` (5 report template MD files).
- **No `.env` file** — All configuration is in `lib/utils/constants.dart`.

### Constants (lib/utils/constants.dart)

Key configuration values (hardcoded, not environment-variable driven):

```
API Base URL: http://localhost:8090/api/v1
Auth endpoints: /auth/register, /auth/login
Token storage keys: codeops_access_token, codeops_refresh_token, codeops_selected_team_id
Polling interval: 3 seconds
Health check schedule: 300 seconds (5 min)
Scribe defaults: JetBrains Mono font, 30s auto-save, 10MB max file size
Relay WebSocket URL: ws://localhost:8090/ws/relay
Relay heartbeat: 30 seconds
```

### Connection Map

```
Database: SQLite (local, via Drift) — 22 tables, schema v7, offline cache + local state
API Server: CodeOps-Server at http://localhost:8090/api/v1 (Dio HTTP client)
Vault API: CodeOps-Vault at http://localhost:8097 (separate Dio client)
WebSocket: Relay messaging at ws://localhost:8090/ws/relay
External APIs: Jira Cloud (direct REST via Dio), GitHub API (direct REST via Dio), Anthropic API (direct REST via Dio)
Cache: None (no Redis/caching layer)
Message Broker: None (uses WebSocket for real-time)
Cloud Services: None
```

### CI/CD

None detected.

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart` → `main()`

Startup sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogConfig.initialize()` — sets log level (debug in dev, info in release), configures file logging directory
3. `windowManager.ensureInitialized()` — configures desktop window (1440x900, min 1024x700, title "CodeOps", hidden title bar)
4. `windowManager.waitUntilReadyToShow()` → show + focus window
5. `runApp(ProviderScope(child: CodeOpsApp()))` — launches Riverpod-scoped app

**Post-login initialization (in `CodeOpsApp.build`):**
1. Listens to `authStateProvider` stream
2. On authentication: auto-selects team (from stored ID or first available)
3. Seeds 13 built-in agents via `agentConfigService.seedBuiltInAgents()`
4. Fire-and-forget: refreshes Anthropic model cache
5. Restores GitHub authentication from stored PAT

**Health check:** No health endpoint (client app). Server health monitored via `HealthMonitorApi`.

**Scheduled tasks:** None built-in. Health monitoring polls server at configurable intervals (default 5 min).

---

## 6. Entity / Data Model Layer

### Local Database (Drift/SQLite)

**`lib/database/tables.dart`** — Defines 22 Drift tables:
Users, Teams, Projects, QaJobs, AgentRuns, Findings, RemediationTasks, Personas, Directives, TechDebtItems, DependencyScans, DependencyVulnerabilities, HealthSnapshots, ComplianceItems, Specifications, SyncMetadata, ClonedRepos, AnthropicModels, AgentDefinitions, AgentFiles, ProjectLocalConfig, ScribeTabs, ScribeSettings

All enum fields stored as `text()` (SCREAMING_SNAKE_CASE).

**`lib/database/database.dart`** — `CodeOpsDatabase extends _$CodeOpsDatabase`
- Schema version: 7 (incremental migrations from v1 through v7)
- Factory: `CodeOpsDatabase.defaults()` uses platform-specific SQLite at `<appSupportDir>/codeops.db`
- Method: `clearAllTables()` — deletes all rows (used on logout)
- Singleton: lazy `database` getter

### Server-Synced Models (JSON-serializable)

All models use `@JsonSerializable()` with `fromJson`/`toJson` factory constructors.

#### Core Domain Models

```
=== Project (lib/models/project.dart) ===
Fields:
  - id: String
  - name: String
  - description: String?
  - repoUrl: String?
  - language: String?
  - teamId: String
  - createdAt: DateTime?
  - updatedAt: DateTime?
  - healthScore: int?
  - lastAuditAt: DateTime?

=== User (lib/models/user.dart) ===
Fields:
  - id: String
  - email: String
  - firstName: String?
  - lastName: String?
  - role: String?
  - avatarUrl: String?
  - createdAt: DateTime?
  - lastLoginAt: DateTime?

=== Team (lib/models/team.dart) ===
Fields:
  - id: String
  - name: String
  - description: String?
  - ownerId: String?
  - colorHex: String?
  - createdAt: DateTime?
  - updatedAt: DateTime?
  - members: List<TeamMember>?

=== TeamMember (lib/models/team.dart) ===
Fields:
  - userId: String
  - email: String
  - firstName: String?
  - lastName: String?
  - role: TeamMemberRole
  - joinedAt: DateTime?
```

#### QA/Audit Models

```
=== QaJob (lib/models/qa_job.dart) ===
Fields:
  - id: String
  - projectId: String
  - mode: JobMode
  - status: JobStatus
  - result: JobResult?
  - agentCount: int?
  - startedAt: DateTime?
  - completedAt: DateTime?
  - summary: String?
  - triggeredBy: String?
  - complianceSpecId: String?

=== AgentRun (lib/models/agent_run.dart) ===
@JsonSerializable()
Fields:
  - id: String
  - jobId: String
  - agentType: String
  - status: AgentStatus
  - startedAt: DateTime?
  - completedAt: DateTime?
  - findingsCount: int?
  - output: String?
  - errorMessage: String?

=== AgentProgress (lib/models/agent_progress.dart) ===
Immutable class (manual, not @JsonSerializable)
Fields:
  - agentType: String
  - phase: String
  - percent: double
  - currentFile: String?
  - findingsCount: int
  - message: String?
  - timestamp: DateTime

=== Finding (lib/models/finding.dart) ===
Fields:
  - id: String
  - jobId: String
  - agentType: String?
  - severity: Severity
  - category: String?
  - title: String
  - description: String?
  - filePath: String?
  - lineNumber: int?
  - suggestion: String?
  - status: FindingStatus?
  - createdAt: DateTime?

=== RemediationTask (lib/models/remediation_task.dart) ===
Fields:
  - id: String
  - jobId: String
  - findingId: String?
  - title: String
  - description: String?
  - status: TaskStatus
  - priority: TaskPriority
  - effort: String?
  - assignee: String?
  - category: String?
  - filePath: String?
  - createdAt: DateTime?
  - updatedAt: DateTime?
```

#### Health & Compliance Models

```
=== HealthSnapshot (lib/models/health_snapshot.dart) ===
Fields:
  - id: String
  - projectId: String
  - overallScore: int
  - securityScore: int?
  - dataIntegrityScore: int?
  - apiQualityScore: int?
  - codeQualityScore: int?
  - testCoverageScore: int?
  - documentationScore: int?
  - infrastructureScore: int?
  - recordedAt: DateTime?

=== ComplianceItem (lib/models/compliance_item.dart) ===
Fields:
  - id: String
  - specId: String?
  - section: String?
  - requirement: String
  - status: ComplianceStatus
  - notes: String?
  - evidencePaths: List<String>?
  - createdAt: DateTime?

=== Specification (lib/models/specification.dart) ===
Fields:
  - id: String
  - name: String
  - version: String?
  - description: String?
  - type: SpecificationType?
  - content: String?
  - uploadedAt: DateTime?

=== DependencyScan (lib/models/dependency_scan.dart) ===
Fields:
  - id: String
  - projectId: String
  - scannedAt: DateTime?
  - totalDependencies: int?
  - outdatedCount: int?
  - vulnerableCount: int?
  - dependencies: List<DependencyItem>?
```

#### Tech Debt & Directives

```
=== TechDebtItem (lib/models/tech_debt_item.dart) ===
Fields:
  - id: String
  - projectId: String
  - title: String
  - description: String?
  - category: DebtCategory
  - status: DebtStatus
  - effortEstimate: EffortEstimate?
  - businessImpact: BusinessImpact?
  - filePath: String?
  - lineNumber: int?
  - firstDetectedJobId: String?
  - createdAt: DateTime?
  - updatedAt: DateTime?

=== Directive (lib/models/directive.dart) ===
Fields:
  - id: String
  - projectId: String?
  - scope: DirectiveScope
  - title: String
  - content: String
  - enabled: bool
  - priority: int?
  - createdAt: DateTime?
  - updatedAt: DateTime?
```

#### Persona & Agent Config

```
=== Persona (lib/models/persona.dart) ===
Fields:
  - id: String
  - name: String
  - description: String?
  - systemPrompt: String
  - category: String?
  - isBuiltIn: bool
  - createdAt: DateTime?
  - updatedAt: DateTime?

=== AnthropicModelInfo (lib/models/anthropic_model_info.dart) ===
Immutable class with factory fromDbRow()
Fields:
  - id: String
  - name: String
  - displayName: String
  - maxTokens: int
  - inputPrice: double
  - outputPrice: double
```

#### Courier (API Testing) Models

```
=== CourierRequest / CourierResponse / etc. (lib/models/courier_models.dart) ===
@JsonSerializable() models for HTTP request/response testing
Key classes: CourierRequest, CourierResponse, CourierHeader, CourierQueryParam, CourierFormField, CourierCollection, CourierFolder, CourierEnvironment, CourierVariable, CourierScript
```

#### Registry (Service Registry) Models

```
=== RegistryService / RegistryPort / RegistrySolution / etc. (lib/models/registry_models.dart) ===
@JsonSerializable() models for microservice registry
Key classes: RegistryService, RegistryPort, RegistryDependency, RegistryRoute, RegistryHealthCheck, RegistryEnvConfig, RegistrySolution, RegistryApiSpec, InfraResource, WorkstationProfile, InstalledTool
```

#### Vault (Secrets Management) Models

```
=== VaultSecret / VaultPolicy / VaultTransitKey / etc. (lib/models/vault_models.dart) ===
@JsonSerializable() models for secrets management
Key classes: VaultSecret, VaultSecretVersion, VaultPolicy, VaultPolicyBinding, VaultTransitKey, VaultLease, VaultAuditEntry, VaultRotationPolicy, VaultRotationEvent, VaultSealStatus, VaultUnsealProgress, VaultShareSet
```

#### Relay (Messaging) Models

```
=== RelayChannel / RelayMessage / RelayReaction / etc. (lib/models/relay_models.dart) ===
@JsonSerializable() models for team messaging
Key classes: RelayChannel, RelayMessage, RelayReaction, RelayThread, RelayDirectConversation, RelayDirectMessage, RelayPresenceUpdate, RelayTypingIndicator, RelayReadReceipt
```

#### Logger Models

```
=== LogEntry / LogStream / LogQuery / etc. (lib/models/logger_models.dart) ===
@JsonSerializable() models for centralized logging
Key classes: LogEntry, LogStream, LogQuery, LogStreamStats, LogAlertRule
```

#### Jira Models

```
=== JiraIssue / JiraProject / JiraSearchResult / etc. (lib/models/jira_models.dart) ===
@JsonSerializable() models for Jira integration
Key classes: JiraIssue, JiraProject, JiraSearchResult, JiraUser, JiraComment, JiraSprint, JiraPriority, JiraIssueType, JiraTransition, CreateJiraIssueRequest, CreateJiraSubTaskRequest, UpdateJiraIssueRequest
```

#### VCS Models

```
=== VcsCredentials / VcsRepository / VcsBranch / etc. (lib/models/vcs_models.dart) ===
Plain Dart classes with fromGitHubJson() factories
Key classes: VcsCredentials, VcsOrganization, VcsRepository, VcsBranch, VcsPullRequest, VcsCommit, VcsStash, VcsTag, WorkflowRun, CloneProgress, RepoStatus, FileChange, DiffResult, DiffHunk, DiffLine
```

#### Scribe (Code Editor) Models

```
=== ScribeFile / ScribeSession / ScribeTab / ScribeRecentFile (lib/models/scribe_models.dart) ===
Immutable models (copyWith pattern) for the code editor feature

=== ScribeDiffResult / ScribeDiffChunk / ScribeDiffLine (lib/models/scribe_diff_models.dart) ===
Models for the diff editor
```

#### OpenAPI Spec Model

```
=== OpenApiSpec / OpenApiPath / OpenApiOperation / etc. (lib/models/openapi_spec.dart) ===
Models for parsing and displaying OpenAPI YAML specs
Key classes: OpenApiSpec, OpenApiPath, OpenApiOperation, OpenApiParameter, OpenApiRequestBody, OpenApiResponse, OpenApiSchema
```

---

## 7. Enum Inventory

### Core Enums (lib/models/enums.dart)

```
=== JobMode ===
Values: audit, compliance, bugInvestigate, remediate, techDebt, dependency, healthMonitor
Used in: QaJob, pages, providers

=== JobStatus ===
Values: pending, running, completed, failed, cancelled
Used in: QaJob, AgentRun

=== JobResult ===
Values: pass, warn, fail
Used in: QaJob

=== AgentStatus ===
Values: pending, running, completed, failed
Used in: AgentRun

=== Severity ===
Values: critical, high, medium, low, info
Used in: Finding

=== FindingStatus ===
Values: open, acknowledged, falsePositive, resolved
Used in: Finding

=== TaskStatus ===
Values: open, inProgress, completed, deferred
Used in: RemediationTask

=== TaskPriority ===
Values: critical, high, medium, low
Used in: RemediationTask

=== ComplianceStatus ===
Values: compliant, nonCompliant, partiallyCompliant, notAssessed
Used in: ComplianceItem

=== SpecificationType ===
Values: regulatory, industry, internal, contractual
Used in: Specification

=== DirectiveScope ===
Values: global, project
Used in: Directive

=== TeamMemberRole ===
Values: OWNER, ADMIN, LEAD, MEMBER, VIEWER
Used in: TeamMember (UPPERCASE enum values)

=== DebtCategory ===
Values: codeSmell, designDebt, testDebt, documentationDebt, dependencyDebt, infrastructureDebt, securityDebt, performanceDebt
Has displayName getter
Used in: TechDebtItem

=== DebtStatus ===
Values: identified, planned, inProgress, resolved
Has displayName getter
Used in: TechDebtItem

=== EffortEstimate ===
Values: trivial, small, medium, large, epic
Has displayName getter
Used in: TechDebtItem

=== BusinessImpact ===
Values: critical, high, medium, low, negligible
Has displayName getter
Used in: TechDebtItem

=== GitHubAuthType ===
Values: pat, oauth, ssh
Used in: VcsCredentials
```

### Courier Enums (lib/models/courier_enums.dart)

```
=== HttpMethod === GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
=== BodyType === NONE, FORM_DATA, X_WWW_FORM_URLENCODED, RAW_JSON, RAW_XML, RAW_HTML, RAW_TEXT, RAW_YAML, BINARY, GRAPHQL
=== AuthType === NO_AUTH, API_KEY, BEARER_TOKEN, BASIC_AUTH, OAUTH2_AUTHORIZATION_CODE, OAUTH2_CLIENT_CREDENTIALS, OAUTH2_IMPLICIT, OAUTH2_PASSWORD, JWT_BEARER, INHERIT_FROM_PARENT
=== ScriptType === PRE_REQUEST, POST_RESPONSE
=== SortOrder === nameAsc, nameDesc, createdAsc, createdDesc
=== ApiKeyLocation === HEADER, QUERY_PARAM
```

### Registry Enums (lib/models/registry_enums.dart)

```
=== ServiceType === BACKEND, FRONTEND, DATABASE, CACHE, QUEUE, GATEWAY, WORKER, SCHEDULER, LIBRARY, INFRASTRUCTURE
=== ServiceStatus === ACTIVE, DEGRADED, DOWN, MAINTENANCE, DEPRECATED, PLANNED
=== PortProtocol === HTTP, HTTPS, TCP, UDP, WS, WSS, GRPC
=== DependencyType === RUNTIME, BUILD, OPTIONAL
=== RouteMethod === GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
=== HealthCheckType === HTTP, TCP, COMMAND, SCRIPT
=== InfraResourceType === DATABASE, CACHE, QUEUE, STORAGE, CDN, DNS, LOAD_BALANCER, MONITORING, LOGGING, CI_CD, CONTAINER_REGISTRY, SECRET_MANAGER, OTHER
=== InfraResourceStatus === HEALTHY, DEGRADED, DOWN, UNKNOWN
```

### Relay Enums (lib/models/relay_enums.dart)

```
=== ChannelType === PUBLIC, PRIVATE, ANNOUNCEMENT, THREAD
=== RelayMessageType === TEXT, SYSTEM, FILE, CODE, LINK
=== PresenceStatus === ONLINE, AWAY, DND, OFFLINE
=== ChannelMemberRole === OWNER, ADMIN, MEMBER
```

### Vault Enums (lib/models/vault_enums.dart)

```
=== SecretType === KV, DATABASE, API_KEY, CERTIFICATE, SSH_KEY, TOKEN, PASSWORD, CUSTOM
=== SecretStatus === ACTIVE, EXPIRED, REVOKED, ROTATING
=== PolicyEffect === ALLOW, DENY
=== PolicyCapability === READ, WRITE, DELETE, LIST, SUDO
=== TransitKeyType === AES256_GCM, RSA_2048, RSA_4096, ED25519
=== LeaseStatus === ACTIVE, EXPIRED, REVOKED
=== VaultAuditOperation === READ, WRITE, DELETE, LIST, LOGIN, POLICY_UPDATE, SEAL, UNSEAL, ROTATE, TRANSIT_ENCRYPT, TRANSIT_DECRYPT
=== RotationStrategy === TIME_BASED, EVENT_BASED, MANUAL
=== RotationStatus === SCHEDULED, IN_PROGRESS, COMPLETED, FAILED
```

### Logger Enums (lib/models/logger_enums.dart)

```
=== LogSeverity === TRACE, DEBUG, INFO, WARN, ERROR, FATAL
=== LogStreamStatus === ACTIVE, PAUSED, ERROR
=== AlertRuleStatus === ENABLED, DISABLED, TRIGGERED
```

---

## 8. Repository Layer

This is a Flutter client app — no JPA repositories. Data access is through:

1. **Local SQLite (Drift):** `lib/database/database.dart` — `CodeOpsDatabase` with methods for agent configs and Anthropic models.
2. **REST API clients** in `lib/services/cloud/` — 27 API client classes that wrap Dio HTTP calls.
3. **Riverpod providers** in `lib/providers/` — 29 provider files that expose API responses as reactive state.

---

## 9. Service Layer — Full Method Signatures

### Authentication

```
=== AuthService (lib/services/auth/auth_service.dart) ===
Injects: Dio, SecureStorage
Purpose: JWT-based authentication against CodeOps-Server

Public Methods:
  - register(email, firstName, lastName, password): Future<void>
  - login(email, password): Future<void>
  - logout(): Future<void>
  - refreshToken(): Future<void>
  - stateStream: Stream<AuthState>
  - currentState: AuthState
  - isAuthenticated: bool

AuthState enum: unknown, checking, authenticated, unauthenticated

=== SecureStorage (lib/services/auth/secure_storage.dart) ===
Injects: SharedPreferences
Purpose: Persists tokens and selected team ID

Public Methods:
  - getAccessToken(): Future<String?>
  - setAccessToken(String): Future<void>
  - getRefreshToken(): Future<String?>
  - setRefreshToken(String): Future<void>
  - getSelectedTeamId(): Future<String?>
  - setSelectedTeamId(String): Future<void>
  - clearAll(): Future<void>
```

### API Client (Base)

```
=== ApiClient (lib/services/cloud/api_client.dart) ===
Injects: SecureStorage
Purpose: Configured Dio instance with auth interceptor, token refresh, error mapping

Provides: Dio instance with:
  - Base URL: http://localhost:8090/api/v1
  - Auto-attach Authorization: Bearer <token>
  - Auto-refresh on 401
  - Maps DioExceptions to typed ApiException subclasses

=== ApiExceptions (lib/services/cloud/api_exceptions.dart) ===
Exception hierarchy:
  - ApiException (base)
  - UnauthorizedException (401)
  - ForbiddenException (403)
  - NotFoundException (404)
  - ConflictException (409)
  - ValidationException (422)
  - ServerException (500+)
  - NetworkException (connection failures)
```

### Cloud API Services (all in lib/services/cloud/)

Each wraps Dio HTTP calls to CodeOps-Server REST endpoints:

```
=== ProjectApi === CRUD for projects, team projects listing
=== TeamApi === CRUD for teams, member management, invitations
=== UserApi === User profile, listing, search
=== JobApi === QA job CRUD, status polling, cancellation
=== FindingApi === Finding CRUD, filtering by job/severity/status
=== TaskApi === Remediation task CRUD, bulk operations
=== PersonaApi === Persona CRUD (server-synced)
=== DirectiveApi === Directive CRUD with scope filtering
=== ComplianceApi === Compliance items, spec upload
=== DependencyApi === Dependency scan results
=== TechDebtApi === Tech debt CRUD, status updates
=== HealthMonitorApi === Health snapshots, score history
=== ReportApi === Job reports (markdown)
=== AdminApi === Admin operations (audit logs, settings, user mgmt, usage stats)
=== MetricsApi === Analytics metrics
=== LoggerApi === Centralized log entries, streams, alerts
=== CourierApi === HTTP request testing (collections, environments, requests)
=== RegistryApi === Service registry CRUD (services, ports, dependencies, routes, solutions, infra, workstations, API docs, startup order)
=== VaultApi === Vault secrets, policies, transit, dynamic, rotation, seal, audit
=== RelayApi === Relay channels, messages, DMs, presence, reactions
=== IntegrationApi === GitHub/Jira integration status
=== AnthropicApiService === Direct Anthropic API (model listing, message creation)
```

### Orchestration Services

```
=== JobOrchestrator (lib/services/orchestration/job_orchestrator.dart) ===
Injects: ApiClient, ProcessManager, AgentConfigService
Purpose: Orchestrates multi-agent QA audit jobs — creates job, dispatches agents, monitors progress

Public Methods:
  - startJob(projectId, mode, config): Future<String> (returns jobId)
  - cancelJob(jobId): Future<void>

=== AgentDispatcher (lib/services/orchestration/agent_dispatcher.dart) ===
Purpose: Launches Claude Code processes for each agent

=== AgentMonitor (lib/services/orchestration/agent_monitor.dart) ===
Purpose: Monitors running agent processes, streams progress updates

=== ProgressAggregator (lib/services/orchestration/progress_aggregator.dart) ===
Purpose: Aggregates per-agent progress into job-level progress

=== VeraManager (lib/services/orchestration/vera_manager.dart) ===
Purpose: Manages the Vera meta-agent that reviews and consolidates agent outputs

=== BugInvestigationOrchestrator (lib/services/orchestration/bug_investigation_orchestrator.dart) ===
Purpose: Orchestrates bug investigation workflow
```

### Agent Services

```
=== AgentConfigService (lib/services/agent/agent_config_service.dart) ===
Injects: CodeOpsDatabase
Purpose: Manages agent configurations in local SQLite, seeds 13 built-in agents

=== PersonaManager (lib/services/agent/persona_manager.dart) ===
Purpose: Loads persona markdown files from assets/personas/

=== ReportParser (lib/services/agent/report_parser.dart) ===
Purpose: Parses agent output into structured findings

=== TaskGenerator (lib/services/agent/task_generator.dart) ===
Purpose: Generates remediation tasks from findings
```

### Analysis Services

```
=== DependencyScanner (lib/services/analysis/dependency_scanner.dart) ===
Purpose: Parses pubspec.yaml/pom.xml/package.json for dependency analysis

=== HealthCalculator (lib/services/analysis/health_calculator.dart) ===
Purpose: Computes project health scores from multiple dimensions

=== TechDebtTracker (lib/services/analysis/tech_debt_tracker.dart) ===
Purpose: Static utilities for tech debt scoring, categorization, reporting
Methods: computeDebtScore, computeDebtByStatus, computeResolutionRate, formatDebtReport
```

### VCS Services

```
=== GitService (lib/services/vcs/git_service.dart) ===
Purpose: Executes git CLI commands (clone, status, diff, commit, push, pull, branch, stash)

=== GitHubProvider (lib/services/vcs/github_provider.dart) ===
Purpose: GitHub REST API client (repos, branches, PRs, commits, orgs, workflow runs)

=== RepoManager (lib/services/vcs/repo_manager.dart) ===
Purpose: Manages cloned repo state, coordinates git operations

=== VcsProvider (lib/services/vcs/vcs_provider.dart) ===
Purpose: Abstract VCS interface (currently only GitHub implementation)
```

### Jira Services

```
=== JiraService (lib/services/jira/jira_service.dart) ===
Injects: Dio (separate from CodeOps API client)
Purpose: Direct Jira Cloud REST API client with Basic Auth

Public Methods:
  - configure(instanceUrl, email, apiToken): void
  - testConnection(): Future<bool>
  - searchIssues(jql, startAt, maxResults): Future<JiraSearchResult>
  - getIssue(issueKey): Future<JiraIssue>
  - createIssue(request): Future<JiraIssue>
  - createSubTask(request): Future<JiraIssue>
  - createIssuesBulk(requests): Future<List<JiraIssue>>
  - updateIssue(issueKey, request): Future<void>
  - getTransitions(issueKey): Future<List<JiraTransition>>
  - transitionIssue(issueKey, transitionId): Future<void>
  - getComments(issueKey): Future<List<JiraComment>>
  - postComment(issueKey, bodyMarkdown): Future<JiraComment>
  - getProjects(): Future<List<JiraProject>>
  - getSprints(boardId): Future<List<JiraSprint>>
  - getIssueTypes(projectKey): Future<List<JiraIssueType>>
  - searchUsers(query): Future<List<JiraUser>>
  - getPriorities(): Future<List<JiraPriority>>

=== JiraMapper (lib/services/jira/jira_mapper.dart) ===
Purpose: Maps between CodeOps findings/tasks and Jira issues (ADF format conversion)
```

### Data Services

```
=== ScribeFileService (lib/services/data/scribe_file_service.dart) ===
Purpose: File system operations for the Scribe code editor

=== ScribePersistenceService (lib/services/data/scribe_persistence_service.dart) ===
Purpose: Session persistence for Scribe editor state

=== ScribeDiffService (lib/services/data/scribe_diff_service.dart) ===
Purpose: Computes diffs between file versions for the diff editor

=== SyncService (lib/services/data/sync_service.dart) ===
Purpose: Synchronizes local data with server
```

### Platform Services

```
=== ClaudeCodeDetector (lib/services/platform/claude_code_detector.dart) ===
Purpose: Detects if Claude Code CLI is installed and available on PATH

=== ProcessManager (lib/services/platform/process_manager.dart) ===
Purpose: Manages OS processes (start, monitor, kill) for agent execution
```

### Logging

```
=== LogService (lib/services/logging/log_service.dart) ===
Global singleton `log` with methods: v(), d(), i(), w(), e(), f()
Outputs to console with ANSI colors (debug) and to daily log files (release)
File rotation: 7-day retention

=== LogConfig (lib/services/logging/log_config.dart) ===
Static config: minimumLevel, enableFileLogging, enableConsoleColors, mutedTags, logDirectory

=== LogLevel (lib/services/logging/log_level.dart) ===
Enum: verbose, debug, info, warning, error, fatal
```

### Other Services

```
=== OpenApiParser (lib/services/openapi_parser.dart) ===
Purpose: Parses OpenAPI YAML into structured OpenApiSpec model

=== ExportService (lib/services/integration/export_service.dart) ===
Purpose: Exports reports/findings to PDF, Markdown, CSV, Jira
```

---

## 10. Controller / API Layer (Pages)

This is a Flutter client — pages serve as the "controller" layer. 52 routes defined in `lib/router.dart`.

### Route Map

```
/login → LoginPage (outside shell, public)
/setup → PlaceholderPage (outside shell)

All below wrapped in ShellRoute → NavigationShell:

/ → HomePage (dashboard)
/projects → ProjectsPage
/projects/:id → ProjectDetailPage
/repos → GitHubBrowserPage
/scribe → ScribePage
/audit → AuditWizardPage
/compliance → ComplianceWizardPage
/dependencies → DependencyScanPage
/bugs → BugInvestigatorPage (?jiraKey query param)
/bugs/jira → JiraBrowserPage
/tasks → TaskManagerPage
/tech-debt → TechDebtPage
/health → HealthDashboardPage
/history → JobHistoryPage
/jobs/:id → JobProgressPage
/jobs/:id/report → JobReportPage
/jobs/:id/findings → FindingsExplorerPage
/jobs/:id/tasks → TaskListPage
/personas → PersonasPage
/personas/:id/edit → PersonaEditorPage
/directives → DirectivesPage
/settings → SettingsPage
/admin → AdminHubPage
/vault → VaultDashboardPage
/vault/secrets → VaultSecretsPage
/vault/secrets/:id → VaultSecretDetailPage
/vault/policies → VaultPoliciesPage
/vault/policies/:id → VaultPolicyDetailPage
/vault/transit → VaultTransitPage
/vault/dynamic → VaultDynamicPage
/vault/rotation → VaultRotationPage
/vault/seal → VaultSealPage
/vault/audit → VaultAuditPage
/registry → ServiceListPage
/registry/services/new → ServiceFormPage
/registry/services/:id → ServiceDetailPage
/registry/services/:id/edit → ServiceFormPage(serviceId)
/registry/ports → PortAllocationPage
/registry/solutions → SolutionListPage
/registry/solutions/:solutionId → SolutionDetailPage
/registry/dependencies → DependencyGraphPage
/registry/dependencies/impact → ImpactAnalysisPage
/registry/topology → TopologyPage
/registry/infra → InfraResourcesPage
/registry/routes → ApiRoutesPage
/registry/config → ConfigGeneratorPage
/registry/workstations → WorkstationListPage
/registry/workstations/:profileId → WorkstationDetailPage
/registry/api-docs → ApiDocsPage
/registry/api-docs/:serviceId → ApiDocsPage(serviceId)
/relay → RelayPage
/relay/channel/:channelId → RelayPage(channelId)
/relay/channel/:channelId/thread/:messageId → RelayPage(channelId, messageId)
/relay/dm/:conversationId → RelayPage(conversationId)
```

### Navigation Shell (lib/widgets/shell/navigation_shell.dart)

Persistent sidebar with sections:
- **Overview:** Home, Projects
- **Build:** Repos (GitHub), Scribe (Code Editor)
- **Quality:** Audit Wizard, Compliance, Dependencies, Bugs, Jira
- **Maintain:** Tasks, Tech Debt, Health Dashboard, History
- **Configure:** Personas, Directives, Settings
- **Admin:** Admin Hub
- **Secure:** Vault (secrets management)
- **Infrastructure:** Registry (service registry)
- **Communicate:** Relay (team messaging)

Team switcher dialog in sidebar header.

---

## 11. Security Configuration

```
Authentication: JWT (via CodeOps-Server)
Token storage: SharedPreferences (access_token, refresh_token)
Token refresh: Automatic on 401 via Dio interceptor

Public routes (no auth required):
  - /login
  - /setup

Protected routes (all others):
  - Redirect to /login if not authenticated
  - GoRouter redirect guard using AuthNotifier

CORS: N/A (desktop client)
CSRF: N/A (desktop client)
Rate limiting: N/A (server-side)
```

---

## 12. Custom Security Components

```
=== AuthService (lib/services/auth/auth_service.dart) ===
Purpose: Manages JWT authentication lifecycle
Token from: Login response (access_token, refresh_token)
Stores tokens via: SecureStorage (SharedPreferences)
Emits state changes via: Stream<AuthState>
Auto-refresh: On 401 response, attempts token refresh before retry

=== SecureStorage (lib/services/auth/secure_storage.dart) ===
Purpose: Persists auth tokens
Backend: SharedPreferences (not OS keychain — noted as potential improvement)
Keys: codeops_access_token, codeops_refresh_token, codeops_selected_team_id

=== ApiClient Interceptor (lib/services/cloud/api_client.dart) ===
Purpose: Attaches Bearer token to all API requests
On 401: Attempts token refresh, retries original request
On refresh failure: Logs out, redirects to /login
```

---

## 13. Exception Handling & Error Responses

```
=== ApiExceptions (lib/services/cloud/api_exceptions.dart) ===

Exception Hierarchy:
  - ApiException (base, message + statusCode)
    - UnauthorizedException (401)
    - ForbiddenException (403)
    - NotFoundException (404)
    - ConflictException (409)
    - ValidationException (422, + errors map)
    - ServerException (500+)
    - NetworkException (no status code)

Mapping: DioException → typed ApiException via ApiClient interceptor

UI Error Handling Pattern:
  - AsyncValue.when(error: ...) in Riverpod consumers
  - SnackBar for transient errors
  - ErrorPanel widget for persistent error states
  - EmptyState widget for no-data scenarios
```

---

## 14. Mappers / DTOs

No MapStruct-style mappers. Mapping patterns:

- **Model.fromJson()** — All server models have `factory fromJson(Map<String, dynamic>)` generated by json_serializable
- **Model.toJson()** — All server models have `Map<String, dynamic> toJson()` generated by json_serializable
- **VCS models** — Manual `fromGitHubJson()` factories that map GitHub API JSON to Dart models
- **Jira models** — Manual `fromJson()` factories that map Jira REST API JSON
- **JiraMapper** — Converts between CodeOps findings/tasks and Jira issue format (including markdown → ADF conversion)
- **Database rows** — Drift generates mapping code in `.g.dart` files

---

## 15. Utility Classes & Shared Components

### Utils (lib/utils/)

```
=== Constants (lib/utils/constants.dart) ===
Static constants: API URLs, token keys, polling intervals, UI dimensions, Scribe/Relay config values

=== DateUtils (lib/utils/date_utils.dart) ===
Functions:
  - formatDateTime(DateTime?): String — 'MMM d, yyyy h:mm a'
  - formatDate(DateTime?): String — 'MMM d, yyyy'
  - formatTimeAgo(DateTime?): String — 'just now', '5m ago', '2h ago', 'yesterday'
  - formatDuration(Duration): String — '1h 23m 45s'

=== FileUtils (lib/utils/file_utils.dart) ===
Functions:
  - formatFileSize(int bytes): String — '1.2 MB'
  - getFileExtension(String path): String
  - getFileName(String path): String

=== FuzzyMatcher (lib/utils/fuzzy_matcher.dart) ===
Class with static methods:
  - match(query, candidate): FuzzyMatch — scores subsequence match
  - filter(query, candidates, {maxResults}): List<FuzzyMatch>
Scoring: consecutive runs (+5), word boundaries (+10), prefix (+15)

=== MarkdownHeadingParser (lib/utils/markdown_heading_parser.dart) ===
Function:
  - parseMarkdownHeadings(String markdown): List<MarkdownHeading>
Extracts ATX-style headings, ignores code blocks

=== StringUtils (lib/utils/string_utils.dart) ===
Functions:
  - truncate(String s, int max): String
  - pluralize(int count, String singular, [String? plural]): String
  - camelToTitle(String s): String — 'codeQuality' → 'Code Quality'
  - snakeToTitle(String s): String — 'CODE_QUALITY' → 'Code Quality'
  - isValidEmail(String email): bool
```

### Theme (lib/theme/)

```
=== AppTheme (lib/theme/app_theme.dart) ===
Static darkTheme: ThemeData with CodeOps dark color scheme

=== CodeOpsColors (lib/theme/colors.dart) ===
Static color constants: background (#0F1117), surface (#1A1D27), primary (#6C5CE7), etc.
Semantic colors: success, warning, error, info
Text hierarchy: textPrimary, textSecondary, textTertiary

=== CodeOpsTypography (lib/theme/typography.dart) ===
Static TextStyle constants: h1 through body, caption, overline, code
```

### Shared Widgets (lib/widgets/shared/)

```
- ConfirmDialog — Reusable confirmation dialog with destructive option
- EmptyState — Empty state placeholder with icon, title, subtitle
- ErrorPanel — Error display with retry button
- LoadingOverlay — Full-screen loading overlay
- MarkdownEditorDialog — Dialog with markdown editor
- NotificationToast — Toast notification widget
- SearchBar — Reusable search bar
- TemperatureHelpDialog — Help dialog for AI temperature settings
```

---

## 16. Database Schema (Live)

**Local SQLite** (managed by Drift, schema version 7):

22 tables mirroring server PostgreSQL entities for offline cache / local state:

```
Core: Users, Teams, Projects
QA: QaJobs, AgentRuns, Findings, RemediationTasks
Config: Personas, Directives, AgentDefinitions, AgentFiles
Analysis: TechDebtItems, DependencyScans, DependencyVulnerabilities
Health: HealthSnapshots, ComplianceItems, Specifications
Infrastructure: SyncMetadata, ClonedRepos, AnthropicModels
Editor: ScribeTabs, ScribeSettings
Local Config: ProjectLocalConfig
```

All enum columns stored as TEXT (SCREAMING_SNAKE_CASE). DateTime columns stored as INTEGER (epoch ms).

**No server-side database** from this client. All server data accessed via REST API from CodeOps-Server.

---

## 17. Message Broker Configuration

No message broker detected. Real-time communication uses WebSocket (`ws://localhost:8090/ws/relay`) for the Relay messaging feature via `RelayWebSocketService`.

---

## 18. Cache Layer

No Redis or caching layer detected. The app uses:
- **Riverpod providers** as in-memory state cache (auto-dispose when unused)
- **Local SQLite** via Drift for persistent local data (agent configs, model cache)
- **SharedPreferences** for simple key-value persistence (tokens, team selection)

---

## 19. Environment Variable Inventory

No environment variables used. All configuration is hardcoded in `lib/utils/constants.dart`.

| Configuration | Value | Location |
|---|---|---|
| API Base URL | `http://localhost:8090/api/v1` | constants.dart |
| WebSocket URL | `ws://localhost:8090/ws/relay` | constants.dart |
| Token Keys | `codeops_access_token`, etc. | constants.dart |
| Polling Interval | 3 seconds | constants.dart |
| Health Check Interval | 300 seconds | constants.dart |

**Note:** For production deployment, these would need to be environment-driven.

---

## 20. Service Dependency Map

```
CodeOps-Client → Depends On:
  - CodeOps-Server: http://localhost:8090/api/v1 (all REST endpoints)
  - CodeOps-Server WebSocket: ws://localhost:8090/ws/relay (Relay messaging)
  - Jira Cloud: https://<instance>.atlassian.net/rest/api/3/ (direct, user-configured)
  - GitHub API: https://api.github.com (direct, via PAT)
  - Anthropic API: https://api.anthropic.com (direct, via API key)
  - Claude Code CLI: Local process execution for agent runs

Downstream Consumers: None (end-user desktop client)
```

---

## 21. Known Technical Debt & Issues

| Issue | Location | Severity | Notes |
|---|---|---|---|
| Tokens stored in SharedPreferences, not OS keychain | SecureStorage | Medium | SharedPreferences is not encrypted; should use flutter_secure_storage for production |
| All API URLs hardcoded | constants.dart | Medium | No environment variable support; needs config for non-localhost deployments |
| No CI/CD pipeline | Project root | Low | No GitHub Actions, Jenkinsfile, etc. |
| Router comment says "39 routes" but has 52 | router.dart:88 | Low | Comment out of date |
| No error boundary widget | App-wide | Low | Unhandled Flutter errors could crash the app |
| No offline support | All API services | Medium | App requires constant server connection; no offline queue |
| DropdownButtonFormField.initialValue deprecation | tech_debt_page.dart | Low | Should use `value` instead of `initialValue` |
| No HTTPS enforcement | constants.dart | Medium | All connections are HTTP/WS in dev; needs TLS for production |
| Duplicate provider definitions | finding_providers.dart / job_providers.dart | Low | `findingApiProvider` and `jobFindingsProvider` defined in both files |
| Duplicate provider definitions | jira_providers.dart / project_providers.dart | Low | `jiraConnectionsProvider` defined in both files |
| Vault API on separate port | constants.dart | Info | Vault uses `http://localhost:8097` (not 8090 like main API) |
