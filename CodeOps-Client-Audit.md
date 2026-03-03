# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-03-03T16:14:05Z
**Branch:** main
**Commit:** bbb93bdc7a5ebbd549c273b2de0fe3e02e50000e CCF-014: Registry integration — service discovery panel, auto-environment, OpenAPI import, URL autocomplete, health badges, test all endpoints, 34 tests
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml (generated separately)

> This audit is the source of truth for the CodeOps-Client codebase structure, models, services, and configuration.
> The OpenAPI spec (CodeOps-Client-OpenAPI.yaml) is the source of truth for all server endpoints and API contracts.
> An AI reading this audit + the OpenAPI spec should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:       CodeOps-Client
Repository URL:     https://github.com/AI-CodeOps/CodeOps-Client.git
Primary Language:   Dart / Flutter (Desktop — macOS)
Dart SDK:           >=3.6.0
Flutter SDK:        >=3.27.0 (runtime: 3.41.1)
Build Tool:         Flutter CLI + build_runner for code generation
Current Branch:     main
Latest Commit:      bbb93bdc7a5ebbd549c273b2de0fe3e02e50000e
Latest Message:     CCF-014: Registry integration — service discovery panel, auto-environment, OpenAPI import, URL autocomplete, health badges, test all endpoints, 34 tests
Audit Timestamp:    2026-03-03T16:14:05Z
```

---

## 2. Directory Structure

Single-module Flutter desktop application. Source lives under `lib/` with feature-based subdirectories. Tests mirror source structure under `test/`.

```
CodeOps-Client/
├── pubspec.yaml                          ← Build manifest (36 runtime + 8 dev deps)
├── analysis_options.yaml                 ← Lint rules (flutter_lints 5.0.0)
├── CodeOps-Client-OpenAPI.yaml           ← API spec (generated separately)
├── README.md
├── assets/
│   ├── personas/                         ← 16 built-in agent persona markdown files
│   └── templates/                        ← 5 report templates (audit, compliance, executive, RCA, task prompt)
├── integration_test/                     ← 5 integration test files
├── lib/                                  ← 622 source files
│   ├── main.dart                         ← Entry point
│   ├── app.dart                          ← Root ConsumerWidget
│   ├── router.dart                       ← GoRouter config (91 routes)
│   ├── database/                         ← Drift SQLite (2 files + generated)
│   │   ├── database.dart                 ← @DriftDatabase, schema v9, migrations
│   │   └── tables.dart                   ← 25 table definitions
│   ├── models/                           ← 64 model files (~465+ classes/enums)
│   ├── pages/                            ← 89 page files
│   │   ├── courier/  (7)                 ← HTTP client module
│   │   ├── datalens/ (5)                 ← Database browser module
│   │   ├── fleet/    (12)                ← Docker management module
│   │   ├── logger/   (13)                ← Log/metrics/trace module
│   │   ├── registry/ (15)                ← Service registry module
│   │   └── relay/    (1)                 ← Messaging module
│   ├── providers/                        ← 33 provider files (~500+ providers)
│   ├── services/                         ← 89 service files
│   │   ├── agent/     (4)                ← Agent config, persona, report parsing
│   │   ├── analysis/  (3)                ← Dependency, health, tech debt analysis
│   │   ├── auth/      (2)                ← AuthService + SecureStorage
│   │   ├── cloud/     (25)               ← Server API clients
│   │   ├── courier/   (9)                ← HTTP client engine, scripts, code gen
│   │   ├── data/      (4)                ← Scribe persistence, sync
│   │   ├── datalens/  (16)               ← DB drivers, query execution, ER diagrams
│   │   ├── integration/ (1)              ← Export service
│   │   ├── jira/      (2)               ← Jira integration
│   │   ├── logging/   (2)                ← Log level + LogService
│   │   ├── openapi_parser.dart (1)       ← OpenAPI spec parser
│   │   ├── orchestration/ (6)            ← Agent dispatch, job orchestration
│   │   ├── platform/  (2)               ← Claude Code CLI detection, process mgr
│   │   └── vcs/       (4)                ← Git/GitHub integration
│   ├── theme/                            ← 3 files (colors, typography, app_theme)
│   ├── utils/                            ← 6 utility files
│   └── widgets/                          ← 430 widget files (20+ subdirs)
├── test/                                 ← 580 unit test files
├── macos/                                ← macOS platform runner
└── coverage/                             ← lcov.info output
```

**File counts:** 622 lib source files, 580 unit test files, 5 integration test files.

---

## 3. Build & Dependency Manifest

**Path:** `pubspec.yaml`

### Runtime Dependencies (36)

| Dependency | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Riverpod codegen annotations |
| go_router | ^14.8.1 | Declarative routing |
| drift | ^2.22.1 | Local SQLite ORM (offline cache) |
| sqlite3_flutter_libs | ^0.5.28 | Native SQLite bindings |
| postgres | ^3.5.9 | DataLens: PostgreSQL direct driver |
| mysql_client | ^0.0.27 | DataLens: MySQL direct driver |
| sqlite3 | ^2.4.7 | DataLens: SQLite direct driver |
| mssql_connection | ^3.0.0 | DataLens: SQL Server direct driver |
| dio | ^5.7.0 | HTTP client |
| flutter_markdown | ^0.7.6 | Markdown rendering |
| flutter_highlight | ^0.7.0 | Syntax highlighting |
| re_editor | ^0.8.0 | Code editor widget (Scribe) |
| re_highlight | ^0.0.3 | re_editor syntax highlighting |
| fl_chart | ^0.70.2 | Charts (health, trends, metrics) |
| file_picker | ^8.1.7 | Native file dialogs |
| desktop_drop | ^0.5.0 | Drag-and-drop file support |
| window_manager | ^0.4.3 | Window size/position control |
| split_view | ^3.2.1 | Resizable split panes |
| diff_match_patch | ^0.4.1 | Text diff computation |
| path | ^1.9.0 | File path manipulation |
| path_provider | ^2.1.5 | App support directory |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.20.1 | Internationalization/date formatting |
| yaml | ^3.1.3 | YAML parsing |
| archive | ^4.0.2 | Archive extraction |
| url_launcher | ^6.3.1 | External URL opening |
| shared_preferences | ^2.3.4 | Simple key-value persistence |
| crypto | ^3.0.6 | Hash computation |
| package_info_plus | ^8.1.2 | App version info |
| connectivity_plus | ^6.1.1 | Network connectivity detection |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| freezed_annotation | ^2.4.4 | Immutable class annotations (present but NOT used — only @JsonSerializable used) |
| collection | ^1.19.0 | Extended collection utilities |
| equatable | ^2.0.7 | Value equality |
| pdf | ^3.11.2 | PDF generation |
| printing | ^5.13.4 | PDF printing/preview |

### Dev Dependencies (8)

| Dependency | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.22.1 | Drift code generator |
| riverpod_generator | ^2.6.4 | Riverpod code generator |
| json_serializable | ^6.9.0 | JSON serialization generator |
| freezed | ^2.5.7 | Immutable class generator (present but NOT used) |
| flutter_test | sdk | Test framework |
| mocktail | ^1.0.4 | Mock framework |
| flutter_lints | ^5.0.0 | Lint rules |

### Build Commands

```
Build:      flutter build macos
Test:       flutter test
Test+Cover: flutter test --coverage
Run:        flutter run -d macos
CodeGen:    dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Configuration & Infrastructure Summary

