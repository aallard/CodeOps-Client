# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-03-02T19:11:50Z
**Branch:** main
**Commit:** b4cb3dfb7329bc230080d1716d60df1f5b7e2e7d — DL-019: Metadata, data, and DDL search — 3 search modes, search dialog, navigator filter, 36 tests
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml (generated separately — N/A: client-side app, no REST API surface)

> This audit is the source of truth for the CodeOps-Client codebase structure, models, services, and configuration.
> An AI reading this audit should be able to generate accurate code changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:       CodeOps-Client
Repository URL:     (local — GitHub remote not inspected)
Primary Language:   Dart / Flutter
Flutter Version:    >=3.27.0
Dart SDK:           ^3.6.0
Build Tool:         Flutter CLI + build_runner (code generation)
Package Name:       codeops
Version:            1.0.0+1
Current Branch:     main
Latest Commit:      b4cb3dfb7329bc230080d1716d60df1f5b7e2e7d
Latest Message:     DL-019: Metadata, data, and DDL search — 3 search modes, search dialog, navigator filter, 36 tests
Audit Timestamp:    2026-03-02T19:11:50Z
Target Platforms:   macOS (primary), Windows, Linux
```

---

## 2. Directory Structure

```
CodeOps-Client/
├── lib/
│   ├── main.dart                  — Entry point
│   ├── app.dart                   — Root CodeOpsApp widget
│   ├── router.dart                — GoRouter (75+ named routes)
│   ├── database/
│   │   ├── database.dart          — Drift DB class (schema v9, 26 tables)
│   │   └── tables.dart            — All table definitions
│   ├── models/                    — Domain model POJOs + enums
│   ├── providers/                 — Riverpod providers (32 files)
│   ├── services/
│   │   ├── agent/                 — Agent config, personas, report parsing
│   │   ├── analysis/              — Health, tech debt, dependency scanning
│   │   ├── auth/                  — AuthService, SecureStorageService
│   │   ├── cloud/                 — 28 API clients (Dio-based)
│   │   ├── data/                  — Scribe diff/file/persistence/sync
│   │   ├── datalens/              — Direct DB drivers + introspection
│   │   ├── integration/           — Export service
│   │   ├── jira/                  — Jira mapper/service
│   │   ├── logging/               — LogService, LogConfig, LogLevel
│   │   ├── openapi_parser.dart    — OpenAPI YAML parser
│   │   ├── orchestration/         — JobOrchestrator, AgentDispatcher, VeraManager
│   │   ├── platform/              — Claude Code detection, process management
│   │   └── vcs/                   — Git, GitHub provider, repo manager
│   ├── pages/                     — 75+ page widgets by module
│   ├── widgets/                   — Widget library by module
│   ├── theme/                     — AppTheme, Colors, Typography
│   └── utils/                     — Constants, DateUtils, StringUtils, FuzzyMatcher, etc.
├── test/                          — 512 test files (unit + widget)
├── integration_test/              — 5 integration test files
├── assets/
│   ├── personas/                  — 17 agent persona markdown files
│   └── templates/                 — Report/RCA/task markdown templates
├── pubspec.yaml
├── analysis_options.yaml
└── macos/ windows/ linux/         — Platform-specific runner code
```

Single-module Flutter project. All source in `lib/`. Generated code (`.g.dart`, `.freezed.dart`) committed but excluded from this audit.

---

## 3. Build & Dependency Manifest

**File:** `pubspec.yaml`

### Production Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Riverpod code generation annotations |
| go_router | ^14.8.1 | Declarative routing |
| drift | ^2.22.1 | SQLite ORM (local cache) |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native libs |
| postgres | ^3.5.9 | DataLens PostgreSQL driver |
| mysql_client | ^0.0.27 | DataLens MySQL driver |
| sqlite3 | ^2.4.7 | DataLens SQLite driver |
| mssql_connection | ^3.0.0 | DataLens SQL Server driver |
| dio | ^5.7.0 | HTTP client |
| flutter_markdown | ^0.7.6 | Markdown rendering |
| flutter_highlight | ^0.7.0 | Syntax highlighting |
| re_editor | ^0.8.0 | Code editor widget |
| re_highlight | ^0.0.3 | Editor highlight support |
| fl_chart | ^0.70.2 | Charts (health gauges, trends) |
| file_picker | ^8.1.7 | File import dialogs |
| desktop_drop | ^0.5.0 | Drag-and-drop file targets |
| window_manager | ^0.4.3 | Desktop window control |
| split_view | ^3.2.1 | Resizable split panels |
| diff_match_patch | ^0.4.1 | Diff computation (Scribe diff editor) |
| path | ^1.9.0 | File path utilities |
| path_provider | ^2.1.5 | Platform directories |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.20.1 | Internationalization/date formatting |
| yaml | ^3.1.3 | YAML parsing (OpenAPI specs) |
| archive | ^4.0.2 | ZIP archive support |
| url_launcher | ^6.3.1 | Open external URLs |
| shared_preferences | ^2.3.4 | Key-value storage (JWT tokens) |
| crypto | ^3.0.6 | Cryptographic utilities |
| package_info_plus | ^8.1.2 | App version info |
| connectivity_plus | ^6.1.1 | Network connectivity detection |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| freezed_annotation | ^2.4.4 | Immutable model annotations |
| collection | ^1.19.0 | Collection utilities |
| equatable | ^2.0.7 | Value equality |
| pdf | ^3.11.2 | PDF export |
| printing | ^5.13.4 | Print/PDF preview |

### Dev Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.22.1 | Drift query builder code gen |
| riverpod_generator | ^2.6.4 | Riverpod provider code gen |
| json_serializable | ^6.9.0 | JSON serialization code gen |
| freezed | ^2.5.7 | Immutable class code gen |
| mocktail | ^1.0.4 | Test mocking |
| flutter_lints | ^5.0.0 | Lint rules |
| integration_test | (SDK) | Integration test framework |

### Build Commands

```
Build:        flutter build macos
Run:          flutter run -d macos
Test:         flutter test
Test+Cover:   flutter test --coverage
Code gen:     dart run build_runner build --delete-conflicting-outputs
Package:      flutter build macos --release
```

---

## 4. Configuration & Infrastructure Summary

**File:** `lib/utils/constants.dart`
- Server: `http://localhost:8090`, prefix `/api/v1`
- Vault server: `http://localhost:8097`, prefix `/api/v1/vault`
- Relay WebSocket: `ws://localhost:8090/ws/relay`
- Anthropic API: `https://api.anthropic.com`
- Default Claude model: `claude-sonnet-4-20250514`
- Dispatch model: `claude-sonnet-4-5-20250514`
- All URLs are hardcoded constants — no environment variable injection at runtime

