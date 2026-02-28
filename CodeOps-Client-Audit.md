# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-02-28T19:50:18Z
**Branch:** main
**Commit:** 5ce2214b61e8937db039094fde3a0fe4e013c369 FTF-007: Images, volumes, networks — Docker resource management, pull, create, prune, connect, 38 tests
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml (generated separately)

> This audit is the source of truth for the CodeOps-Client codebase structure, models, services, and configuration.
> The OpenAPI spec (CodeOps-Client-OpenAPI.yaml) is the source of truth for all endpoints, DTOs, and API contracts.
> An AI reading this audit + the OpenAPI spec should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name: CodeOps-Client
Repository URL: https://github.com/AI-CodeOps/CodeOps-Client.git
Primary Language / Framework: Dart / Flutter
Dart SDK Version: ^3.6.0
Flutter Version: >=3.27.0
Build Tool: Flutter CLI + pub
Current Branch: main
Latest Commit Hash: 5ce2214b61e8937db039094fde3a0fe4e013c369
Latest Commit Message: FTF-007: Images, volumes, networks — Docker resource management, pull, create, prune, connect, 38 tests
Audit Timestamp: 2026-02-28T19:50:18Z
```

---

## 2. Directory Structure

```
CodeOps-Client/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── app.dart                     ← Root widget (MaterialApp.router)
│   ├── router.dart                  ← GoRouter with 64 routes
│   ├── database/                    ← Drift local SQLite cache (2 files)
│   ├── models/                      ← Domain models + enums (33 files)
│   ├── pages/                       ← Page-level widgets (64 files)
│   │   ├── fleet/                   ← Docker Fleet pages (12 files)
│   │   ├── registry/                ← Service Registry pages (15 files)
│   │   └── relay/                   ← Team messaging page
│   ├── providers/                   ← Riverpod state management (30 files)
│   ├── services/                    ← Business logic + API clients (60 files)
│   │   ├── agent/                   ← Agent config, personas, report parsing
│   │   ├── analysis/                ← Health calc, dependency scan, tech debt
│   │   ├── auth/                    ← Auth service + secure storage
│   │   ├── cloud/                   ← REST API clients (28 files)
│   │   ├── data/                    ← Scribe persistence, sync, diff
│   │   ├── integration/             ← Export service
│   │   ├── jira/                    ← Jira integration
│   │   ├── logging/                 ← Centralized logging
│   │   ├── orchestration/           ← Job orchestrator, agent dispatch
│   │   ├── platform/                ← Claude Code detection, process mgmt
│   │   └── vcs/                     ← Git CLI, GitHub API, repo manager
│   ├── theme/                       ← Dark theme, colors, typography (3 files)
│   ├── utils/                       ← Constants, date/file/string utils (6 files)
│   └── widgets/                     ← Reusable UI components (316 files)
│       ├── admin/                   ← Admin hub tabs
│       ├── compliance/              ← Compliance wizard panels
│       ├── dashboard/               ← Home dashboard widgets
│       ├── dependency/              ← Dependency scan widgets
│       ├── findings/                ← Finding browser widgets
│       ├── fleet/                   ← Fleet container/profile widgets
│       ├── health/                  ← Health dashboard widgets
│       ├── jira/                    ← Jira browser widgets
│       ├── personas/                ← Persona editor widgets
│       ├── progress/                ← Job progress widgets
│       ├── registry/                ← Service registry widgets
│       ├── relay/                   ← Real-time messaging widgets
│       ├── reports/                 ← Report/chart widgets
│       ├── scribe/                  ← Code editor widgets
│       ├── settings/                ← Settings panel widgets
│       ├── shared/                  ← Empty state, error, loading, toast
│       ├── shell/                   ← Navigation shell
│       ├── tasks/                   ← Task management widgets
│       ├── tech_debt/               ← Tech debt widgets
│       ├── vault/                   ← Secret management widgets
│       ├── vcs/                     ← Version control widgets
│       └── wizard/                  ← Audit/compliance wizard steps
├── test/                            ← Unit + widget tests (405 files)
├── integration_test/                ← Integration tests (5 files)
├── assets/
│   ├── personas/                    ← Built-in agent persona markdown files
│   └── templates/                   ← Report/audit templates
├── pubspec.yaml
├── analysis_options.yaml
└── macos/                           ← macOS runner
```

**Summary:** Single-module Flutter desktop application (macOS primary target). 459 source files in lib/, 405 test files, 5 integration tests. Uses Riverpod for state management, GoRouter for navigation, Dio for HTTP, Drift for local SQLite caching.

---

## 3. Build & Dependency Manifest

**File:** `pubspec.yaml`

### Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Riverpod code generation annotations |
| go_router | ^14.8.1 | Declarative navigation/routing |
| drift | ^2.22.1 | Local SQLite database (cache) |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native bindings |
| dio | ^5.7.0 | HTTP client |
| flutter_markdown | ^0.7.6 | Markdown rendering |
| flutter_highlight | ^0.7.0 | Syntax highlighting |
| re_editor | ^0.8.0 | Code editor widget |
| re_highlight | ^0.0.3 | Editor syntax highlighting |
| fl_chart | ^0.70.2 | Charts and gauges |
| file_picker | ^8.1.7 | Native file dialogs |
| desktop_drop | ^0.5.0 | Drag-and-drop file support |
| window_manager | ^0.4.3 | Native window control |
| split_view | ^3.2.1 | Resizable split panes |
| diff_match_patch | ^0.4.1 | Text diff computation |
| path | ^1.9.0 | Path manipulation |
| path_provider | ^2.1.5 | Platform-specific directories |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.20.1 | Date/number formatting |
| yaml | ^3.1.3 | YAML parsing |
| archive | ^4.0.2 | ZIP archive support |
| url_launcher | ^6.3.1 | Open URLs in browser |
| shared_preferences | ^2.3.4 | Key-value storage (auth tokens) |
| crypto | ^3.0.6 | Hashing utilities |
| package_info_plus | ^8.1.2 | App version info |
| connectivity_plus | ^6.1.1 | Network connectivity detection |
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
| json_serializable | ^6.9.0 | JSON serialization code gen |
| freezed | ^2.5.7 | Immutable model code gen |
| flutter_test | SDK | Widget testing framework |
| mocktail | ^1.0.4 | Mocking library |
| integration_test | SDK | Integration testing |
| flutter_lints | ^5.0.0 | Lint rules |

### Build Commands

```
Build: flutter build macos
Test: flutter test
Run: flutter run -d macos
Code Gen: dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Configuration & Infrastructure Summary