### Configuration Files

- **`pubspec.yaml`** — Build manifest, asset registration (`assets/personas/`, `assets/templates/`). Path: `./pubspec.yaml`
- **`analysis_options.yaml`** — Lint rules from flutter_lints 5.0.0. Path: `./analysis_options.yaml`
- **`lib/utils/constants.dart`** — 120+ static constants including `apiBaseUrl: 'http://localhost:8090'`, `apiPrefix: '/api/v1'`, `vaultBaseUrl: 'http://localhost:8097'`. Path: `./lib/utils/constants.dart`

### Connection Map

```
CodeOps-Server:    HTTP (Dio),    localhost:8090, /api/v1/
Vault Server:      HTTP (Dio),    localhost:8097, /api/v1/
Relay WebSocket:   WS,            localhost:8090, /ws/relay/
Anthropic API:     HTTP (Dio),    api.anthropic.com (model listing)
Jira Cloud:        HTTP (Dio),    <configured-jira-url>/rest/api/3/
GitHub API:        HTTP (Dio),    api.github.com
DataLens Direct:   TCP,           user-configured PostgreSQL/MySQL/SQLite/MSSQL connections
Local Database:    SQLite (Drift), <app-support-dir>/codeops.db
```

### CI/CD

None detected (no `.github/workflows`, no Jenkinsfile).

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart`

Startup sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogConfig.initialize()` — configures logging
3. `WindowManager` — sets window to 1440x900 (min 1024x700), hidden title bar, centered
4. `runApp(ProviderScope(child: CodeOpsApp()))` — launches Riverpod + root widget

**Root widget (`lib/app.dart`):**
- `CodeOpsApp` is a `ConsumerWidget`
- Bridges `authStateProvider` → GoRouter's `authNotifier` for reactive redirect
- On authentication: auto-selects team, seeds 13 built-in agents, refreshes Anthropic model cache

**No scheduled tasks or background jobs.** All server polling is user-initiated. WebSocket for Relay messaging uses exponential backoff reconnection.

---

## 6. Entity / Data Model Layer

This is a Flutter client — models are DTOs deserialized from server JSON responses and Drift SQLite tables for offline cache. There are no JPA entities.

### Drift SQLite Tables (25 tables, schema v9)

Path: `lib/database/tables.dart`, `lib/database/database.dart`

All tables use UUID text primary keys. Enum fields stored as text (SCREAMING_SNAKE_CASE). No explicit foreign key constraints or indexes (SQLite for local cache only).

| Table | Purpose | Key Fields |
|---|---|---|
| Users | User profile cache | id, email, displayName, avatarUrl, isActive, lastLoginAt |
| Teams | Team cache | id, name, description, ownerId, ownerName, teamsWebhookUrl, memberCount |
| Projects | Project cache | id, teamId, name, githubConnectionId, repoUrl, repoFullName, defaultBranch, jiraConnectionId, jiraProjectKey, techStack, healthScore, isArchived |
| QaJobs | QA job cache | id, projectId, mode, status, name, branch, configJson, summaryMd, overallResult, healthScore, totalFindings, criticalCount, highCount, mediumCount, lowCount, jiraTicketKey |
| AgentRuns | Agent run cache | id, jobId, agentType, status, result, reportS3Key, score, findingsCount |
| Findings | Finding cache | id, jobId, agentType, severity, title, description, filePath, lineNumber, recommendation, evidence, effortEstimate, debtCategory, findingStatus |
| RemediationTasks | Task cache | id, jobId, taskNumber, title, description, promptMd, priority, status, assignedTo, jiraKey |
| Personas | Persona cache | id, name, agentType, description, contentMd, scope, teamId, isDefault, version |
| Directives | Directive cache | id, name, description, contentMd, category, scope, teamId, projectId, version |
| TechDebtItems | Tech debt cache | id, projectId, category, title, description, filePath, effortEstimate, businessImpact, status |
| DependencyScans | Dep scan cache | id, projectId, jobId, manifestFile, totalDependencies, outdatedCount, vulnerableCount |
| DependencyVulnerabilities | Vuln cache | id, scanId, dependencyName, currentVersion, fixedVersion, cveId, severity, status |
| HealthSnapshots | Health history cache | id, projectId, jobId, healthScore, findingsBySeverity, techDebtScore, dependencyScore, testCoveragePercent |
| ComplianceItems | Compliance cache | id, jobId, requirement, specId, specName, status, evidence, agentType |
| Specifications | Spec cache | id, jobId, name, specType, s3Key |
| ClonedRepos | Local git repos | repoFullName (PK), localPath, projectId |
| SyncMetadata | Sync timestamps | syncTableName (PK), lastSyncAt, etag |
| AnthropicModels | Model metadata cache | id (PK), displayName, modelFamily, contextWindow, maxOutputTokens, fetchedAt |
| AgentDefinitions | Agent config | id, name, agentType, isQaManager, isBuiltIn, isEnabled, modelId, temperature, maxRetries, timeoutMinutes, maxTurns, systemPromptOverride, sortOrder |
| AgentFiles | Agent attachments | id, agentDefinitionId, fileName, fileType, contentMd, filePath, sortOrder |
| ProjectLocalConfig | Local project settings | projectId (PK), localWorkingDir |
| ScribeTabs | Editor tab state | id, title, filePath, content, language, isDirty, cursorLine, cursorColumn, scrollOffset, displayOrder |
| ScribeSettings | Editor settings KV | key (PK), value (JSON) |
| DatalensConnections | Saved DB connections | id, name, driver, host, port, database, schema, username, password, useSsl, sslMode, color, connectionTimeout, filePath |
| DatalensQueryHistory | Query history | id, connectionId, sql, status, rowCount, executionTimeMs, error |
| DatalensSavedQueries | Saved queries | id, connectionId, name, description, sql, folder |