**File:** `lib/services/auth/secure_storage.dart`
- Uses `SharedPreferences` (UserDefaults on macOS, Registry on Windows) — deliberately NOT Keychain to avoid macOS sandbox dialog
- Stores: auth token, refresh token, user ID, selected team ID, GitHub PAT, Anthropic API key, remember-me credentials
- Logout preserves: remember-me credentials and Anthropic API key

**File:** `lib/database/database.dart`
- Drift SQLite at `getApplicationSupportDirectory()/codeops.db`
- Schema version: 9, fully migrated via `MigrationStrategy.onUpgrade`

**File:** `analysis_options.yaml`
- Uses `flutter_lints` ruleset

**Connection Map:**
```
Primary Server:     http://localhost:8090/api/v1 (CodeOps-Server)
Vault Server:       http://localhost:8097/api/v1/vault (CodeOps-Vault)
Relay WebSocket:    ws://localhost:8090/ws/relay
Anthropic API:      https://api.anthropic.com (direct Anthropic calls)
DataLens (direct):  User-configured connections to PostgreSQL/MySQL/SQLite/MSSQL
Local DB:           SQLite (Drift), platform app support directory
```

**CI/CD:** None detected.

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart` → `main()` async

**Startup sequence:**
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogConfig.initialize()` — sets up structured logging with file rotation
3. `windowManager.ensureInitialized()` — desktop window setup (1440×900, min 1024×700, hidden title bar)
4. `windowManager.waitUntilReadyToShow()` → show + focus window
5. `runApp(ProviderScope(child: CodeOpsApp()))`
6. `CodeOpsApp.build()` — listens to `authStateProvider` stream
7. On `AuthState.authenticated`: `_initTeamSelection()` (fetches teams, selects stored or first), `_initAgentConfig()` (seeds 17 built-in agents if empty, refreshes Anthropic model cache)
8. GoRouter `redirect` gate: unauthenticated → `/login`, authenticated on `/login` → `/`

**Health check endpoint:** None (desktop app — no HTTP server).

**Scheduled tasks:** None — polling is done in specific providers on demand.

**Background processes:** Claude Code CLI subprocess dispatch via `ProcessManager` (AgentDispatcher).

---

## 6. Local Database — Drift SQLite (26 Tables)

Schema version: **9**. File path: `{AppSupportDir}/codeops.db`. All tables mirror CodeOps-Server PostgreSQL entities. Enum fields stored as SCREAMING_SNAKE_CASE text.

```
=== Users ===
PK: id (text, UUID)
Fields: email, displayName, avatarUrl (nullable), isActive (default true), lastLoginAt (nullable), createdAt (nullable)

=== Teams ===
PK: id (text, UUID)
Fields: name, description, ownerId, ownerName, teamsWebhookUrl, memberCount, createdAt, updatedAt

=== Projects ===
PK: id (text, UUID)
Fields: teamId, name, description, githubConnectionId, repoUrl, repoFullName, defaultBranch, jiraConnectionId, jiraProjectKey, techStack, healthScore, lastAuditAt, isArchived (default false), createdAt, updatedAt

=== QaJobs ===
PK: id (text, UUID)
Fields: projectId, projectName, mode (text enum), status (text enum), name, branch, configJson, summaryMd, overallResult, healthScore, totalFindings, criticalCount, highCount, mediumCount, lowCount, jiraTicketKey, startedBy, startedByName, startedAt, completedAt, createdAt

=== AgentRuns ===
PK: id (text, UUID)
Fields: jobId, agentType (text enum), status (text enum), result (nullable text enum), reportS3Key, score, findingsCount, criticalCount, highCount, startedAt, completedAt

=== Findings ===
PK: id (text, UUID)
Fields: jobId, agentType, severity (text enum), title, description, filePath, lineNumber, recommendation, evidence, effortEstimate, debtCategory, findingStatus (text enum), statusChangedBy, statusChangedAt, createdAt

=== RemediationTasks ===
PK: id (text, UUID)
Fields: jobId, taskNumber, title, description, promptMd, priority, status (text enum), assignedTo, assignedToName, jiraKey, createdAt

=== Personas ===
PK: id (text, UUID)
Fields: name, agentType, description, contentMd, scope (text enum), teamId, createdBy, createdByName, isDefault (default false), version, createdAt, updatedAt

=== Directives ===
PK: id (text, UUID)
Fields: name, description, contentMd, category, scope (text enum), teamId, projectId, createdBy, createdByName, version, createdAt, updatedAt

=== TechDebtItems ===
PK: id (text, UUID)
Fields: projectId, category (text enum), title, description, filePath, effortEstimate, businessImpact, status (text enum), firstDetectedJobId, resolvedJobId, createdAt, updatedAt

=== DependencyScans ===
PK: id (text, UUID)
Fields: projectId, jobId, manifestFile, totalDependencies, outdatedCount, vulnerableCount, createdAt

=== DependencyVulnerabilities ===
PK: id (text, UUID)
Fields: scanId, dependencyName, currentVersion, fixedVersion, cveId, severity (text enum), description, status (text enum), createdAt

=== HealthSnapshots ===
PK: id (text, UUID)
Fields: projectId, jobId, healthScore, findingsBySeverity (JSON text), techDebtScore, dependencyScore, testCoveragePercent (real), capturedAt

=== ComplianceItems ===
PK: id (text, UUID)
Fields: jobId, requirement, specId, specName, status (text enum), evidence, agentType, notes, createdAt

=== Specifications ===
PK: id (text, UUID)
Fields: jobId, name, specType, s3Key, createdAt

=== ClonedRepos ===
PK: repoFullName (text, "owner/repo")
Fields: localPath, projectId, clonedAt, lastAccessedAt

=== SyncMetadata ===
PK: syncTableName (text)
Fields: lastSyncAt, etag

=== AnthropicModels ===
PK: id (text, model ID)
Fields: displayName, modelFamily, contextWindow, maxOutputTokens, fetchedAt

=== AgentDefinitions ===
PK: id (text, UUID)
Fields: name, agentType, isQaManager (default false), isBuiltIn (default true), isEnabled (default true), modelId, temperature (default 0.0), maxRetries (default 1), timeoutMinutes, maxTurns (default 50), systemPromptOverride, description, sortOrder, createdAt, updatedAt

=== AgentFiles ===
PK: id (text, UUID)
Fields: agentDefinitionId, fileName, fileType, contentMd, filePath, sortOrder, createdAt, updatedAt

=== ProjectLocalConfig ===
PK: projectId (text, UUID)
Fields: localWorkingDir

=== ScribeTabs ===
PK: id (text, UUID)
Fields: title, filePath (nullable), content, language, isDirty (default false), cursorLine (default 0), cursorColumn (default 0), scrollOffset (default 0.0), displayOrder, createdAt, lastModifiedAt

=== ScribeSettings ===
PK: key (text)
tableName: scribe_settings
Fields: value (JSON text)

=== DatalensConnections ===
PK: id (text, UUID)
Fields: name, driver (default 'POSTGRESQL'), host, port (default 5432), database, schema, username, password (nullable), useSsl (default false), sslMode, color, connectionTimeout (default 10), filePath (nullable, for SQLite), lastConnectedAt, createdAt, updatedAt

=== DatalensQueryHistory ===
PK: id (text, UUID)
Fields: connectionId, sql, status (text enum), rowCount, executionTimeMs, error, executedAt

=== DatalensSavedQueries ===
PK: id (text, UUID)
Fields: connectionId, name, description, sql, folder, createdAt, updatedAt
```