**No configuration files** (application.yml, etc.) — this is a Flutter desktop app. All configuration is in code:

- **`lib/utils/constants.dart`** — Centralized constants (AppConstants class). Key values:
  - Server URL: `http://localhost:8090` (apiBaseUrl)
  - API prefix: `/api/v1`
  - Vault URL: `http://localhost:8097`
  - Vault prefix: `/api/v1/vault`
  - WebSocket URL: `ws://localhost:8090/ws/relay`
  - JWT expiry: 24h access, 30d refresh
  - Anthropic API: `https://api.anthropic.com` (version `2023-06-01`)
  - Default Claude model: `claude-sonnet-4-20250514`
  - All storage keys for SharedPreferences defined as constants

- **`analysis_options.yaml`** — Uses `package:flutter_lints/flutter.yaml` base rules. No custom rules enabled.

**Connection map:**
```
Database: SQLite (local, Drift ORM — cache only)
Cache: None (no Redis)
Message Broker: WebSocket (ws://localhost:8090/ws/relay — Relay messaging)
External APIs:
  - CodeOps-Server: http://localhost:8090/api/v1/
  - CodeOps-Vault: http://localhost:8097/api/v1/vault/
  - GitHub REST API: https://api.github.com (v3)
  - Anthropic API: https://api.anthropic.com
Cloud Services: None (S3 is server-side)
```

**CI/CD:** None detected.

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart` → `main()` function

**Startup sequence:**
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogConfig.initialize()` — sets log level (debug in dev, info in release), configures file logging
3. `windowManager.ensureInitialized()` — native window setup
4. Window options: 1440x900, minimum 1024x700, centered, title "CodeOps", hidden title bar
5. `runApp(ProviderScope(child: CodeOpsApp()))` — Riverpod scope wraps root

**On authentication (post-login):**
1. `_initTeamSelection()` — loads teams, auto-selects stored or first team
2. `restoreGitHubAuth()` — restores GitHub PAT from storage
3. `_initAgentConfig()` — seeds 13 built-in agents, refreshes Anthropic model cache

**Scheduled tasks:** None (polling is on-demand per page).

**Health check:** No local health endpoint — server health verified via login endpoint.

---

## 6. Data Model Layer (Models)

All models use `@JsonSerializable()` with `json_serializable` code generation. Generated files: `.g.dart`.

### Core Models