**Migration history:** v1→v2 (ClonedRepos), v2→v3 (configJson on QaJobs), v3→v4 (summaryMd, startedByName on QaJobs; statusChangedBy/At on Findings), v4→v5 (AnthropicModels, AgentDefinitions, AgentFiles), v5→v6 (ProjectLocalConfig), v6→v7 (ScribeTabs, ScribeSettings), v7→v8 (DatalensConnections, DatalensQueryHistory, DatalensSavedQueries), v8→v9 (filePath on DatalensConnections).

---

## 7. Enum Inventory

All enums use SCREAMING_SNAKE_CASE values matching the Java server. Custom `JsonConverter` classes handle serialization.

### Core Enums (`lib/models/enums.dart`)

| Enum | Values | Used In |
|---|---|---|
| AgentType | API_CONTRACT, ARCHITECTURE, CHAOS_MONKEY, CODE_QUALITY, COMPLETENESS, COMPLIANCE_AUDITOR, DATABASE, DEPENDENCY, DOCUMENTATION, HOSTILE_USER, LOAD_SABOTEUR, PERFORMANCE, SECURITY, TEST_COVERAGE, UI_UX | AgentRun, Persona, Finding, AgentDefinition |
| AgentStatus | PENDING, INITIALIZING, RUNNING, COMPLETED, FAILED, CANCELLED | AgentRun |
| AgentResult | PASS, FAIL, ERROR, CANCELLED | AgentRun |
| JobMode | FULL_AUDIT, TARGETED_AUDIT, COMPLIANCE_CHECK, BUG_INVESTIGATION | QaJob |
| JobStatus | PENDING, INITIALIZING, RUNNING, AGGREGATING, COMPLETED, FAILED, CANCELLED | QaJob |
| OverallResult | PASS, CONDITIONAL_PASS, FAIL | QaJob |
| Severity | CRITICAL, HIGH, MEDIUM, LOW, INFO | Finding |
| FindingStatus | OPEN, ACKNOWLEDGED, FALSE_POSITIVE, RESOLVED, DEFERRED | Finding |
| TaskPriority | CRITICAL, HIGH, MEDIUM, LOW | RemediationTask |
| TaskStatus | PENDING, IN_PROGRESS, COMPLETED, CANCELLED | RemediationTask |
| EffortEstimate | TRIVIAL, SMALL, MEDIUM, LARGE, EPIC | Finding, TechDebtItem |
| PersonaScope | SYSTEM, TEAM, PROJECT | Persona |
| DirectiveCategory | CODING_STANDARDS, ARCHITECTURE, TESTING, SECURITY, DOCUMENTATION, PERFORMANCE, COMPLIANCE, OTHER | Directive |
| DirectiveScope | GLOBAL, TEAM, PROJECT | Directive |
| TeamMemberRole | OWNER, LEAD, MEMBER, VIEWER | Team member display |
| DebtCategory | CODE_SMELL, DESIGN_DEBT, TEST_DEBT, DOCUMENTATION_DEBT, DEPENDENCY_DEBT, INFRASTRUCTURE_DEBT | TechDebtItem |
| BusinessImpact | CRITICAL, HIGH, MODERATE, LOW | TechDebtItem |
| DebtStatus | OPEN, IN_PROGRESS, RESOLVED, ACCEPTED | TechDebtItem |
| VulnerabilityStatus | OPEN, PATCHED, IGNORED, IN_PROGRESS | DependencyVulnerability |
| ComplianceStatus | COMPLIANT, NON_COMPLIANT, PARTIAL, NOT_ASSESSED | ComplianceItem |
| SpecType | REGULATORY, INDUSTRY, INTERNAL, SECURITY | Specification |
| IntegrationStatus | ACTIVE, INACTIVE, ERROR | Integration display |

### Courier Enums (`lib/models/courier_enums.dart`)

| Enum | Values |
|---|---|
| HttpMethod | GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS |
| BodyType | NONE, FORM_DATA, X_WWW_FORM_URLENCODED, RAW_JSON, RAW_XML, RAW_HTML, RAW_TEXT, RAW_YAML, BINARY, GRAPHQL |
| AuthType | NO_AUTH, API_KEY, BEARER_TOKEN, BASIC_AUTH, OAUTH2_AUTHORIZATION_CODE, OAUTH2_CLIENT_CREDENTIALS, OAUTH2_IMPLICIT, OAUTH2_PASSWORD, JWT_BEARER, INHERIT_FROM_PARENT |
| ScriptType | PRE_REQUEST, POST_RESPONSE |