**Migration history (schema versions):**
- v1→2: created `clonedRepos`
- v2→3: added `qaJobs.configJson`
- v3→4: added `qaJobs.summaryMd`, `qaJobs.startedByName`, `findings.statusChangedBy`, `findings.statusChangedAt`
- v4→5: created `anthropicModels`, `agentDefinitions`, `agentFiles`
- v5→6: created `projectLocalConfig`
- v6→7: created `scribeTabs`, `scribeSettings`
- v7→8: created `datalensConnections`, `datalensQueryHistory`, `datalensSavedQueries`
- v8→9: added `datalensConnections.filePath`

---

## 7. Enum Inventory

**File:** `lib/models/enums.dart` — Primary domain enums. All serialize to/from SCREAMING_SNAKE_CASE strings. Every enum provides `toJson()`, `fromJson(String)`, and `displayName`.

| Enum | Values |
|------|--------|
| AgentResult | pass, warn, fail |
| AgentStatus | pending, running, completed, failed, cancelled |
| AgentType | security, codeQuality, buildHealth, completeness, apiContract, testCoverage, uiUx, documentation, database, performance, dependency, architecture, chaosMoney, hostileUser, complianceAuditor, loadSaboteur |
| ComplianceStatus | met, partial, notMet, notApplicable, pending |
| DebtCategory | codeQuality, architecture, performance, security, testing, documentation, dependencies, other |
| EffortEstimate | trivial, small, medium, large, epic |
| FindingStatus | open, acknowledged, inProgress, resolved, falsePositive, wontFix |
| JobMode | auditAndFix, compliance, bugInvestigate, custom |
| JobResult | pass, warn, fail |
| JobStatus | pending, running, completed, failed, cancelled |
| PersonaScope | team, project, global |
| DirectiveScope | team, project, global |
| DirectiveCategory | coding, testing, documentation, architecture, security, performance, other |
| Severity | critical, high, medium, low |
| SpecType | openapi, requirements, compliance, custom |
| TeamMemberRole | OWNER, ADMIN, LEAD, MEMBER |
| VulnerabilityStatus | open, acknowledged, fixed, falsePositive |

**File:** `lib/models/courier_enums.dart` — Courier HTTP testing enums.
- `BodyType`: NONE, FORM_DATA, X_WWW_FORM_URLENCODED, RAW_JSON, RAW_XML, RAW_HTML, RAW_TEXT, RAW_YAML, BINARY, GRAPHQL
- `AuthType`: NO_AUTH, API_KEY, BEARER_TOKEN, BASIC_AUTH, OAUTH2_AUTHORIZATION_CODE, OAUTH2_CLIENT_CREDENTIALS, OAUTH2_IMPLICIT, OAUTH2_PASSWORD, JWT_BEARER, INHERIT_FROM_PARENT
- `ScriptType`: PRE_REQUEST, POST_RESPONSE

**File:** `lib/models/datalens_enums.dart` — DataLens database enums.
- `DbDriver`: POSTGRESQL, MYSQL, SQLITE, SQL_SERVER
- `QueryStatus`: SUCCESS, ERROR, RUNNING, CANCELLED
- `ColumnType`: text, integer, decimal, boolean, datetime, json, uuid, binary, unknown
- `ConstraintType`: primary, foreign, unique, check, notNull

**File:** `lib/models/fleet_enums.dart` — Fleet Docker enums.
- `ContainerState`: created, restarting, running, removing, paused, exited, dead
- `NetworkDriver`: bridge, host, overlay, macvlan, none
- `VolumeDriver`: local