```
=== User (user.dart) ===
Fields: id (String), email (String), displayName (String), avatarUrl (String?),
        isActive (bool?), lastLoginAt (DateTime?), createdAt (DateTime?)
Serialization: @JsonSerializable, fromJson/toJson

=== AuthResponse (user.dart) ===
Fields: token (String), refreshToken (String), user (User)

=== Project (project.dart) ===
Fields: id (String), teamId (String), name (String), description (String?),
        githubConnectionId (String?), repoUrl (String?), repoFullName (String?),
        defaultBranch (String?), jiraConnectionId (String?), jiraProjectKey (String?),
        jiraDefaultIssueType (String?), jiraLabels (List<String>?),
        jiraComponent (String?), techStack (String?), healthScore (int?),
        lastAuditAt (DateTime?), isArchived (bool?), createdAt (DateTime?),
        updatedAt (DateTime?)

=== Team (team.dart) ===
Fields: id, name, description, avatarUrl, createdAt, updatedAt
Related: TeamMember, TeamInvitation

=== Persona (persona.dart) ===
Fields: id, teamId, name, description, scope (Scope), agentType (AgentType),
        content, isActive, createdAt, updatedAt

=== Directive (directive.dart) ===
Fields: id, teamId, name, description, content, scope (DirectiveScope),
        category (DirectiveCategory), createdAt, updatedAt

=== QaJob (qa_job.dart) ===
Fields: id, teamId, projectId, projectName, mode (JobMode),
        status (JobStatus), result (JobResult?), startedAt, completedAt,
        healthScore (int?), critical/high/medium/low counts, totalFindings, etc.

=== AgentRun (agent_run.dart) ===
Fields: id, jobId, agentType (AgentType), status (AgentStatus),
        result (AgentResult?), startedAt, completedAt, report, findings count

=== AgentProgress (agent_progress.dart) ===
Fields: agentRunId, agentType, status, currentPhase, phaseProgress,
        overallProgress, liveFindings, lastOutput, startedAt, updatedAt

=== HealthSnapshot (health_snapshot.dart) ===
Fields: id, projectId, score, category scores, snapshotDate
Related: GitHubConnection, HealthSchedule

=== Specification (specification.dart) ===
Fields: id, projectId, name, type (SpecType), fileUrl, fileSizeBytes, checksum

=== ComplianceItem (compliance_item.dart) ===
Fields: id, jobId, specId, requirementId, title, status (ComplianceStatus),
        evidence, recommendations

=== DependencyScan (dependency_scan.dart) ===
Fields: id, projectId, scanDate, totalDeps, outdated, vulnerable,
        vulnerabilities list

=== RemediationTask (remediation_task.dart) ===
Fields: id, jobId, findingId, title, description, priority (Priority),
        status (TaskStatus), assigneeId, jiraTicketKey, effort (Effort)

=== TechDebtItem (tech_debt_item.dart) ===
Fields: id, projectId, title, description, category (DebtCategory),
        severity (Severity), status (DebtStatus), businessImpact (BusinessImpact),
        effort (Effort), estimatedHours, filePath, lineNumber
```

### Module-Specific Models

```
=== Courier Models (courier_models.dart) ===
HTTP request/response testing models: CourierEnvironment, CourierCollection,
CourierRequest, CourierResponse, CourierHeader, CourierQueryParam, CourierAuth,
CourierScript, CourierKeyValue

=== Fleet Models (fleet_models.dart) ===
Docker container management: FleetContainer, FleetContainerDetail, FleetEvent,
ContainerStats, FleetImage, FleetVolume, FleetNetwork, FleetNetworkDetail,
ServiceProfile, SolutionProfile, WorkstationProfile, WorkstationSolution

=== Registry Models (registry_models.dart) ===
Service registry: RegisteredService, ServiceEndpoint, ServiceDependency,
EnvConfig, InfraResource, PortAllocation, Solution, SolutionService,
WorkstationProfile, WorkstationSolution, StoredConfig

=== Relay Models (relay_models.dart) ===
Team messaging: RelayChannel, RelayMessage, RelayReaction, RelayThread,
RelayDirectConversation, RelayEvent, RelayPresence, RelayAttachment

=== Vault Models (vault_models.dart) ===
Secret management: VaultSecret, VaultSecretValue, VaultPolicy, VaultPolicyRule,
VaultAuditEntry, VaultSealStatus, VaultTransitKey, VaultDynamicRole, VaultLease,
VaultRotationPolicy, VaultRotationHistory

=== Logger Models (logger_models.dart) ===
Centralized logging: LogSourceResponse, LogEntryResponse, LogTrapResponse,
SavedQueryResponse, QueryHistoryResponse, LogQueryRequest, DslQueryRequest

=== Jira Models (jira_models.dart) ===
Jira integration: JiraProject, JiraIssue, JiraUser, JiraSprint, JiraComment,
JiraTransition, JiraPriority

=== VCS Models (vcs_models.dart) ===
Version control: VcsOrganization, VcsRepository, VcsBranch, VcsPullRequest,
VcsCommit, VcsTag, WorkflowRun, VcsStash, VcsCredentials, RepoStatus,
FileChange, CloneProgress, DiffResult, DiffHunk, DiffLine, CreatePRRequest

=== Scribe Models (scribe_models.dart) ===
Code editor: ScribeFile, ScribeTab, ScribeSession

=== Scribe Diff Models (scribe_diff_models.dart) ===
Diff editing: DiffHunkModel, DiffLineModel, DiffSummary, DiffSession

=== OpenAPI Spec (openapi_spec.dart) ===
OpenAPI parsing: OpenApiSpec, OpenApiPath, OpenApiOperation, OpenApiSchema,
OpenApiParameter, OpenApiResponse

=== Anthropic Model Info (anthropic_model_info.dart) ===
AI models: AnthropicModelInfo
```

---

## 7. Enum Inventory

### Core Enums (enums.dart)