### DataLens Enums (`lib/models/datalens_enums.dart`)

| Enum | Values |
|---|---|
| DatabaseDriver | POSTGRESQL, MYSQL, SQLITE, SQL_SERVER |
| QueryStatus | SUCCESS, ERROR, CANCELLED |

### Fleet Enums (`lib/models/fleet_enums.dart`)

| Enum | Values (summary) |
|---|---|
| ContainerStatus | CREATED, RUNNING, PAUSED, RESTARTING, REMOVING, EXITED, DEAD |
| ContainerHealth | HEALTHY, UNHEALTHY, STARTING, NONE |
| RestartPolicy | NO, ALWAYS, UNLESS_STOPPED, ON_FAILURE |
| NetworkDriver | BRIDGE, HOST, OVERLAY, MACVLAN, NONE |
| VolumeDriver | LOCAL |
| ProfileStatus | DRAFT, ACTIVE, ARCHIVED |

### Logger Enums (`lib/models/logger_enums.dart`)

| Enum | Values (summary) |
|---|---|
| LogLevel | TRACE, DEBUG, INFO, WARN, ERROR, FATAL |
| SpanStatus | OK, ERROR |
| AlertSeverity | CRITICAL, WARNING, INFO |
| AlertState | ACTIVE, RESOLVED, ACKNOWLEDGED, SILENCED |
| DashboardWidgetType | LOG_COUNT, ERROR_RATE, LATENCY_PERCENTILE, CUSTOM_METRIC, SERVICE_MAP, LOG_STREAM |
| MetricType | COUNTER, GAUGE, HISTOGRAM, SUMMARY |
| AggregationFunction | COUNT, SUM, AVG, MIN, MAX, P50, P90, P95, P99 |
| TrapAction | ALERT, TAG, SAMPLE, DROP |
| ChannelType | EMAIL, SLACK, WEBHOOK, PAGERDUTY, TEAMS |

### MCP Enums (`lib/models/mcp_enums.dart`)

| Enum | Values |
|---|---|
| McpServerStatus | ACTIVE, INACTIVE, ERROR |
| McpToolType | RESOURCE, TOOL, PROMPT |
| McpTransportType | STDIO, SSE |

### Registry Enums (`lib/models/registry_enums.dart`)

| Enum | Values (summary) |
|---|---|
| ServiceType | API, WEB, WORKER, DATABASE, CACHE, MESSAGE_BROKER, GATEWAY, SCHEDULER, MONITORING, OTHER |
| ServiceStatus | ACTIVE, DEPRECATED, PLANNED, DECOMMISSIONED |
| DependencyType | RUNTIME, BUILD, OPTIONAL |
| HealthStatus | HEALTHY, DEGRADED, UNHEALTHY, UNKNOWN |
| InfraResourceType | DATABASE, CACHE, MESSAGE_BROKER, STORAGE, CDN, DNS, LOAD_BALANCER, MONITORING, OTHER |

### Relay Enums (`lib/models/relay_enums.dart`)

| Enum | Values (summary) |
|---|---|
| ChannelType | PUBLIC, PRIVATE, ANNOUNCEMENTS |
| MessageType | TEXT, FILE, SYSTEM, THREAD_REPLY |
| UserPresence | ONLINE, AWAY, DO_NOT_DISTURB, OFFLINE |
| DeliveryStatus | SENT, DELIVERED, READ |
| EventType | MESSAGE_SENT, REACTION_ADDED, USER_JOINED, CHANNEL_CREATED, etc. |

### Vault Enums (`lib/models/vault_enums.dart`)

| Enum | Values (summary) |
|---|---|
| SecretType | KV, DATABASE, API_KEY, CERTIFICATE, SSH_KEY, TOKEN |
| SecretStatus | ACTIVE, EXPIRED, REVOKED, ROTATING |
| RotationStrategy | TIME_BASED, EVENT_BASED, MANUAL |
| SealStatus | SEALED, UNSEALED, STANDBY |
| TransitKeyType | AES256_GCM, CHACHA20_POLY1305, RSA_2048, RSA_4096 |
| AuditOperation | READ, WRITE, DELETE, LIST, LOGIN, SEAL, UNSEAL, ROTATE, etc. |
| PolicyEffect | ALLOW, DENY |

---

## 8. Repository Layer

No traditional repository layer. Data access has two paths:

1. **Drift DAO (local SQLite)** — `CodeOpsDatabase` (singleton at `lib/database/database.dart`) provides typed queries on 25 tables. `clearAllTables()` for logout. No custom DAOs — services use Drift's generated accessors directly.

2. **Cloud API services** — 25 service classes under `lib/services/cloud/` that perform HTTP calls via `ApiClient`/`RegistryApiClient`/`VaultApiClient`. These serve as the "remote repository" layer.

---

## 9. Service Layer — Full Method Signatures

### API Client Architecture

Three HTTP client classes, all based on Dio with the same interceptor pattern:

```
=== ApiClient (lib/services/cloud/api_client.dart) ===
Base URL: http://localhost:8090/api/v1/
Interceptors: auth (Bearer token), refresh (401 → retry once), error (→ ApiException), logging
Public Paths: /auth/login, /auth/register, /auth/refresh, /health
Timeouts: connect 15s, receive 30s, send 15s
Methods: get<T>, post<T>, put<T>, patch<T>, delete<T>, download
Exposes: dio getter for advanced usage (custom headers like X-Team-Id)

=== RegistryApiClient (lib/services/cloud/registry_api_client.dart) ===
Base URL: http://localhost:8090/api/v1/
Same interceptor pattern as ApiClient. Dedicated to Registry module.

=== VaultApiClient (lib/services/cloud/vault_api_client.dart) ===
Base URL: http://localhost:8097/api/v1/
Same interceptor pattern. Dedicated to Vault module (separate server).
```