**File:** `lib/models/logger_enums.dart` — Logger module enums.
- `LogLevel`: TRACE, DEBUG, INFO, WARN, ERROR, FATAL
- `AlertSeverity`: INFO, WARNING, CRITICAL
- `TrapType`: KEYWORD, REGEX, THRESHOLD, ANOMALY
- `AggregationFunction`: COUNT, SUM, AVG, MIN, MAX, P50, P95, P99

**File:** `lib/models/vault_enums.dart` — Vault enums.
- `VaultSecretStatus`: ACTIVE, EXPIRING_SOON, EXPIRED, REVOKED, PENDING_ROTATION
- `VaultSecretType`: KV, DATABASE, SSH, PKI, AWS, AZURE, GCP, GENERIC
- `RotationStatus`: ACTIVE, PENDING, IN_PROGRESS, COMPLETED, FAILED, PAUSED
- `SealStatus`: SEALED, UNSEALED, INITIALIZING

**File:** `lib/models/registry_enums.dart` — Registry enums.
- `ServiceStatus`: ACTIVE, DEPRECATED, EXPERIMENTAL, MAINTENANCE, RETIRED
- `ServiceType`: API, WORKER, FRONTEND, DATABASE, CACHE, MESSAGE_BROKER, GATEWAY, SCHEDULER, MONITOR, CLI
- `InfraResourceType`: SERVER, LOAD_BALANCER, DATABASE, CACHE, STORAGE, CDN, DNS, FIREWALL, QUEUE, OTHER
- `PortProtocol`: TCP, UDP, HTTP, HTTPS, GRPC, WS, WSS

**File:** `lib/models/relay_enums.dart` — Relay messaging enums.
- `ChannelType`: PUBLIC, PRIVATE
- `MessageType`: text, file, system, thread_reply
- `RelayEventType`: channel_message, dm_message, user_joined, user_left, typing, presence_changed, reaction_added

**File:** `lib/models/mcp_enums.dart` — MCP server enums.
- `McpTransport`: STDIO, HTTP, SSE

---

## 8. Service Layer

### Auth Services (`lib/services/auth/`)

```
=== AuthService ===
Injects: ApiClient, SecureStorageService, CodeOpsDatabase
Public Methods:
  - login(email, password): Future<User>
    Calls: POST /auth/login, SecureStorageService.setAuthToken/setRefreshToken/setCurrentUserId
  - register(email, password, displayName): Future<User>
    Calls: POST /auth/register
  - refreshToken(): Future<void>
    Calls: POST /auth/refresh
  - changePassword(currentPassword, newPassword): Future<void>
    Calls: POST /auth/change-password
  - logout(): Future<void>
    Calls: SecureStorageService.clearAll(), CodeOpsDatabase.clearAllTables()
  - tryAutoLogin(): Future<void>
    Calls: GET /users/me; validates stored token
  - dispose(): void

=== SecureStorageService ===
Injects: SharedPreferences (injectable for tests)
Storage keys: auth_token, refresh_token, current_user_id, selected_team_id, github_pat, codeops_anthropic_api_key, remember_me, remembered_email, remembered_password
Public Methods: getAuthToken, setAuthToken, getRefreshToken, setRefreshToken, getCurrentUserId, setCurrentUserId, getSelectedTeamId, setSelectedTeamId, read, write, delete, getAnthropicApiKey, setAnthropicApiKey, deleteAnthropicApiKey, clearAll
clearAll() preserves: remember-me credentials + Anthropic API key
```

### HTTP Client (`lib/services/cloud/api_client.dart`)

```
=== ApiClient ===
Base URL: http://localhost:8090/api/v1
Timeouts: connect 15s, receive 30s, send 15s
Interceptors (in order):
  1. Auth: attaches "Authorization: Bearer <token>" to non-public paths
  2. Refresh: on 401, refreshes token once and retries; triggers logout on failure
  3. Error: maps DioException to typed ApiException hierarchy
  4. Logging: correlation IDs, request/response timing (no body/token logging)
Public paths (no auth header): /auth/login, /auth/register, /auth/refresh, /health
Methods: get<T>, post<T>, put<T>, delete<T>, uploadFile<T>, downloadFile

=== ApiException hierarchy (sealed) ===
BadRequestException (400), UnauthorizedException (401), ForbiddenException (403),
NotFoundException (404), ConflictException (409), ValidationException (422),
RateLimitException (429, retryAfterSeconds), ServerException (5xx),
NetworkException (no connection), TimeoutException (request timeout)
```

### Cloud API Services (`lib/services/cloud/`)

27 Dio-based API services, all constructor-injected with `ApiClient`. Each wraps a module domain:

| Service | Endpoints Covered |
|---------|------------------|
| AdminApi | User management, settings, audit logs, usage stats |
| AnthropicApiService | `GET /v1/models` (direct Anthropic API, not via server) |
| ComplianceApi | Compliance items, specs, gap analysis |
| CourierApi | HTTP request testing (collections, requests, environments) |
| DependencyApi | Dependency scans, vulnerabilities |
| DirectiveApi | Directive CRUD |
| FindingApi | Finding CRUD, batch create, status updates |
| FleetApi | Docker containers, images, volumes, networks, service/solution/workstation profiles |
| HealthMonitorApi | Health snapshots, project health, schedule management |
| IntegrationApi | Jira/GitHub integration connections |
| JobApi | Job CRUD, agent run CRUD, batch agent run creation |
| LoggerApi | Log search, log viewer, traps, alerts, dashboards, metrics, traces, retention |
| McpApi | MCP server management |
| MetricsApi | Application metrics |
| PersonaApi | Persona CRUD |
| ProjectApi | Project CRUD |
| RegistryApi | Service registry, port allocation, topology, impact analysis, config generation, API routes, infra resources, workstation profiles |
| RegistryApiClient | Registry-specific Dio instance (X-Team-Id header) |
| RelayApi | Channel/DM messaging REST endpoints |
| RelayWebSocketService | WebSocket connection for real-time messaging |
| ReportApi | Agent report upload, summary report upload, report download |
| TaskApi | Remediation task CRUD |
| TeamApi | Team CRUD, member management |
| TechDebtApi | Tech debt item CRUD |
| UserApi | User profile management |
| VaultApi | HashiCorp Vault secrets, policies, transit, dynamic, rotation, seal, audit |
| VaultApiClient | Vault-specific Dio instance (localhost:8097/api/v1/vault) |