| Enum | Values | Used In |
|---|---|---|
| AgentResult | pass, warn, fail | AgentRun |
| AgentStatus | pending, running, completed, failed | AgentRun, AgentProgress |
| AgentType | security, codeQuality, buildHealth, completeness, apiContract, testCoverage, uiUx, documentation, database, performance, dependency, architecture | AgentRun, Persona |
| BusinessImpact | low, medium, high, critical | TechDebtItem |
| ComplianceStatus | met, partial, missing, notApplicable | ComplianceItem |
| DebtCategory | architecture, code, test, dependency, documentation | TechDebtItem |
| DebtStatus | identified, planned, inProgress, resolved | TechDebtItem |
| DirectiveCategory | architecture, standards, conventions, context, other | Directive |
| DirectiveScope | team, project, user | Directive |
| Effort | s, m, l, xl | RemediationTask, TechDebtItem |
| FindingStatus | open, acknowledged, falsePositive, fixed, wontFix | Findings |
| GitHubAuthType | pat, oauth, ssh | VcsCredentials |
| InvitationStatus | pending, accepted, expired | TeamInvitation |
| JobMode | audit, compliance, bugInvestigate, remediate, techDebt, dependency, healthMonitor | QaJob |
| JobResult | pass, warn, fail | QaJob |
| JobStatus | pending, running, completed, failed, cancelled | QaJob |
| Priority | p0, p1, p2, p3 | RemediationTask |
| ScheduleType | daily, weekly, onCommit | HealthSchedule |
| Scope | system, team, user | Persona |
| Severity | critical, high, medium, low | Findings, DependencyScan |
| SpecType | openapi, markdown, screenshot, figma | Specification |
| TaskStatus | pending, assigned, exported, jiraCreated, completed | RemediationTask |
| TeamRole | owner, admin, member, viewer | TeamMember |
| VulnerabilityStatus | open, updating, suppressed, resolved | DependencyScan |

All enums serialize to SCREAMING_SNAKE_CASE with `toJson()`/`fromJson()` and have `displayName` getters. Each has a `JsonConverter` companion class.

### Module Enums

- **courier_enums.dart:** BodyType (10 values), AuthType (10 values), ScriptType (PRE_REQUEST, POST_RESPONSE)
- **fleet_enums.dart:** ContainerState (7 values), HealthStatus (4 values), RestartPolicy (4 values), Protocol (TCP, UDP), ProfileStatus (3 values)
- **registry_enums.dart:** ServiceType (8 values), ServiceStatus (6 values), DependencyType (5 values), SolutionStatus (5 values), InfraResourceType (10 values), ConfigType (6 values), PortProtocol (TCP, UDP, HTTP, HTTPS, GRPC)
- **relay_enums.dart:** ChannelType (3 values), MessageType (5 values), RelayEventType (10 values), UserStatus (4 values)
- **vault_enums.dart:** SecretType (6 values), VaultPermission (6 values), TransitKeyType (6 values), SealStatus (3 values), RotationStatus (5 values), AuditOperation (8 values)
- **logger_enums.dart:** LogLevel (6 values), TrapSeverity (4 values), TrapStatus (ACTIVE, PAUSED, DISABLED), ConditionOperator (12 values), ConditionField (8 values)

---

## 8. Database Layer (Local Cache)

**Technology:** Drift (SQLite) — local cache only, not a primary data store.

**File:** `lib/database/tables.dart` — defines table schemas
**File:** `lib/database/database.dart` — `CodeOpsDatabase` extends `_$CodeOpsDatabase`

Tables are used for local caching of:
- Scribe sessions (open tabs, file content)
- Agent configurations (built-in agent definitions)
- Anthropic model cache
- Cloned repository paths

The primary data store is the CodeOps-Server (PostgreSQL).

---

## 9. Service Layer

### Authentication & HTTP

```
=== AuthService (services/auth/auth_service.dart) ===
Injects: ApiClient, SecureStorageService, CodeOpsDatabase
Public Methods:
  - login(String email, String password): Future<User>
  - register(String email, String password, String displayName): Future<User>
  - refreshToken(): Future<void>
  - changePassword(String currentPassword, String newPassword): Future<void>
  - logout(): Future<void>
  - tryAutoLogin(): Future<void>
  - dispose(): void
Stream: authStateStream → Stream<AuthState>
State: currentState → AuthState, currentUser → User?

=== SecureStorageService (services/auth/secure_storage.dart) ===
Injects: SharedPreferences (lazy-init)
Storage keys: auth_token, refresh_token, current_user_id, selected_team_id,
              claude_model, github_pat, codeops_anthropic_api_key,
              remember_me, remembered_email, remembered_password
Public Methods:
  - getAuthToken/setAuthToken: Future<String?>/Future<void>
  - getRefreshToken/setRefreshToken
  - getCurrentUserId/setCurrentUserId
  - getSelectedTeamId/setSelectedTeamId
  - getAnthropicApiKey/setAnthropicApiKey/deleteAnthropicApiKey
  - read(String key)/write(String key, String value)/delete(String key)
  - clearAll(): Future<void> — preserves remember-me + API key

=== ApiClient (services/cloud/api_client.dart) ===
Injects: SecureStorageService
Wraps: Dio with 4 interceptors:
  1. Auth interceptor — attaches Bearer token (skips /auth/login, /auth/register, /auth/refresh, /health)
  2. Refresh interceptor — on 401, attempts single token refresh then retries
  3. Error interceptor — maps DioException to typed ApiException subclasses
  4. Logging interceptor — correlation ID, timing (never logs bodies or tokens)
Public Methods: get, post, put, delete, uploadFile, downloadFile
```

### Cloud API Clients (all in services/cloud/)

All API services inject `ApiClient` and delegate HTTP calls. Method signatures match the OpenAPI spec.