### Auth Service (`lib/services/auth/`)

```
=== AuthService ===
Injects: ApiClient, SecureStorageService, CodeOpsDatabase
State: AuthState enum (unknown, authenticated, unauthenticated) via StreamController.broadcast
Methods:
  - login(String email, String password): Future<User>
  - register(String email, String password, String displayName): Future<User>
  - refreshToken(): Future<void>
  - logout(): Future<void> — clears tokens, clears DB, emits unauthenticated
  - checkAuthState(): Future<void> — validates stored tokens on startup
  - getCurrentUser(): Future<User?>
  - getHealth(): Future<HealthResponse>

=== SecureStorageService ===
Injects: FlutterSecureStorage
Methods:
  - getAccessToken / setAccessToken / deleteAccessToken
  - getRefreshToken / setRefreshToken / deleteRefreshToken
  - getUserId / setUserId / deleteUserId
  - getSelectedTeamId / setSelectedTeamId / deleteSelectedTeamId
  - clearAll()
```

### Cloud API Services (`lib/services/cloud/`)

25 API service classes. Each takes an API client constructor param. Key services by endpoint count:

| Service | File | Endpoints | Server |
|---|---|---|---|
| LoggerApi | logger_api.dart | ~104 | 8090 |
| CourierApiService | courier_api.dart | ~79 | 8090 |
| RegistryApi | registry_api.dart | ~77 | 8090 |
| VaultApi | vault_api.dart | ~67 | 8097 |
| RelayApiService | relay_api.dart | ~59 | 8090 |
| FleetApiService | fleet_api.dart | ~53 | 8090 |
| McpApi | mcp_api.dart | ~30 | 8090 |
| FindingApi | finding_api.dart | ~12 | 8090 |
| JobApi | job_api.dart | ~10 | 8090 |
| ProjectApi | project_api.dart | ~8 | 8090 |
| PersonaApi | persona_api.dart | ~8 | 8090 |
| DirectiveApi | directive_api.dart | ~7 | 8090 |
| TeamApi | team_api.dart | ~6 | 8090 |
| UserApi | user_api.dart | ~5 | 8090 |
| TechDebtApi | tech_debt_api.dart | ~5 | 8090 |
| HealthMonitorApi | health_monitor_api.dart | ~5 | 8090 |
| DependencyApi | dependency_api.dart | ~5 | 8090 |
| ComplianceApi | compliance_api.dart | ~5 | 8090 |
| AdminApi | admin_api.dart | ~5 | 8090 |
| ReportApi | report_api.dart | ~4 | 8090 |
| TaskApi | task_api.dart | ~4 | 8090 |
| MetricsApi | metrics_api.dart | ~3 | 8090 |
| IntegrationApi | integration_api.dart | ~3 | 8090 |
| AnthropicApiService | anthropic_api_service.dart | ~2 | api.anthropic.com |
| RelayWebSocketService | relay_websocket_service.dart | WebSocket | 8090 |

### Courier Services (`lib/services/courier/`)

```
=== ScriptEngine (script_engine.dart) ===
Purpose: Custom JS-like DSL interpreter for pre-request/post-response scripts
Injects: none (standalone)
Supports: variable assignment, console.log, assertions, JSON operations,
          environment variable get/set, header manipulation

=== HttpExecutionService (http_execution_service.dart) ===
Purpose: Executes Courier HTTP requests with variable resolution
Injects: VariableResolutionService

=== CollectionRunnerService (collection_runner_service.dart) ===
Purpose: Batch-runs collections of requests sequentially

=== CurlParserService (curl_parser_service.dart) ===
Purpose: Parses curl commands into Courier request models

=== OpenApiImportService (openapi_import_service.dart) ===
Purpose: Imports OpenAPI YAML/JSON specs into Courier collections

=== CodeGenerationService (code_generation_service.dart) ===
Purpose: Generates code snippets from Courier requests (curl, Python, JS, Dart)

=== VariableResolutionService (variable_resolution_service.dart) ===
Purpose: Resolves {{variable}} placeholders from environments/globals

=== DataFileParserService (data_file_parser.dart) ===
Purpose: Parses CSV/JSON data files for collection runner iterations

=== RegistryEnvironmentService (registry_environment_service.dart) ===
Purpose: Auto-generates Courier environments from Registry service entries
```

### DataLens Services (`lib/services/datalens/`)

```
=== DatabaseConnectionService (database_connection_service.dart) ===
Purpose: Manages live database connections via driver factory
Injects: DriverFactory
Methods: connect, disconnect, testConnection, getActiveConnection

=== DriverFactory + Drivers (drivers/) ===
Purpose: Abstract DatabaseDriver with implementations for PostgreSQL, MySQL, SQLite, SQL Server
Interface: execute(sql), getSchemas, getTables, getColumns, getIndexes, getForeignKeys, getTableRowCount

=== QueryExecutionService (query_execution_service.dart) ===
Purpose: Executes SQL queries against live connections, tracks timing

=== SchemaIntrospectionService (schema_introspection_service.dart) ===
Purpose: Reads database schema metadata (tables, columns, constraints, indexes)

=== ErDiagramService (er_diagram_service.dart) ===
Purpose: Builds ER diagram graph models from introspected schema

=== ErExportService (er_export_service.dart) ===
Purpose: Exports ER diagrams to PNG/SVG/SQL DDL

=== DataEditorService (data_editor_service.dart) ===
Purpose: In-place cell editing with pending changes buffer and commit/rollback

=== SqlAutocompleteService (sql_autocomplete_service.dart) ===
Purpose: SQL keyword and schema-aware autocomplete

=== DatalensSearchService (datalens_search_service.dart) ===
Purpose: Cross-table text search within connected databases

=== DbAdminService (db_admin_service.dart) ===
Purpose: Admin operations (active sessions, locks, table stats, index usage)

=== QueryHistoryService (query_history_service.dart) ===
Purpose: Persists query history to local Drift table

=== Import Services (import/) ===
  - CsvImportService: CSV file → SQL INSERT generation
  - SqlScriptImportService: SQL script execution
  - TableTransferService: Table data transfer between connections
```