### Orchestration Services (`lib/services/orchestration/`)

```
=== JobOrchestrator ===
Injects: AgentDispatcher, AgentMonitor, VeraManager, ProgressAggregator, ReportParser, JobApi, FindingApi, ReportApi, AgentProgressNotifier?
Public Methods:
  - executeJob({projectId, projectName, projectPath, teamId, branch, mode, selectedAgents, config, jobName?, additionalContext?, jiraTicketKey?, jiraTicketData?, specReferences?}): Future<JobResult>
    10-step lifecycle: create job → create agent runs → set RUNNING → dispatch → parse+upload each → Vera consolidate → batch upload findings → upload summary → finalize job → emit JobCompleted
  - cancelJob(jobId): Future<void>
  - get activeJobId: String?
  - get lifecycleStream: Stream<JobLifecycleEvent>
Lifecycle events (sealed): JobCreated, JobStarted, AgentPhaseStarted, AgentPhaseProgress, ConsolidationStarted, SyncStarted, JobCompleted, JobFailed, JobCancelled

=== VeraManager ===
Injects: nothing
Public Methods:
  - consolidate({jobId, projectName, agentReports, mode}): Future<VeraReport>
  - calculateHealthScore(reports): int — weighted average (security/arch x1.5, others x1.0)
  - deduplicateFindings(allFindings): List<ParsedFinding> — Levenshtein similarity >= 0.8 + file/line proximity
  - determineOverallResult(findings): JobResult
  - generateExecutiveSummary({...}): Future<String> — Markdown template (no AI call)

=== AgentDispatcher ===
Injects: ProcessManager, AgentConfigService, PersonaManager, DirectiveApi, PersonaApi
Purpose: Spawns Claude Code CLI subprocesses for each agent type, respects concurrency limit, streams NDJSON output, manages timeout
Public Methods:
  - dispatchAll({agentTypes, teamId, projectId, projectPath, branch, mode, projectName, config, additionalContext?, jiraTicketData?, specReferences?}): Stream<AgentDispatchEvent>
  - cancelAll(): Future<void>

=== AgentMonitor ===
Injects: nothing
Purpose: Monitors active agent processes

=== ProgressAggregator ===
Injects: nothing
Purpose: Aggregates per-agent progress into a single JobProgress snapshot, maintains live findings feed
```

### Agent Services (`lib/services/agent/`)

```
=== AgentConfigService ===
Injects: CodeOpsDatabase, AnthropicApiService, SecureStorageService
Public Methods:
  - getCachedModels(): Future<List<AnthropicModelInfo>>
  - cacheModels(models): Future<void>
  - refreshModels(): Future<List<AnthropicModelInfo>>
  - getAllAgents(): Future<List<AgentDefinition>>
  - getAgent(id): Future<AgentDefinition?>
  - createAgent({name, description?, agentType?}): Future<AgentDefinition>
  - updateAgent(id, {name?, description?, agentType?, isEnabled?, modelId?, temperature?, maxRetries?, timeoutMinutes?, maxTurns?, systemPromptOverride?}): Future<void>
  - deleteAgent(id): Future<void> — throws StateError if isBuiltIn
  - reorderAgents(orderedIds): Future<void>
  - getAgentFiles(agentDefinitionId): Future<List<AgentFile>>
  - addFile(agentDefinitionId, {fileName, fileType, contentMd?, filePath?}): Future<AgentFile>
  - updateFile(fileId, {fileName?, contentMd?, fileType?}): Future<void>
  - deleteFile(fileId): Future<void>
  - importFileFromDisk(agentDefinitionId): Future<AgentFile?> — opens FilePicker (.md/.txt/.markdown)
  - seedBuiltInAgents(): Future<void> — idempotent, seeds 17 agents if table empty

Built-in agents (17):
  Vera (QA manager), Security, Code Quality, Build Health, Completeness, API Contract,
  Test Coverage, UI/UX, Documentation, Database, Performance, Dependency, Architecture,
  Chaos Monkey, Hostile User, Compliance Auditor, Load Saboteur

=== PersonaManager ===
Injects: PersonaApi, AgentConfigService
Purpose: Loads agent persona markdown (server persona or local AgentFile) for prompt assembly

=== ReportParser ===
Injects: nothing
Purpose: Parses Claude Code agent output markdown into ParsedReport (metadata, executiveSummary, findings, metrics)

=== TaskGenerator ===
Injects: nothing
Purpose: Generates remediation task prompts from ParsedFindings
```

### DataLens Services (`lib/services/datalens/`)

```
Drivers: PostgresqlDriver, MysqlDriver, SqliteDriver, SqlServerDriver (all implement DatabaseDriverAdapter)
DriverFactory: creates driver instance from DbDriver enum
DatabaseConnectionService: manages active connection lifecycle
SchemaIntrospectionService: fetches tables, columns, indexes, constraints, foreign keys, dependencies
QueryExecutionService: executes SQL, tracks timing and row count
QueryHistoryService: persists query history to DatalensQueryHistory table
DatalensSavedQueriesService: CRUD for saved queries in DatalensSavedQueries table
DataEditorService: in-memory pending changes (insert/update/delete) with commit/rollback
DbAdminService: server info, active sessions, index usage, lock monitor, table stats
SqlAutocompleteService: SQL keyword + schema-aware completion
ErDiagramService: builds ER diagram from schema introspection
ErExportService: exports ER diagram as SVG/PNG
DatalensSearchService: 3-mode search (metadata, data, DDL) across schema and table data
CsvImportService, SqlScriptImportService, TableTransferService: data import utilities
```

### Analysis Services (`lib/services/analysis/`)