| Service | File | Purpose |
|---|---|---|
| AdminApi | admin_api.dart | System settings, user management, audit logs |
| AnthropicApiService | anthropic_api_service.dart | Anthropic model listing + Claude Messages API |
| ComplianceApi | compliance_api.dart | Compliance check CRUD |
| CourierApi | courier_api.dart | HTTP request testing (environments, collections, requests) |
| DependencyApi | dependency_api.dart | Dependency scan CRUD |
| DirectiveApi | directive_api.dart | Directive CRUD + project assignment |
| FindingApi | finding_api.dart | Finding queries + status updates |
| FleetApi | fleet_api.dart | Docker container/image/volume/network management |
| HealthMonitorApi | health_monitor_api.dart | Health snapshots, trends, schedules |
| IntegrationApi | integration_api.dart | GitHub/Jira connection management |
| JobApi | job_api.dart | QA job CRUD + agent run queries |
| LoggerApi | logger_api.dart | Log source/entry/trap/query management |
| MetricsApi | metrics_api.dart | Analytics metrics queries |
| PersonaApi | persona_api.dart | Persona CRUD |
| ProjectApi | project_api.dart | Project CRUD |
| RegistryApi | registry_api.dart | Service registry CRUD |
| RegistryApiClient | registry_api_client.dart | Registry-specific Dio client |
| RelayApi | relay_api.dart | Channel/message/DM CRUD |
| RelayWebSocketService | relay_websocket_service.dart | WebSocket real-time messaging |
| ReportApi | report_api.dart | Report queries + downloads |
| TaskApi | task_api.dart | Remediation task CRUD |
| TeamApi | team_api.dart | Team + member + invitation management |
| TechDebtApi | tech_debt_api.dart | Tech debt item CRUD |
| UserApi | user_api.dart | User profile queries |
| VaultApi | vault_api.dart | Vault secret/policy/transit/dynamic/rotation CRUD |
| VaultApiClient | vault_api_client.dart | Vault-specific Dio client (port 8097) |

### Orchestration Services

```
=== JobOrchestrator (services/orchestration/job_orchestrator.dart) ===
Injects: AgentDispatcher, AgentMonitor, ProgressAggregator, JobApi
Purpose: Coordinates multi-agent QA jobs — dispatches agents, monitors progress, aggregates results

=== AgentDispatcher (services/orchestration/agent_dispatcher.dart) ===
Injects: ProcessManager, AgentConfigService
Purpose: Spawns Claude Code CLI subprocesses for each agent

=== AgentMonitor (services/orchestration/agent_monitor.dart) ===
Purpose: Tracks running agent processes, detects completion/failure

=== ProgressAggregator (services/orchestration/progress_aggregator.dart) ===
Purpose: Aggregates individual agent progress into job-level metrics

=== VeraManager (services/orchestration/vera_manager.dart) ===
Purpose: Manages the Vera AI manager persona for job orchestration

=== BugInvestigationOrchestrator (services/orchestration/bug_investigation_orchestrator.dart) ===
Purpose: Orchestrates bug investigation workflow from Jira ticket
```

### Analysis Services

```
=== HealthCalculator (services/analysis/health_calculator.dart) ===
Purpose: Computes project health scores from findings (weighted by severity/agent)

=== DependencyScanner (services/analysis/dependency_scanner.dart) ===
Purpose: Scans project dependencies for vulnerabilities and outdated packages

=== TechDebtTracker (services/analysis/tech_debt_tracker.dart) ===
Purpose: Tracks and categorizes technical debt items
```

### Agent Services

```
=== AgentConfigService (services/agent/agent_config_service.dart) ===
Injects: CodeOpsDatabase, AnthropicApiService, SecureStorageService
Purpose: Manages 13 built-in agent configurations, seeds database, caches Anthropic models

=== PersonaManager (services/agent/persona_manager.dart) ===
Purpose: Loads persona markdown from assets, resolves persona for agent execution

=== ReportParser (services/agent/report_parser.dart) ===
Purpose: Parses agent output reports into structured findings

=== TaskGenerator (services/agent/task_generator.dart) ===
Purpose: Generates remediation tasks from audit findings
```

### Data Services

```
=== ScribeDiffService (services/data/scribe_diff_service.dart) ===
Purpose: Computes text diffs for Scribe editor

=== ScribeFileService (services/data/scribe_file_service.dart) ===
Purpose: File I/O for Scribe editor (read/write/watch)

=== ScribePersistenceService (services/data/scribe_persistence_service.dart) ===
Purpose: Persists Scribe sessions (open tabs, cursor positions) to local database

=== SyncService (services/data/sync_service.dart) ===
Purpose: Syncs local cache with server data
```

### Platform Services

```
=== ClaudeCodeDetector (services/platform/claude_code_detector.dart) ===
Purpose: Detects if Claude Code CLI is installed and its version

=== ProcessManager (services/platform/process_manager.dart) ===
Purpose: Manages system processes (Claude Code CLI execution)

=== GitService (services/vcs/git_service.dart) ===
Purpose: Local git CLI wrapper (clone, pull, push, checkout, status, diff, log, stash, tag, merge, blame)
Injects: ProcessRunner (abstraction over dart:io Process for testability)

=== GitHubProvider (services/vcs/github_provider.dart) ===
Purpose: GitHub REST API v3 implementation — orgs, repos, branches, PRs, commits, workflows, releases
Injects: Dio (separate from ApiClient, targets api.github.com)

=== VcsProvider (services/vcs/vcs_provider.dart) ===
Purpose: Abstract interface for VCS operations (implemented by GitHubProvider)

=== RepoManager (services/vcs/repo_manager.dart) ===
Purpose: Tracks cloned repositories (local path ↔ remote URL mapping via Drift DB)
```