### Orchestration Services (`lib/services/orchestration/`)

```
=== JobOrchestrator (job_orchestrator.dart) ===
Purpose: Orchestrates QA job lifecycle — dispatches agents, monitors progress, aggregates results
Injects: ApiClient, AgentDispatcher, AgentMonitor, ProgressAggregator, ProcessManager,
         PersonaManager, VeraManager, AgentConfigService, TaskGenerator, CodeOpsDatabase

=== AgentDispatcher (agent_dispatcher.dart) ===
Purpose: Spawns Claude Code CLI as OS subprocesses via dart:io Process
Injects: ProcessManager
Spawns: `claude --dangerously-skip-permissions` with persona + directive content as prompt

=== AgentMonitor (agent_monitor.dart) ===
Purpose: Monitors spawned agent process stdout/stderr, parses progress

=== ProgressAggregator (progress_aggregator.dart) ===
Purpose: Aggregates multi-agent progress into overall job progress

=== VeraManager (vera_manager.dart) ===
Purpose: Manages the QA manager (Vera) agent — a meta-agent that reviews other agents' reports

=== BugInvestigationOrchestrator (bug_investigation_orchestrator.dart) ===
Purpose: Specialized orchestrator for bug investigation jobs
```

### VCS Services (`lib/services/vcs/`)

```
=== GitService (git_service.dart) ===
Purpose: Local git operations via dart:io Process (clone, pull, branch, status, log, diff, stash)

=== GithubProvider (github_provider.dart) ===
Purpose: GitHub API integration (repos, PRs, issues, commits, CI status)

=== RepoManager (repo_manager.dart) ===
Purpose: Manages cloned repos in Drift table, auto-cleanup

=== VcsProvider (vcs_provider.dart) ===
Purpose: Abstract VCS interface (only GitHub implementation exists)
```

### Other Services

```
=== SyncService (lib/services/data/sync_service.dart) ===
Purpose: Syncs server data to local Drift cache with ETag-based conditional requests

=== ScribeFileService (lib/services/data/scribe_file_service.dart) ===
Purpose: File I/O for the Scribe code editor (read, write, watch for changes)

=== ScribePersistenceService (lib/services/data/scribe_persistence_service.dart) ===
Purpose: Persists Scribe editor tabs/settings to Drift tables for session restore

=== ScribeDiffService (lib/services/data/scribe_diff_service.dart) ===
Purpose: Computes text diffs using diff_match_patch for side-by-side/inline diff views

=== ExportService (lib/services/integration/export_service.dart) ===
Purpose: Exports reports to PDF using the pdf/printing packages

=== JiraService (lib/services/jira/jira_service.dart) ===
Purpose: Jira REST API integration (search, create, update issues)

=== JiraMapper (lib/services/jira/jira_mapper.dart) ===
Purpose: Maps between CodeOps findings/tasks and Jira issue fields

=== OpenApiParser (lib/services/openapi_parser.dart) ===
Purpose: Parses OpenAPI YAML specs into in-memory models for API docs browsing

=== DependencyScanner (lib/services/analysis/dependency_scanner.dart) ===
Purpose: Analyzes dependency scan results for CVE alerts and update recommendations

=== HealthCalculator (lib/services/analysis/health_calculator.dart) ===
Purpose: Computes project health scores from findings, tech debt, coverage

=== TechDebtTracker (lib/services/analysis/tech_debt_tracker.dart) ===
Purpose: Tracks tech debt items across audits, computes trends

=== ClaudeCodeDetector (lib/services/platform/claude_code_detector.dart) ===
Purpose: Detects Claude Code CLI installation on the local machine

=== ProcessManager (lib/services/platform/process_manager.dart) ===
Purpose: Spawns and manages OS subprocesses with stdout/stderr capture

=== LogService (lib/services/logging/log_service.dart) ===
Purpose: Centralized logging with level filtering. Global `log` accessor.

=== AgentConfigService (lib/services/agent/agent_config_service.dart) ===
Purpose: Manages agent definitions in Drift — seed built-in agents, CRUD, model cache

=== PersonaManager (lib/services/agent/persona_manager.dart) ===
Purpose: Resolves persona content for agent dispatch (built-in assets + DB personas)

=== ReportParser (lib/services/agent/report_parser.dart) ===
Purpose: Parses agent stdout into structured report sections

=== TaskGenerator (lib/services/agent/task_generator.dart) ===
Purpose: Generates remediation tasks from agent findings
```

---

## 10. Controller / API Layer

Not applicable — this is a Flutter desktop client, not a server. The equivalent of "controllers" are **pages** (routed screens) backed by **providers** (Riverpod state).

### Router (`lib/router.dart`)

91 routes total. 2 routes outside shell (login, setup/placeholder), 89 inside `NavigationShell`. Auth redirect: unauthenticated → `/login`. All shell routes use `NoTransitionPage`.