```
=== HealthCalculator ===
Purpose: Computes project health score from findings, tech debt, and dependency scans
=== TechDebtTracker ===
Purpose: Deduplicates and categorizes tech debt findings across jobs
=== DependencyScanner ===
Purpose: Parses dependency manifest files locally (pubspec.yaml, pom.xml, package.json)
```

### VCS Services (`lib/services/vcs/`)

```
GitService: local git operations via ProcessManager (status, diff, commit, push, stash)
GitHubProvider: GitHub REST API via ApiClient (repos, branches, PRs, CI status)
RepoManager: manages cloned repo registry (ClonedRepos table), clone/fetch/pull
VcsProvider (abstract): interface for VCS adapters
```

### Other Services

```
LogService (lib/services/logging/): Singleton structured logger (6 levels: verbose/debug/info/warn/error/fatal), ANSI console colors, daily file rotation (7-day purge), tag muting
LogConfig: minimumLevel, mutedTags, enableFileLogging, enableConsoleColors, logDirectory
JiraService + JiraMapper: Jira issue CRUD via IntegrationApi
OpenApiParser: parses OpenAPI YAML specs for Registry API Docs viewer
ClaudeCodeDetector: detects Claude Code CLI installation and version
ProcessManager: spawns and monitors system processes (used by AgentDispatcher for Claude Code)
ScribeDiffService, ScribeFileService, ScribePersistenceService, SyncService: Scribe editor services
ExportService: exports job reports and findings to PDF/JSON/Markdown
```

---

## 9. Provider Layer (Riverpod)

**32 provider files** in `lib/providers/`. All follow the Riverpod pattern with `Provider<T>`, `StateProvider<T>`, `StreamProvider<T>`, `FutureProvider<T>`, and `@riverpod`-generated providers.

**Core providers:**
- `secureStorageProvider` → `SecureStorageService`
- `apiClientProvider` → `ApiClient`
- `databaseProvider` → `CodeOpsDatabase`
- `authServiceProvider` → `AuthService`
- `authStateProvider` → `Stream<AuthState>`
- `currentUserProvider` → `User?`
- `selectedTeamIdProvider` → `String?`

**Feature provider domains:** agent_config, agent_progress, agent, auth, compliance, courier, datalens, dependency, directive, finding, fleet, github, health, jira, job, logger, mcp, persona, project_local_config, project, registry, relay, report, scribe, settings, task, team, tech_debt, user, vault, wizard

---

## 10. Router

**File:** `lib/router.dart`

GoRouter with 75 named routes. Auth guard via `AuthNotifier` (ChangeNotifier bridging `AuthService.authStateStream`).

**Redirect logic:**
- `!authenticated && !onLogin` → `/login`
- `authenticated && onLogin` → `/`

**Route map (key routes):**

| Route Name | Path | Page |
|---|---|---|
| login | /login | LoginPage |
| setup | /setup | PlaceholderPage("Setup Wizard") — **INCOMPLETE** |
| home | / | HomePage |
| projects | /projects | ProjectsPage |
| projectDetail | /projects/:id | ProjectDetailPage |
| repos | /repos | GitHubBrowserPage |
| scribe | /scribe | ScribePage |
| audit | /audit | AuditWizardPage |
| compliance | /compliance | ComplianceWizardPage |
| dependencies | /dependencies | DependencyScanPage |
| bugs | /bugs | BugInvestigatorPage |
| jiraBrowser | /bugs/jira | JiraBrowserPage |
| tasks | /tasks | TaskManagerPage |
| techDebt | /tech-debt | TechDebtPage |
| health | /health | HealthDashboardPage |
| history | /history | JobHistoryPage |
| jobProgress | /jobs/:id | JobProgressPage |
| jobReport | /jobs/:id/report | JobReportPage |
| findingsExplorer | /jobs/:id/findings | FindingsExplorerPage |
| taskList | /jobs/:id/tasks | TaskListPage |
| personas | /personas | PersonasPage |
| personaEditor | /personas/:id/edit | PersonaEditorPage |
| directives | /directives | DirectivesPage |
| settings | /settings | SettingsPage |
| admin | /admin | AdminHubPage |
| vault | /vault | VaultDashboardPage |
| vault-secrets | /vault/secrets | VaultSecretsPage |
| vault-secret-detail | /vault/secrets/:id | VaultSecretDetailPage |
| vault-policies | /vault/policies | VaultPoliciesPage |
| vault-policy-detail | /vault/policies/:id | VaultPolicyDetailPage |
| vault-transit | /vault/transit | VaultTransitPage |
| vault-dynamic | /vault/dynamic | VaultDynamicPage |
| vault-rotation | /vault/rotation | VaultRotationPage |
| vault-seal | /vault/seal | VaultSealPage |
| vault-audit | /vault/audit | VaultAuditPage |
| registry | /registry | ServiceListPage |
| registry-service-new | /registry/services/new | ServiceFormPage |
| registry-service-detail | /registry/services/:id | ServiceDetailPage |
| registry-service-edit | /registry/services/:id/edit | ServiceFormPage |
| registry-ports | /registry/ports | PortAllocationPage |
| registry-solutions | /registry/solutions | SolutionListPage |
| registry-solution-detail | /registry/solutions/:solutionId | SolutionDetailPage |
| registry-dependencies | /registry/dependencies | DependencyGraphPage |
| registry-impact-analysis | /registry/dependencies/impact | ImpactAnalysisPage |
| registry-topology | /registry/topology | TopologyPage |
| registry-infra | /registry/infra | InfraResourcesPage |
| registry-routes | /registry/routes | ApiRoutesPage |
| registry-config | /registry/config | ConfigGeneratorPage |
| registry-workstations | /registry/workstations | WorkstationListPage |
| registry-workstation-detail | /registry/workstations/:profileId | WorkstationDetailPage |
| registry-api-docs | /registry/api-docs | ApiDocsPage |
| registry-api-docs-service | /registry/api-docs/:serviceId | ApiDocsPage |
| fleet | /fleet | FleetDashboardPage |
| fleet-containers | /fleet/containers | ContainerListPage |
| fleet-container-detail | /fleet/containers/:id | ContainerDetailPage |
| fleet-service-profiles | /fleet/service-profiles | ServiceProfileListPage |
| fleet-service-profile-detail | /fleet/service-profiles/:id | ServiceProfileDetailPage |
| fleet-solution-profiles | /fleet/solution-profiles | SolutionProfileListPage |
| fleet-solution-profile-detail | /fleet/solution-profiles/:id | SolutionProfileDetailPage |
| fleet-workstation-profiles | /fleet/workstation-profiles | WorkstationProfileListPage |
| fleet-workstation-profile-detail | /fleet/workstation-profiles/:id | WorkstationProfileDetailPage |
| fleet-images | /fleet/images | ImageListPage |
| fleet-volumes | /fleet/volumes | VolumeListPage |
| fleet-networks | /fleet/networks | NetworkListPage |
| datalens | /datalens | DatalensPage |
| logger | /logger | LoggerDashboardPage |
| logger-viewer | /logger/viewer | LogViewerPage |
| logger-search | /logger/search | LogSearchPage |
| logger-traps | /logger/traps | LogTrapsPage |
| logger-trap-edit | /logger/traps/:id/edit | TrapEditorPage |
| logger-alerts | /logger/alerts | AlertsPage |
| logger-alert-channels | /logger/alerts/channels | AlertChannelsPage |
| logger-dashboards | /logger/dashboards | LogDashboardsPage |
| logger-dashboard-detail | /logger/dashboards/:id | DashboardDetailPage |
| logger-metrics | /logger/metrics | MetricsExplorerPage |
| logger-traces | /logger/traces | TraceViewerPage |
| logger-trace-detail | /logger/traces/:correlationId | TraceDetailPage |
| logger-retention | /logger/retention | RetentionAdminPage |
| relay | /relay | RelayPage |
| relay-channel | /relay/channel/:channelId | RelayPage |
| relay-thread | /relay/channel/:channelId/thread/:messageId | RelayPage |
| relay-dm | /relay/dm/:conversationId | RelayPage |