### Other Services

```
=== ExportService (services/integration/export_service.dart) ===
Purpose: Exports findings/reports to CSV, JSON, PDF formats

=== JiraService (services/jira/jira_service.dart) ===
Purpose: Jira REST API integration — issue CRUD, search, transitions

=== JiraMapper (services/jira/jira_mapper.dart) ===
Purpose: Maps CodeOps findings/tasks to Jira issue fields

=== OpenApiParser (services/openapi_parser.dart) ===
Purpose: Parses OpenAPI/Swagger YAML specs into structured models

=== LogService (services/logging/log_service.dart) ===
Purpose: Centralized logging with levels, tags, console colors, and file rotation
Global instance: `log` (accessed as `log.d()`, `log.i()`, `log.w()`, `log.e()`)

=== LogConfig (services/logging/log_config.dart) ===
Purpose: Environment-aware log configuration (debug vs release defaults)
```

---

## 10. Pages (UI Routes)

64 pages mapped to GoRouter routes. All are `ConsumerWidget` or `ConsumerStatefulWidget`.

### Core Pages

| Route | Page | Purpose |
|---|---|---|
| `/login` | LoginPage | Email/password auth with remember-me |
| `/` | HomePage | Dashboard with project health grid, quick actions, recent activity |
| `/projects` | ProjectsPage | Project list with search/filter |
| `/projects/:id` | ProjectDetailPage | Project detail with tabs |
| `/repos` | GitHubBrowserPage | GitHub org/repo browser with master-detail layout |
| `/scribe` | ScribePage | Multi-tab code editor with syntax highlighting, diff, markdown |
| `/audit` | AuditWizardPage | Multi-step audit configuration wizard |
| `/compliance` | ComplianceWizardPage | Compliance check wizard |
| `/dependencies` | DependencyScanPage | Dependency vulnerability scanner |
| `/bugs` | BugInvestigatorPage | Bug investigation from Jira ticket |
| `/bugs/jira` | JiraBrowserPage | Jira issue browser |
| `/tasks` | TaskManagerPage | Remediation task manager |
| `/tech-debt` | TechDebtPage | Tech debt dashboard |
| `/health` | HealthDashboardPage | Health monitoring with trends/schedules |
| `/history` | JobHistoryPage | QA job history |
| `/jobs/:id` | JobProgressPage | Live job progress with agent cards |
| `/jobs/:id/report` | JobReportPage | Job report viewer |
| `/jobs/:id/findings` | FindingsExplorerPage | Finding browser with filters |
| `/jobs/:id/tasks` | TaskListPage | Task list for a job |
| `/personas` | PersonasPage | Persona list |
| `/personas/:id/edit` | PersonaEditorPage | Persona markdown editor |
| `/directives` | DirectivesPage | Directive manager |
| `/settings` | SettingsPage | Agent config, API keys, general settings |
| `/admin` | AdminHubPage | Admin: users, settings, audit log, usage stats |

### Vault Pages (9 routes)

| Route | Page |
|---|---|
| `/vault` | VaultDashboardPage |
| `/vault/secrets` | VaultSecretsPage |
| `/vault/secrets/:id` | VaultSecretDetailPage |
| `/vault/policies` | VaultPoliciesPage |
| `/vault/policies/:id` | VaultPolicyDetailPage |
| `/vault/transit` | VaultTransitPage |
| `/vault/dynamic` | VaultDynamicPage |
| `/vault/rotation` | VaultRotationPage |
| `/vault/seal` | VaultSealPage |
| `/vault/audit` | VaultAuditPage |

### Registry Pages (17 routes)

| Route | Page |
|---|---|
| `/registry` | ServiceListPage |
| `/registry/services/new` | ServiceFormPage |
| `/registry/services/:id` | ServiceDetailPage |
| `/registry/services/:id/edit` | ServiceFormPage (edit mode) |
| `/registry/ports` | PortAllocationPage |
| `/registry/solutions` | SolutionListPage |
| `/registry/solutions/:id` | SolutionDetailPage |
| `/registry/dependencies` | DependencyGraphPage |
| `/registry/dependencies/impact` | ImpactAnalysisPage |
| `/registry/topology` | TopologyPage |
| `/registry/infra` | InfraResourcesPage |
| `/registry/routes` | ApiRoutesPage |
| `/registry/config` | ConfigGeneratorPage |
| `/registry/workstations` | WorkstationListPage |
| `/registry/workstations/:id` | WorkstationDetailPage |
| `/registry/api-docs` | ApiDocsPage |
| `/registry/api-docs/:serviceId` | ApiDocsPage (service-specific) |

### Fleet Pages (12 routes)