Key route paths:
- `/` → HomePage (dashboard)
- `/login` → LoginPage
- `/projects` → ProjectsPage
- `/projects/:id` → ProjectDetailPage
- `/jobs/history` → JobHistoryPage
- `/jobs/:id/progress` → JobProgressPage
- `/jobs/:id/report` → JobReportPage
- `/health` → HealthDashboardPage
- `/findings` → FindingsExplorerPage
- `/tasks/:jobId` → TaskListPage
- `/task-manager` → TaskManagerPage
- `/personas` → PersonasPage
- `/directives` → DirectivesPage
- `/tech-debt` → TechDebtPage
- `/dependencies` → DependencyScanPage
- `/audit-wizard` → AuditWizardPage
- `/compliance-wizard` → ComplianceWizardPage
- `/bug-investigator` → BugInvestigatorPage
- `/scribe` → ScribePage
- `/datalens` → DatalensPage
- `/courier` → CourierPage + 6 sub-routes
- `/fleet` → FleetDashboardPage + 11 sub-routes
- `/logger` → LoggerDashboardPage + 12 sub-routes
- `/registry` → RegistryDashboardPage + 14 sub-routes
- `/vault` → VaultDashboardPage + 9 sub-routes
- `/relay` → RelayPage
- `/github` → GithubBrowserPage
- `/jira` → JiraBrowserPage
- `/settings` → SettingsPage
- `/admin` → AdminHubPage

---

## 11. Security Configuration

```
Authentication: JWT Bearer token (issued by CodeOps-Server)
Token storage: flutter_secure_storage (macOS Keychain)
Token lifecycle: Access + Refresh tokens. 401 → auto-refresh → retry once → logout on failure.

Public endpoints (no auth):
  - /auth/login
  - /auth/register
  - /auth/refresh
  - /health

Protected endpoints: All other /api/v1/** paths require Bearer token.

CORS: N/A (desktop client, not web)
CSRF: N/A (desktop client)
Rate limiting: N/A (client-side)
```

---

## 12. Custom Security Components

```
=== AuthService (lib/services/auth/auth_service.dart) ===
Purpose: Full auth lifecycle management
Token extraction: From login/register API response JSON
Stores: access_token, refresh_token, user_id in SecureStorageService
Sets: ApiClient.onAuthFailure callback for automatic logout on refresh failure

=== SecureStorageService (lib/services/auth/secure_storage.dart) ===
Wraps: flutter_secure_storage (macOS Keychain backend)
Stores: access_token, refresh_token, user_id, selected_team_id

=== ApiClient auth interceptor ===
Attaches: Authorization: Bearer <token> to all non-public requests
Refresh: On 401, attempts refresh once, retries original request, logs out on failure
```

---

## 13. Exception Handling & Error Responses

```
=== ApiException hierarchy (lib/services/cloud/api_exceptions.dart) ===
Base: ApiException (message, statusCode)
Subtypes:
  - UnauthorizedException (401)
  - ForbiddenException (403)
  - NotFoundException (404)
  - ConflictException (409)
  - ValidationException (422, with field errors map)
  - ServerException (500+)
  - NetworkException (connection failures)
  - TimeoutException (request timeouts)

Error interceptor in ApiClient maps DioException → typed ApiException.
Providers catch ApiExceptions and expose them via AsyncValue.error.
Pages display errors via ErrorPanel widget or SnackBar notifications.
```

---

## 14. Mappers / DTOs

No MapStruct or similar framework. All JSON ↔ Dart mapping uses three patterns:

1. **@JsonSerializable + `.g.dart` code generation** — Used by most server-synchronized models (User, Team, Project, QaJob, Finding, etc.). Factory `fromJson` + `toJson` method.

2. **Manual `factory fromJson(Map<String, dynamic>)` + `Map<String, dynamic> toJson()`** — Used by VCS models, Scribe models, Anthropic models, and some complex nested types.

3. **Plain Dart classes (no serialization)** — Used by OpenAPI spec models, DataLens ER/admin/search models, AgentProgress (parsed from process stdout).

**Enum serialization:** Custom `JsonConverter<EnumType, String>` classes for each enum with `fromJson`/`toJson` using SCREAMING_SNAKE_CASE string values.

---

## 15. State Management — Providers

Riverpod is the exclusive state management solution. 33 provider files, ~500+ providers.

### Provider Patterns Used

| Pattern | Usage |
|---|---|
| `Provider` | Singleton service instances (ApiClient, AuthService, database) |
| `StateProvider` | Simple UI state (selected IDs, filters, toggle flags) |
| `FutureProvider` | Async data fetching (lists, details) |
| `FutureProvider.family` | Parameterized async fetching (by ID) |
| `StateNotifierProvider` | Complex state with mutations (Courier collections, DataLens connections) |
| `StreamProvider` | Reactive streams (auth state, WebSocket messages) |

### Key Provider Files

| File | Purpose | Key Providers |
|---|---|---|
| auth_providers.dart | Auth state + services | authServiceProvider, authStateProvider, secureStorageProvider, currentUserProvider |
| project_providers.dart | Project data | projectsProvider, selectedProjectIdProvider, selectedProjectProvider |
| team_providers.dart | Team data | teamsProvider, selectedTeamIdProvider, teamMembersProvider |
| job_providers.dart | Job lifecycle | jobsProvider, jobDetailProvider, activeJobProvider |
| agent_providers.dart | Agent runs | agentRunsProvider, agentReportProvider |
| agent_config_providers.dart | Agent definitions | agentDefinitionsProvider, agentConfigServiceProvider, anthropicModelsProvider |
| finding_providers.dart | Findings | findingsProvider, findingStatsProvider |
| task_providers.dart | Remediation tasks | tasksProvider, tasksByJobProvider |
| persona_providers.dart | Personas | personasProvider, personaDetailProvider |
| directive_providers.dart | Directives | directivesProvider, directiveDetailProvider |
| health_providers.dart | Health snapshots | healthSnapshotsProvider, latestHealthProvider |
| tech_debt_providers.dart | Tech debt | techDebtItemsProvider, techDebtStatsProvider |
| dependency_providers.dart | Dep scans | dependencyScansProvider, vulnerabilitiesProvider |
| compliance_providers.dart | Compliance | complianceItemsProvider, specificationProvider |
| courier_providers.dart | Courier state | collectionsProvider, activeRequestProvider, environmentsProvider |
| courier_ui_providers.dart | Courier UI state | selectedTabProvider, responseProvider |
| datalens_providers.dart | DataLens state | connectionsProvider, activeConnectionProvider, queryResultsProvider |
| fleet_providers.dart | Fleet/Docker | containersProvider, imagesProvider, networksProvider, volumesProvider |
| logger_providers.dart | Logger module | logEntriesProvider, metricsProvider, tracesProvider, dashboardsProvider |
| registry_providers.dart | Registry module | servicesProvider, solutionsProvider, dependencyGraphProvider |
| relay_providers.dart | Relay/messaging | channelsProvider, messagesProvider, presenceProvider |
| vault_providers.dart | Vault module | secretsProvider, policiesProvider, sealStatusProvider |
| github_providers.dart | GitHub integration | githubReposProvider, pullRequestsProvider |
| jira_providers.dart | Jira integration | jiraIssuesProvider, jiraProjectsProvider |
| scribe_providers.dart | Code editor | scribeTabsProvider, editorContentProvider |
| settings_providers.dart | App settings | themeProvider, apiKeyProvider |
| mcp_providers.dart | MCP servers | mcpServersProvider, mcpToolsProvider |
| wizard_providers.dart | Audit/compliance wizard state |
| report_providers.dart | Job report data |
| admin_providers.dart | Admin hub data |
| user_providers.dart | User management |
| project_local_config_providers.dart | Local project paths |
| agent_progress_notifier.dart | Real-time agent progress via StateNotifier |