---

## 11. Security Configuration

```
Authentication: JWT Bearer tokens
Storage: SharedPreferences (NOT Keychain — macOS sandbox workaround)
Token sources: access token (auth_token), refresh token (refresh_token)
Auto-refresh: on 401, single attempt via fresh Dio instance (prevents interceptor loop)
On refresh failure: logout triggered via AuthService._handleAuthFailure()

Public endpoints (no token required):
  - POST /auth/login
  - POST /auth/register
  - POST /auth/refresh
  - GET /health

Sensitive data logging: PROHIBITED — LogService contract explicitly forbids logging tokens/passwords/PII
Correlation IDs: X-Correlation-ID header on every request
CORS: N/A (desktop app, no browser CORS)
CSRF: N/A (not browser-based)
Rate limiting: handled server-side; client receives RateLimitException with retryAfterSeconds
```

**Security concern:** Tokens stored in `SharedPreferences` (unencrypted UserDefaults on macOS) rather than Keychain. This is a known, intentional trade-off documented in `SecureStorageService` to avoid macOS password dialogs. Acceptable for a local dev tool but should be addressed before multi-user production deployment.

---

## 12. Exception Handling

**File:** `lib/services/cloud/api_exceptions.dart`

Sealed `ApiException` hierarchy enables exhaustive pattern matching. All cloud API calls propagate typed exceptions. The UI layer catches these in providers and surfaces them via error state.

```
ApiException (sealed)
  ├── BadRequestException (400, optional Map<String, String> errors)
  ├── UnauthorizedException (401)
  ├── ForbiddenException (403)
  ├── NotFoundException (404)
  ├── ConflictException (409)
  ├── ValidationException (422, optional fieldErrors)
  ├── RateLimitException (429, retryAfterSeconds?)
  ├── ServerException (500+, statusCode required)
  ├── NetworkException (no statusCode)
  └── TimeoutException (no statusCode)
```

---

## 13. Key Utility Classes

**File:** `lib/utils/constants.dart`
- `AppConstants` — All application-level constants. No magic strings/numbers in service code.
- Key values: apiBaseUrl, vaultApiBaseUrl, relayWebSocketUrl, all SharedPreferences keys, agent weight constants, deduplication thresholds, Scribe editor defaults

**File:** `lib/utils/date_utils.dart` — Date formatting/parsing utilities.

**File:** `lib/utils/string_utils.dart` — String manipulation helpers.

**File:** `lib/utils/file_utils.dart` — File path and size utilities.

**File:** `lib/utils/fuzzy_matcher.dart` — Fuzzy string matching (used in navigator search, quick-open).

**File:** `lib/utils/markdown_heading_parser.dart` — Parses markdown headings for TOC generation (Scribe).

---

## 14. Theme System

**File:** `lib/theme/app_theme.dart` — `AppTheme.darkTheme` (single dark theme, no light mode).

**File:** `lib/theme/colors.dart` — `CodeOpsColors` class with all static color constants.

**File:** `lib/theme/typography.dart` — Text style definitions.

---

## 15. Module Summary