| Route | Page |
|---|---|
| `/fleet` | FleetDashboardPage |
| `/fleet/containers` | ContainerListPage |
| `/fleet/containers/:id` | ContainerDetailPage |
| `/fleet/service-profiles` | ServiceProfileListPage |
| `/fleet/service-profiles/:id` | ServiceProfileDetailPage |
| `/fleet/solution-profiles` | SolutionProfileListPage |
| `/fleet/solution-profiles/:id` | SolutionProfileDetailPage |
| `/fleet/workstation-profiles` | WorkstationProfileListPage |
| `/fleet/workstation-profiles/:id` | WorkstationProfileDetailPage |
| `/fleet/images` | ImageListPage |
| `/fleet/volumes` | VolumeListPage |
| `/fleet/networks` | NetworkListPage |

### Relay Pages (4 routes)

| Route | Page |
|---|---|
| `/relay` | RelayPage |
| `/relay/channel/:channelId` | RelayPage (channel selected) |
| `/relay/channel/:channelId/thread/:messageId` | RelayPage (thread open) |
| `/relay/dm/:conversationId` | RelayPage (DM selected) |

---

## 11. Security Configuration

```
Authentication: JWT (Bearer token via CodeOps-Server)
Token storage: SharedPreferences (macOS UserDefaults) — NOT Keychain
Password encoder: Server-side (BCrypt)

Public paths (no auth required):
  - /auth/login
  - /auth/register
  - /auth/refresh
  - /health

Protected paths: All other API calls require Bearer token

Token refresh: Automatic on 401 — single retry with refresh token, then logout

CORS: N/A (desktop app, not browser)
CSRF: N/A (desktop app)
Rate limiting: Client detects 429 via RateLimitException (retryAfterSeconds)

GitHub auth: Personal Access Token stored in SharedPreferences
Anthropic API key: Stored in SharedPreferences
```

---

## 12. Custom Security Components

```
=== ApiClient interceptors ===
Auth interceptor: Attaches Bearer token to all non-public requests
Refresh interceptor: On 401, refreshes token using separate Dio instance (avoids interceptor loop)
Error interceptor: Maps HTTP errors to typed ApiException hierarchy

=== ApiException hierarchy (sealed class) ===
  - BadRequestException (400)
  - UnauthorizedException (401)
  - ForbiddenException (403)
  - NotFoundException (404)
  - ConflictException (409)
  - ValidationException (422)
  - RateLimitException (429) — includes retryAfterSeconds
  - ServerException (500+)
  - NetworkException (no connectivity)
  - TimeoutException (request timeout)

=== AuthService ===
Auth state: unknown → authenticated | unauthenticated
Token storage: SharedPreferences (access token, refresh token, user ID)
Auto-login: Validates stored token via GET /users/me on startup
Logout: Clears tokens, wipes local database cache
```

---

## 13. Exception Handling & Error Responses

The `ApiClient` error interceptor maps all HTTP errors to typed `ApiException` subclasses (see Section 12). UI components catch these and display via `NotificationToast`:

```dart
showToast(context, message: 'Failed: $e', type: ToastType.error);
```

No global error handler widget — each page/widget handles errors locally.

---

## 14. Mappers / DTOs

No separate mapper layer. Models use `@JsonSerializable()` with `fromJson`/`toJson` factory methods and `.g.dart` code generation. Some models have custom `fromGitHubJson` factories (VCS models) for mapping GitHub API responses.

---

## 15. Utility Classes & Shared Components

```
=== AppConstants (utils/constants.dart) ===
All magic numbers and configuration values. 130+ constants covering API URLs,
storage keys, UI dimensions, timeout values, agent limits, Scribe editor config.

=== CodeOpsDateUtils (utils/date_utils.dart) ===
Methods: formatRelative, formatDateTime, formatDate, formatTime, formatDuration

=== FileUtils (utils/file_utils.dart) ===
Methods: formatFileSize, getFileExtension, isTextFile, isImageFile

=== FuzzyMatcher (utils/fuzzy_matcher.dart) ===
Methods: score(query, target) — fuzzy string matching for search

=== MarkdownHeadingParser (utils/markdown_heading_parser.dart) ===
Methods: parse(markdown) — extracts heading hierarchy for table-of-contents

=== StringUtils (utils/string_utils.dart) ===
Methods: truncate, capitalize, pluralize, slugify
```

---

## 16. Database Schema (Live)

N/A — This is a desktop application. Local SQLite database is managed by Drift ORM (auto-migrated). No external database to inspect.

The Drift database (`CodeOpsDatabase`) caches:
- Agent configurations (built-in 13 agents)
- Anthropic model info
- Scribe sessions (open tabs, content, cursor positions)
- Cloned repository paths

---

## 17. Message Broker Configuration

**WebSocket** for Relay (team messaging):
- URL: `ws://localhost:8090/ws/relay`
- Heartbeat: 30-second interval
- Reconnect: Exponential backoff, max 30-second delay
- Service: `RelayWebSocketService` manages connection lifecycle

No RabbitMQ/Kafka/SQS on the client side.

---

## 18. Cache Layer

No Redis or caching layer. Local SQLite (Drift) is used for session persistence and agent config caching.

---

## 19. Environment Variable Inventory

N/A — Flutter desktop app. All configuration is hardcoded in `AppConstants`. No `.env` files.