---

## 16. Database Schema — Live State

**Local database:** SQLite via Drift, file at `<app-support-dir>/codeops.db`, schema version 9. 25 tables (documented in Section 6).

**No server-side database** — this is a client application. Server database is in CodeOps-Server.

**DataLens direct connections:** User-configured external PostgreSQL, MySQL, SQLite, SQL Server databases accessed via raw drivers (not Drift). Connection credentials stored in `DatalensConnections` table locally.

---

## 17. Message Broker Detection

**Relay WebSocket:** `RelayWebSocketService` connects to `ws://localhost:8090/ws/relay/` for real-time messaging. Uses `web_socket_channel` with exponential backoff reconnection (1s → 2s → 4s → ... → 30s max).

No client-side message broker (Kafka/RabbitMQ). Server-side Kafka is consumed by CodeOps-Server, not directly by the client.

---

## 18. Cache Detection

**Local SQLite cache (Drift):** All 25 tables serve as an offline cache of server data. `SyncMetadata` table tracks per-table sync timestamps with ETag support for conditional requests.

**No Redis or in-memory cache.** Riverpod's built-in caching (FutureProvider auto-dispose) handles transient caching of API responses.

---

## 19. Environment Variable Inventory

No environment variables. All configuration is hardcoded in `lib/utils/constants.dart`:

```
apiBaseUrl:     http://localhost:8090
apiPrefix:      /api/v1/
vaultBaseUrl:   http://localhost:8097
wsBaseUrl:      ws://localhost:8090
```

**Note:** These values are compile-time constants. Environment-based configuration would require a `.env` file or runtime config mechanism (not implemented).

---

## 20. Service Dependency Map

```
CodeOps-Client (Flutter Desktop)
  ├── → CodeOps-Server (HTTP REST)         localhost:8090
  │     ├── Auth (/auth/**)
  │     ├── Core (/projects, /jobs, /findings, /tasks, /personas, /directives, etc.)
  │     ├── Courier (/courier/**)
  │     ├── Fleet (/fleet/**)
  │     ├── Logger (/logger/**)
  │     ├── Registry (/registry/**)
  │     ├── Relay (/relay/** + WebSocket)
  │     ├── MCP (/mcp/**)
  │     └── Admin (/admin/**)
  ├── → Vault Server (HTTP REST)            localhost:8097
  │     └── Vault (/vault/**)
  ├── → GitHub API (HTTP REST)              api.github.com
  ├── → Anthropic API (HTTP REST)           api.anthropic.com
  ├── → Jira Cloud (HTTP REST)              <user-configured>
  ├── → Claude Code CLI (OS subprocess)     local binary
  └── → Direct DB connections (TCP)         user-configured (DataLens)
```

---

## 21. Known Technical Debt & Issues

### BLOCKING ISSUES

| ID | Severity | Issue | Details |
|---|---|---|---|
| TD-01 | CRITICAL | Test coverage at 56.8% | 49,933/87,947 lines covered. Requires 100%. |
| TD-02 | CRITICAL | Class doc coverage at 69.1% | 1,615/2,337 classes documented. 722 undocumented. Requires 100%. |
| TD-03 | CRITICAL | Method doc coverage at 38.4% | 1,503/3,911 public methods documented. 2,408 undocumented. Requires 100%. |

### NON-BLOCKING OBSERVATIONS

| ID | Severity | Issue | Details |
|---|---|---|---|
| TD-04 | LOW | Hardcoded server URLs | `constants.dart` has localhost URLs. No env-based configuration mechanism. |
| TD-05 | LOW | Unused freezed dependency | `freezed` and `freezed_annotation` in pubspec but all models use `@JsonSerializable` only. |
| TD-06 | LOW | No CI/CD pipeline | No `.github/workflows` or equivalent detected. |
| TD-07 | LOW | DataLens stores DB passwords in plaintext | `DatalensConnections.password` stored as plain text in local SQLite (not in Keychain). |

---

## 22. Security Vulnerability Scan (Snyk)

**Scan Date:** 2026-03-03
**Snyk CLI Version:** installed and authenticated

### Dependency Vulnerabilities (Open Source)
**PASS** — No known vulnerabilities in dependencies.

Critical: 0
High: 0
Medium: 0
Low: 0

### Code Vulnerabilities (SAST)
**PASS** — No code vulnerabilities detected.

Errors (high severity): 0
Warnings (medium): 0
Notes (low): 0

### IaC Findings
N/A — No Dockerfile or docker-compose.yml in client project.