| Module | Pages | Widgets | Services | Notes |
|--------|-------|---------|----------|-------|
| Core/Auth | login, home | shell/navigation_shell, dashboard/* | AuthService, SecureStorageService | JWT, auto-refresh |
| Projects | projects, project_detail | — | ProjectApi, HealthCalculator | |
| QA Jobs | audit_wizard, job_progress, job_report, job_history, findings_explorer, task_list, task_manager | progress/*, wizard/*, findings/*, reports/* | JobOrchestrator, AgentDispatcher, VeraManager, ReportParser | Claude Code subprocess |
| Compliance | compliance_wizard | compliance/* | ComplianceApi | Spec upload + gap analysis |
| Personas | personas, persona_editor | personas/* | PersonaApi, PersonaManager | |
| Directives | directives | — | DirectiveApi | |
| VCS/GitHub | github_browser | vcs/* | GitService, GitHubProvider, RepoManager | |
| Scribe | scribe | scribe/* (35+ widgets) | ScribeFileService, ScribePersistenceService, ScribeDiffService | Code editor, session persistence |
| DataLens | datalens, db_admin, er_diagram | datalens/* (50+ widgets) | DB drivers, schema introspection, SQL autocomplete, ER export, search | Direct DB connection |
| Registry | 15 registry pages | registry/* (30+ widgets) | RegistryApi | Service catalog, topology |
| Fleet | 14 fleet pages | fleet/* (20+ widgets) | FleetApi | Docker management |
| Logger | 12 logger pages | logger/* (20+ widgets) | LoggerApi | Log search, metrics, tracing |
| Vault | 10 vault pages | vault/* (30+ widgets) | VaultApi, VaultApiClient | HashiCorp Vault |
| Relay | relay page + sub-routes | relay/* (25+ widgets) | RelayApi, RelayWebSocketService | Real-time messaging |
| Dependency | dependency_scan | dependency/* | DependencyApi, DependencyScanner | CVE scanning |
| Tech Debt | tech_debt | tech_debt/* | TechDebtApi, TechDebtTracker | |
| Health | health_dashboard | health/* | HealthMonitorApi, HealthCalculator | |
| Admin | admin_hub | admin/* | AdminApi | User mgmt, audit logs |
| Settings | settings | settings/*, shared/* | AgentConfigService, SecureStorageService | Agent config, API keys |
| Bug Investigator | bug_investigator | — | JobOrchestrator | Jira-linked bug analysis |
| Jira | jira_browser | jira/* | JiraService, JiraMapper | |

---

## 16. Database Schema (Live)

CodeOps-Client is a Flutter desktop app. No PostgreSQL database — the local SQLite database is managed by Drift (schema documented in Section 6). DataLens connects to user-configured external databases (PostgreSQL/MySQL/SQLite/SQL Server) — those schemas are not part of this application.

---

## 17. Message Broker

**Relay WebSocket** (`lib/services/cloud/relay_websocket_service.dart`):
- URL: `ws://localhost:8090/ws/relay` (constant `AppConstants.relayWebSocketUrl`)
- Heartbeat: 30s (`AppConstants.relayHeartbeatIntervalSeconds`)
- Reconnect: exponential backoff, max 30s delay
- Used by Relay module for real-time channel messaging and DM

No traditional message broker (no Kafka, RabbitMQ, SQS).

---

## 18. Cache Layer

Local Drift SQLite serves as the offline cache for server data. No Redis or in-memory cache layer. Sync metadata tracked in `SyncMetadata` table (lastSyncAt, etag per table).

Anthropic model cache: `AnthropicModels` table, refreshed on login via `AgentConfigService.refreshModels()`.

---

## 19. Environment Variable Inventory

CodeOps-Client is a Flutter desktop app — no environment variables at runtime. All configuration is in `lib/utils/constants.dart` (hardcoded) or persisted in `SharedPreferences` at runtime by the user:

| Key | Storage | Set by |
|-----|---------|--------|
| auth_token | SharedPreferences | Login flow |
| refresh_token | SharedPreferences | Login flow |
| current_user_id | SharedPreferences | Login flow |
| selected_team_id | SharedPreferences | Team selection |
| github_pat | SharedPreferences | Settings page |
| codeops_anthropic_api_key | SharedPreferences | Settings page |
| claude_model | SharedPreferences | Settings page |
| max_concurrent_agents | SharedPreferences | Settings page |
| agent_timeout_minutes | SharedPreferences | Settings page |
| remember_me / remembered_email / remembered_password | SharedPreferences | Login page |

---

## 20. Service Dependency Map

```
CodeOps-Client → Depends On:
  CodeOps-Server (http://localhost:8090/api/v1) — core server
  CodeOps-Vault  (http://localhost:8097/api/v1/vault) — Vault module
  Anthropic API  (https://api.anthropic.com) — model list + direct Claude calls
  Claude Code CLI (subprocess) — agent dispatch
  User-configured databases (DataLens) — PostgreSQL/MySQL/SQLite/SQL Server

Downstream consumers: None (desktop client, not an API server)
```

---

## 21. Known Technical Debt & Issues

**TODO/FIXME Scan Results:** No actual code TODOs or FIXME markers found in `lib/`. The two grep matches were description strings inside `_BuiltInAgentSpec` data (not code issues).

| Issue | Location | Severity | Notes |
|-------|----------|----------|-------|
| /setup route uses PlaceholderPage | lib/pages/placeholder_page.dart, router.dart:139 | MEDIUM | Setup Wizard not implemented; shows "Coming soon" |
| Tokens in SharedPreferences (unencrypted) | lib/services/auth/secure_storage.dart | MEDIUM | Intentional trade-off for macOS dev tool; not suitable for production |
| Server URLs hardcoded | lib/utils/constants.dart | LOW | localhost:8090 / localhost:8097 — no user-configurable base URL in settings |
| Test coverage 55.4% | coverage/lcov.info | CRITICAL-BLOCKING | Below 100% mandatory threshold. 44,452/80,272 lines covered |
| Class DartDoc coverage 56.3% | lib/ | CRITICAL-BLOCKING | 1,160/2,061 classes documented. 100% required (excluding generated) |
| mssql_connection:3.0.0 | pubspec.yaml | LOW | Windows-only MSSQL driver; may limit macOS DataLens SQL Server support |
| No CI/CD pipeline | Project root | LOW | No .github/workflows or equivalent found |

---

## 22. Security Vulnerability Scan (Snyk)

**Scan Date:** 2026-03-02T19:11:50Z

### Dependency Vulnerabilities (Open Source)
Critical: 0
High: 0
Medium: 0
Low: 0

**Result: PASS** — No known vulnerabilities in declared dependencies.

### Code Vulnerabilities (SAST)
Snyk Code: Not run (Dart/Flutter SAST not fully supported by Snyk CLI at this time).

### IaC Findings
Not applicable — no Dockerfile, docker-compose, or IaC files in this project.