| Constant | Location | Value | Notes |
|---|---|---|---|
| apiBaseUrl | constants.dart | http://localhost:8090 | Server URL |
| vaultApiBaseUrl | constants.dart | http://localhost:8097 | Vault URL |
| anthropicApiBaseUrl | constants.dart | https://api.anthropic.com | Anthropic API |
| relayWebSocketUrl | constants.dart | ws://localhost:8090/ws/relay | WebSocket |

For production, these would need to be externalized.

---

## 20. Service Dependency Map

```
CodeOps-Client → Depends On:
  CodeOps-Server (http://localhost:8090/api/v1/) — primary backend for all data
  CodeOps-Vault (http://localhost:8097/api/v1/vault/) — secret management
  GitHub REST API (https://api.github.com) — repository browsing, PRs, commits
  Anthropic API (https://api.anthropic.com) — model listing, agent dispatch
  Claude Code CLI (local binary) — agent subprocess execution

Downstream Consumers:
  None — this is the end-user desktop client
```

---

## 21. Known Technical Debt & Issues

### TODO/Placeholder/Stub Scan

**Zero actual TODO/FIXME/XXX/HACK patterns found in source code.** All matches were:
- Agent description strings that mention "TODOs" as part of what agents scan for
- DartDoc comments referencing "placeholder" in the context of replacing previous implementations
- UI `placeholder` properties on text fields

### Issues Discovered During Audit

| Issue | Location | Severity | Notes |
|---|---|---|---|
| Hardcoded server URLs | constants.dart | Medium | apiBaseUrl, vaultApiBaseUrl hardcoded to localhost — need env-based config for production |
| SharedPreferences for tokens | secure_storage.dart | Medium | Uses UserDefaults instead of Keychain — acceptable for dev, not production |
| Documentation coverage 53% | lib/ (786 undocumented classes) | High | BLOCKING — 887/1673 classes have DartDoc, models/DTOs excluded from requirement |
| Method documentation 49.5% | lib/ (1774 undocumented methods) | High | BLOCKING — 1740/3514 methods have DartDoc |
| No CI/CD pipeline | project root | Low | No .github/workflows or equivalent detected |

---

## 22. Security Vulnerability Scan (Snyk)

**Scan Date:** 2026-02-28
**Snyk CLI Version:** 1.1303.0

### Dependency Vulnerabilities (Open Source)
**SKIPPED** — Snyk does not support Flutter/Dart dependency scanning (`SNYK-CLI-0008: No supported files found`).

### Code Vulnerabilities (SAST)
**SKIPPED** — Snyk Code is not enabled for the organization (`SNYK-CODE-0005: 403 Forbidden`).

### IaC Findings
N/A — No Dockerfile, docker-compose, or Terraform files in this project.

---

## Appendix: Widget Inventory Summary

316 widget files organized by feature area:

| Directory | Count | Purpose |
|---|---|---|
| admin/ | 4 | Admin hub tabs (users, settings, audit log, usage) |
| compliance/ | 3 | Compliance wizard panels |
| dashboard/ | 4 | Home dashboard (health grid, quick start, activity, team) |
| dependency/ | 4 | Dependency scan UI |
| findings/ | 4 | Finding browser (table, detail, filters, actions) |
| fleet/ | 24 | Docker container/profile management |
| health/ | 3 | Health dashboard panels |
| jira/ | 7 | Jira issue browser and dialogs |
| personas/ | 4 | Persona editor, list, preview, test runner |
| progress/ | 9 | Job progress (agent cards, terminal, status grid) |
| registry/ | 42 | Service registry (topology, dependencies, ports, configs) |
| relay/ | 22 | Real-time team messaging |
| reports/ | 7 | Report rendering (charts, gauges, markdown) |
| scribe/ | 28 | Code editor (tabs, diff, find, markdown, shortcuts) |
| settings/ | 6 | Settings panels (agents, API keys, general) |
| shared/ | 5 | Reusable: empty state, error, loading, toast, search |
| shell/ | 1 | Navigation shell (sidebar + top bar) |
| tasks/ | 3 | Task management cards/lists |
| tech_debt/ | 4 | Tech debt dashboard |
| vault/ | 43 | Secret management UI |
| vcs/ | 12 | Version control (repo browser, diff viewer, PRs) |
| wizard/ | 8 | Audit/compliance wizard steps |

---

## Appendix: Test Coverage Summary

| Category | Test Files | Description |
|---|---|---|
| models/ | 29 | Serialization, enum alignment, model equality |
| services/ | 39 | API client, auth, orchestration, analysis, platform |
| providers/ | 28 | Riverpod provider behavior |
| pages/ | 65 | Page widget rendering and interaction |
| widgets/ | 220 | Widget rendering, state, interaction |
| theme/ | 2 | Theme consistency |
| utils/ | 5 | Utility function behavior |
| router/ | 1 | Route configuration |
| database/ | 2 | Database operations |
| navigation/ | 1 | Vault route testing |
| integration/ | 1 | Compliance flow integration |
| **Total** | **405 unit/widget** | **2,820 test() + 2,091 testWidgets() calls** |
| integration_test/ | 5 | Full flow integration tests |
