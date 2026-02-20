# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-02-20T13:42:33Z
**Branch:** main
**Commit:** 688f0c69063f1ff4af0b87d132181f0d0866865c Codebase audit — 2026-02-20
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml

> This audit is the single source of truth for the CodeOps-Client codebase.
> The OpenAPI spec (CodeOps-Client-OpenAPI.yaml) is the source of truth for all consumed API endpoints, request/response DTOs, and API contracts.
> An AI reading this audit + the OpenAPI spec should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:          CodeOps-Client
Repository URL:        https://github.com/adamallard/CodeOps-Client
Primary Language:      Dart / Flutter
Dart Version:          3.11.0
Flutter Version:       3.41.1
Build Tool:            Flutter CLI + build_runner
Current Branch:        main
Latest Commit Hash:    688f0c69063f1ff4af0b87d132181f0d0866865c
Latest Commit Message: Codebase audit — 2026-02-20
Audit Timestamp:       2026-02-20T13:42:33Z
```

---

## 2. Directory Structure

```
CodeOps-Client/
├── analysis_options.yaml
├── pubspec.yaml
├── assets/
│   ├── personas/           ← 12 built-in agent persona .md files + vera-manager
│   └── templates/          ← 5 report templates (audit, compliance, executive, rca, task-prompt)
├── integration_test/       ← 5 integration test flows
├── lib/
│   ├── main.dart           ← Entry point (window_manager init)
│   ├── app.dart            ← Root widget (ProviderScope, auth bridging)
│   ├── router.dart         ← GoRouter with 31 routes
│   ├── database/           ← Drift SQLite (23 tables, schema v7)
│   │   ├── database.dart
│   │   └── tables.dart
│   ├── models/             ← 22 model files (140+ classes, 35+ enums)
│   ├── pages/              ← 27 page widgets
│   ├── providers/          ← 25 provider files (150+ Riverpod providers)
│   ├── services/
│   │   ├── agent/          ← Agent config, persona, report parsing, task gen
│   │   ├── analysis/       ← Dependency, health, tech debt analysis
│   │   ├── auth/           ← Auth service + secure storage
│   │   ├── cloud/          ← 21 API service files (218+ methods)
│   │   ├── data/           ← Scribe persistence, sync
│   │   ├── integration/    ← Export service (markdown, PDF, ZIP, CSV)
│   │   ├── jira/           ← Jira REST API client + mapper
│   │   ├── logging/        ← Structured logging with file output
│   │   ├── orchestration/  ← Agent dispatch, monitoring, job lifecycle
│   │   ├── platform/       ← Claude Code CLI detection, process manager
│   │   └── vcs/            ← Git CLI, GitHub REST API, repo manager
│   ├── theme/              ← Dark theme, colors, typography
│   ├── utils/              ← Constants, date/file/string utils
│   └── widgets/            ← 107+ reusable widget files organized by feature
└── test/                   ← 235 unit/widget test files
```

Single-module Flutter desktop application (macOS). Source organized by feature within `lib/`. All generated code (`.g.dart`, `.freezed.dart`) excluded from audit.

---

## 3. Build & Dependency Manifest

**File:** `pubspec.yaml`

### Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter | SDK | UI framework |
| flutter_riverpod | 2.6.1 | State management |
| go_router | 14.8.1 | Declarative routing (31 routes) |
| drift | 2.22.1 | Local SQLite ORM (23 tables) |
| sqlite3_flutter_libs | 0.5.28 | Native SQLite bindings |
| dio | 5.7.0 | HTTP client (CodeOps-Server, Vault, GitHub, Jira) |
| flutter_secure_storage | 9.2.4 | Encrypted token/credential storage |
| json_annotation | 4.9.0 | JSON serialization annotations |
| freezed_annotation | 2.4.4 | Immutable model annotations |
| flutter_markdown | 0.7.6 | Markdown rendering |
| re_editor | 0.8.0 | Code editor widget (Scribe) |
| fl_chart | 0.70.2 | Charts (health trends, severity) |
| window_manager | 0.4.3 | Desktop window management |
| path_provider | 2.1.5 | Platform-specific directories |
| path | 1.9.1 | Path manipulation |
| url_launcher | 6.3.1 | Open URLs in browser |
| intl | 0.19.0 | Date/number formatting |
| collection | 1.19.1 | Collection utilities |

### Dev Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter_test | SDK | Test framework |
| mocktail | 1.0.4 | Mock library (typesafe, no codegen) |
| build_runner | 2.4.14 | Code generation runner |
| drift_dev | 2.22.1 | Drift code generation |
| json_serializable | 6.9.0 | JSON serialization codegen |
| freezed | 2.5.8 | Immutable model codegen |
| flutter_lints | 5.0.0 | Lint rules |

### Build Commands

```
Build:     flutter build macos
Test:      flutter test
Run:       flutter run -d macos
Codegen:   dart run build_runner build --delete-conflicting-outputs
Package:   flutter build macos --release
```

---

## 4. Configuration & Infrastructure Summary

- **`pubspec.yaml`** — SDK constraints: Dart ^3.6.0, Flutter >=3.27.0. Assets: `assets/personas/`, `assets/templates/`, `fonts/`. Fonts: Inter (400/500/600/700), JetBrains Mono (400).
- **`analysis_options.yaml`** — Extends `flutter_lints`. Custom rules: `prefer_const_constructors`, `prefer_const_declarations_for_immutable_fields`, `always_declare_return_types`, `avoid_print`.
- **No `docker-compose.yml`** — This is a desktop client, not a containerized service.
- **No `.env`** — All configuration is in `lib/utils/constants.dart` (hardcoded for development).

**Connection Map:**
```
Database:        SQLite (local, via Drift, schema v7)
Cache:           None (local SQLite serves as offline cache)
Message Broker:  None
External APIs:
  - CodeOps-Server: http://localhost:8090/api/v1/ (JWT auth)
  - CodeOps-Vault:  http://localhost:8097/api/v1/vault/ (JWT auth, same tokens)
  - GitHub API:     https://api.github.com (PAT Bearer auth)
  - Jira Cloud:     https://{instance}.atlassian.net/rest/api/3 (Basic Auth email:apiToken)
  - Anthropic API:  https://api.anthropic.com (API key auth)
Cloud Services:  S3 (via CodeOps-Server presigned URLs for reports/specs)
```

**CI/CD:** None detected.

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart`

**Startup sequence:**
1. Initialize `LogService` and `LogConfig`
2. Configure `WindowManager`: size 1440x900, min 1024x700, hidden title bar, center on screen
3. Run `ProviderScope(child: CodeOpsApp())` — Riverpod root

**`app.dart` initialization (on auth state change to authenticated):**
1. Bridge `authStateProvider` stream → GoRouter's `authNotifier`
2. Auto-select team: loads teams, picks first, stores selected team ID
3. Seed built-in agents: calls `AgentConfigService.seedBuiltInAgents()`
4. Restore GitHub auth: reads PAT from secure storage, authenticates VcsProvider
5. Refresh Anthropic model cache: fetches available Claude models

**Scheduled tasks:** None (desktop app, no background jobs).

**Health endpoint:** N/A — this is a client application, not a server. The health dashboard at `/health` monitors CodeOps-Server projects.

---

## 6. Entity / Data Model Layer

### Local Database (Drift SQLite — 23 Tables)

**File:** `lib/database/tables.dart`

All tables use `TextColumn` primary keys (UUID strings). Schema version 7 with migration support (v1→v7). Tables serve as offline cache — synced from CodeOps-Server via `SyncService`.

| Table | Primary Key | Key Columns | Purpose |
|---|---|---|---|
| Users | id (text) | email, displayName, isActive | User cache |
| Teams | id (text) | name, ownerId, memberCount | Team cache |
| Projects | id (text) | teamId, name, healthScore, isArchived | Project cache |
| QaJobs | id (text) | projectId, mode, status, overallResult, healthScore | Job cache |
| AgentRuns | id (text) | jobId, agentType, status, result, score | Agent run cache |
| Findings | id (text) | jobId, agentType, severity, title, filePath, findingStatus | Finding cache |
| RemediationTasks | id (text) | jobId, taskNumber, title, priority, status | Task cache |
| Personas | id (text) | name, agentType, scope, teamId, isDefault | Persona cache |
| Directives | id (text) | name, category, scope, teamId, projectId | Directive cache |
| TechDebtItems | id (text) | projectId, category, title, status, effortEstimate | Tech debt cache |
| DependencyScans | id (text) | projectId, totalDependencies, vulnerableCount | Dependency cache |
| DependencyVulnerabilities | id (text) | scanId, dependencyName, severity, cveId | Vulnerability cache |
| HealthSnapshots | id (text) | projectId, healthScore, capturedAt | Health history |
| ComplianceItems | id (text) | jobId, requirement, status, specId | Compliance cache |
| Specifications | id (text) | jobId, name, specType, s3Key | Spec file cache |
| ClonedRepos | repoFullName (text) | localPath, projectId, clonedAt | Cloned repo tracking |
| SyncMetadata | syncTableName (text) | lastSyncAt, etag | Sync timestamps |
| AnthropicModels | id (text) | displayName, modelFamily, contextWindow | Model cache |
| AgentDefinitions | id (text) | name, agentType, isBuiltIn, isEnabled, modelId, maxTurns | Agent config |
| AgentFiles | id (text) | agentDefinitionId, fileName, fileType, contentMd | Agent file content |
| ProjectLocalConfig | projectId (text) | localWorkingDir | Per-project local paths |
| ScribeTabs | id (text) | title, filePath, content, language, isDirty | Editor tabs |
| ScribeSettings | key (text) | value (JSON) | Editor settings |

**Database singleton:** `lib/database/database.dart` — `CodeOpsDatabase` class with lazy singleton. `clearAllTables()` method used during logout.

### Cloud-Synced Models (22 Model Files)

**Serialization approaches:**
- **json_serializable** (48 classes): Server-synced models with generated `.g.dart` files
- **Plain Dart** (50+ classes): UI-only models with custom `toJson()`/`fromJson()`
- **Custom enum converters** (35 enums): Companion `JsonConverter` classes for SCREAMING_SNAKE_CASE

Key model files and their classes (see OpenAPI spec for full field-level detail):

| File | Classes | Serialization |
|---|---|---|
| `user.dart` | User | json_serializable |
| `team.dart` | Team, TeamMember, Invitation | json_serializable |
| `project.dart` | Project | json_serializable |
| `qa_job.dart` | QaJob, JobSummary | json_serializable |
| `agent_run.dart` | AgentRun, BugInvestigation | json_serializable |
| `finding.dart` | Finding | json_serializable |
| `remediation_task.dart` | RemediationTask | json_serializable |
| `persona.dart` | Persona | json_serializable |
| `directive.dart` | Directive | json_serializable |
| `tech_debt_item.dart` | TechDebtItem | json_serializable |
| `health_snapshot.dart` | HealthSnapshot, TeamMetrics, ProjectMetrics, HealthSchedule | json_serializable |
| `compliance_item.dart` | ComplianceItem | json_serializable |
| `specification.dart` | Specification | json_serializable |
| `dependency_scan.dart` | DependencyScan, DependencyVulnerability | json_serializable |
| `jira_models.dart` | JiraIssue, JiraSearchResult, JiraUser, JiraStatus, + 15 more | json_serializable |
| `vault_models.dart` | SecretResponse, AccessPolicyResponse, TransitKeyResponse, + 12 more | json_serializable |
| `vault_enums.dart` | SecretType, SealStatus, PolicyPermission, BindingType, RotationStrategy, LeaseStatus | Custom converters |
| `vcs_models.dart` | VcsRepository, VcsBranch, VcsPullRequest, VcsCommit, + 15 more | Plain Dart (GitHub API factories) |
| `agent_progress.dart` | AgentProgress | Plain Dart |
| `scribe_models.dart` | ScribeTab, ScribeSettings | Plain Dart |
| `anthropic_model_info.dart` | AnthropicModelInfo | json_serializable |
| `enums.dart` | 25+ enums (AgentType, JobMode, JobStatus, Severity, etc.) | Custom converters |

---

## 7. Enum Definitions

**File:** `lib/models/enums.dart`

All enums use SCREAMING_SNAKE_CASE JSON representation. Each provides `toJson()`, `fromJson(String)`, `displayName`, and a companion `JsonConverter`.

| Enum | Values | Used By |
|---|---|---|
| AgentType | SECURITY, CODE_QUALITY, BUILD_HEALTH, COMPLETENESS, API_CONTRACT, TEST_COVERAGE, UI_UX, DOCUMENTATION, DATABASE, PERFORMANCE, DEPENDENCY, ARCHITECTURE | AgentRun.agentType, Finding.agentType, Persona.agentType, AgentDefinitions.agentType |
| JobMode | FULL_AUDIT, TARGETED, COMPLIANCE, BUG_INVESTIGATION | QaJob.mode |
| JobStatus | PENDING, RUNNING, COMPLETED, FAILED, CANCELLED | QaJob.status |
| JobResult | PASS, WARN, FAIL | QaJob.overallResult |
| AgentStatus | PENDING, RUNNING, COMPLETED, FAILED, TIMED_OUT | AgentRun.status |
| AgentResult | PASS, WARN, FAIL | AgentRun.result |
| Severity | CRITICAL, HIGH, MEDIUM, LOW | Finding.severity |
| FindingStatus | OPEN, ACKNOWLEDGED, FALSE_POSITIVE, RESOLVED | Finding.findingStatus |
| Priority | P0, P1, P2, P3 | RemediationTask.priority |
| TaskStatus | PENDING, ASSIGNED, EXPORTED, JIRA_CREATED, COMPLETED | RemediationTask.status |
| Scope | SYSTEM, TEAM, USER | Persona.scope, Directive.scope |
| TeamRole | OWNER, ADMIN, LEAD, MEMBER | TeamMember.role, Invitation.role |
| InvitationStatus | PENDING, ACCEPTED, DECLINED, EXPIRED, CANCELLED | Invitation.status |
| DebtCategory | ARCHITECTURE, CODE_SMELL, DEPENDENCY, DOCUMENTATION, PERFORMANCE, SECURITY, TEST_COVERAGE | TechDebtItem.category |
| DebtStatus | IDENTIFIED, PLANNED, IN_PROGRESS, RESOLVED | TechDebtItem.status |
| Effort | TRIVIAL, MINOR, MODERATE, MAJOR, MASSIVE | TechDebtItem.effortEstimate |
| BusinessImpact | LOW, MEDIUM, HIGH, CRITICAL | TechDebtItem.businessImpact |
| ComplianceStatus | COMPLIANT, NON_COMPLIANT, PARTIAL, NOT_ASSESSED | ComplianceItem.status |
| SpecType | OPENAPI, REQUIREMENTS, ARCHITECTURE, POLICY, CUSTOM | Specification.specType |
| VulnerabilityStatus | OPEN, UPDATING, SUPPRESSED, RESOLVED | DependencyVulnerability.status |
| DirectiveCategory | ARCHITECTURE, STANDARDS, CONVENTIONS, CONTEXT, OTHER | Directive.category |
| GitHubAuthType | PAT, OAUTH, SSH | VcsCredentials.authType |

**File:** `lib/models/vault_enums.dart`

| Enum | Values | Used By |
|---|---|---|
| SecretType | STATIC, DYNAMIC, REFERENCE | SecretResponse.secretType |
| SealStatus | SEALED, UNSEALED, UNSEALING | SealStatusResponse.status |
| PolicyPermission | READ, WRITE, DELETE, LIST, ROTATE | AccessPolicyResponse.permissions |
| BindingType | USER, TEAM, SERVICE | PolicyBindingResponse.bindingType |
| RotationStrategy | RANDOM_GENERATE, EXTERNAL_API, CUSTOM_SCRIPT | RotationPolicyResponse.strategy |
| LeaseStatus | ACTIVE, EXPIRED, REVOKED | DynamicLeaseResponse.status |

---

## 8. Repository Layer (Drift Database)

**File:** `lib/database/database.dart`

No JPA repositories — this is a Flutter app using Drift (SQLite). The `CodeOpsDatabase` class extends the generated `_$CodeOpsDatabase` and provides:

- **Schema version:** 7
- **Migration strategy:** `onCreate` + `onUpgrade` (v1→v7 incremental migrations)
- **`clearAllTables()`** — Deletes all rows on logout
- **Default constructor:** `CodeOpsDatabase.defaults()` — Platform-specific SQLite file location
- **Singleton access:** `database` getter returns lazy singleton

Data access is primarily through Riverpod providers that call cloud API services, with Drift used for offline caching via `SyncService`.

---

## 9. Service Layer

### 9.1 Cloud API Services (21 files, 218+ methods)

**Base:** `lib/services/cloud/api_client.dart`
- Dio-based HTTP client targeting `http://localhost:8090/api/v1`
- Interceptors: Auth (JWT Bearer), Token Refresh (401→POST /auth/refresh), Error Mapping, Logging
- Timeouts: connect=15s, receive=30s, send=15s

**Vault Base:** `lib/services/cloud/vault_api_client.dart`
- Separate Dio targeting `http://localhost:8097/api/v1/vault`
- Same JWT tokens, refresh via CodeOps-Server endpoint
- Same interceptor pattern

**API Service Classes (each depends on ApiClient or VaultApiClient):**

| Service | File | Methods | Covers |
|---|---|---|---|
| AdminApi | admin_api.dart | 9 | Team admin, activity logs, system health |
| AnthropicApiService | anthropic_api_service.dart | 2 | Model listing, API key validation |
| ComplianceApi | compliance_api.dart | 5 | Compliance items CRUD |
| DependencyApi | dependency_api.dart | 6 | Scans, vulnerabilities, status updates |
| DirectiveApi | directive_api.dart | 7 | Directive CRUD, filtering by scope/project |
| FindingApi | finding_api.dart | 8 | Finding CRUD, batch create, severity counts |
| HealthMonitorApi | health_monitor_api.dart | 6 | Snapshots, schedules CRUD |
| IntegrationApi | integration_api.dart | 8 | GitHub/Jira connection management |
| JobApi | job_api.dart | 14 | Jobs, agent runs, bug investigations |
| MetricsApi | metrics_api.dart | 3 | Team/project metrics, health trends |
| PersonaApi | persona_api.dart | 11 | Persona CRUD, defaults, system/team/user scoping |
| ProjectApi | project_api.dart | 8 | Project CRUD, archive/unarchive |
| ReportApi | report_api.dart | 5 | Upload/download reports and specs (S3) |
| TaskApi | task_api.dart | 6 | Remediation task CRUD, batch create |
| TeamApi | team_api.dart | 12 | Team CRUD, members, invitations |
| TechDebtApi | tech_debt_api.dart | 9 | Tech debt items, batch create, summary |
| UserApi | user_api.dart | 6 | User profile, search, activate/deactivate |
| VaultApi | vault_api.dart | 67 | Secrets(19), Policies(12), Rotation(8), Transit(12), Dynamic(7), Seal(5), Audit(3) |

### 9.2 Auth Services

**`auth_service.dart`** — `AuthService`
- Dependencies: ApiClient, SecureStorageService, CodeOpsDatabase
- State: `AuthState` enum (unknown, authenticated, unauthenticated)
- Stream-based: `authStateStream` broadcasts state changes
- Methods: `login()`, `register()`, `logout()`, `tryAutoLogin()`, `refreshToken()`, `changePassword()`
- Login: POST /auth/login → stores JWT + refresh token + userId in secure storage
- Logout: clears secure storage, clears all database tables, emits unauthenticated
- Auto-login: reads stored tokens, validates via GET /users/me, refreshes if 401

**`secure_storage.dart`** — `SecureStorageService`
- Wraps `flutter_secure_storage` for encrypted key-value storage
- Methods: get/set/delete for auth tokens, refresh tokens, user ID, team ID, GitHub PAT, Anthropic API key, remembered credentials
- `clearAll()` removes all stored values

### 9.3 Agent Services

**`agent_config_service.dart`** — `AgentConfigService`
- Dependencies: CodeOpsDatabase
- Seeds 13 built-in agents from `assets/personas/*.md` files on first launch
- CRUD operations for agent definitions and agent files (Drift)
- Caches Anthropic model list in local database

**`persona_manager.dart`** — `PersonaManager`
- Dependencies: PersonaApi, AgentConfigService
- Resolves persona content for agent dispatch (team default → system default → built-in fallback)

**`report_parser.dart`** — `ReportParser`
- Parses Claude Code JSON output into structured findings (ParsedReport, ParsedFinding)
- Extracts severity, file path, line numbers, recommendations from agent output

**`task_generator.dart`** — `TaskGenerator`
- Generates remediation tasks from findings with prioritization
- Groups findings by file, generates fix prompts

### 9.4 Orchestration Services

**`job_orchestrator.dart`** — `JobOrchestrator` (core workflow engine)
- Dependencies: AgentDispatcher, AgentMonitor, VeraManager, ProgressAggregator, ReportParser, JobApi, FindingApi, ReportApi
- 10-step lifecycle: create job → create agent runs → dispatch agents → parse reports → consolidate (Vera) → upload findings → upload summary → update job
- Stream-JSON event parsing for real-time progress
- `lifecycleStream` broadcasts JobLifecycleEvent hierarchy

**`agent_dispatcher.dart`** — `AgentDispatcher`
- Dependencies: ProcessManager, PersonaManager, ClaudeCodeDetector
- Spawns Claude Code CLI as subprocesses: `claude --print --output-format stream-json --max-turns N --model MODEL -p PROMPT`
- Semaphore-based concurrency control (configurable max concurrent agents)
- Per-agent model/timeout/maxTurns overrides

**`agent_monitor.dart`** — `AgentMonitor`
- Monitors running agent processes with output collection and timeout enforcement
- Concurrent stdout/stderr buffering with broadcast streams

**`vera_manager.dart`** — `VeraManager`
- Consolidates multi-agent reports into unified output
- Finding deduplication: same filePath + line threshold + title similarity ≥ 0.8 (Levenshtein)
- Weighted health scoring: Security/Architecture 1.5x, others 1.0x

**`progress_aggregator.dart`** — `ProgressAggregator`
- Real-time progress snapshots via broadcast stream
- Tracks agent phases: queued → running → parsing → completed/failed/timedOut

**`bug_investigation_orchestrator.dart`** — `BugInvestigationOrchestrator`
- Launches bug investigation jobs from Jira issues
- Converts Jira ADF content to markdown for agent consumption

### 9.5 VCS Services

**`github_provider.dart`** — `GitHubProvider` implements `VcsProvider`
- Separate Dio targeting `https://api.github.com`
- PAT Bearer auth, rate limit tracking from response headers
- Methods: authenticate, getOrganizations (user as pseudo-org), getRepositories, searchRepositories, getBranches, getPullRequests, createPullRequest, mergePullRequest, getCommitHistory, getWorkflowRuns, getReleases, getReadmeContent

**`git_service.dart`** — `GitService`
- Local git CLI wrapper via subprocess execution (25+ commands)
- All commands use `GIT_TERMINAL_PROMPT=0` to prevent interactive hangs
- Methods: clone (with progress), pull, push, fetch, checkout, branch, status (porcelain v2), diff, log (JSON), commit, merge, blame, stash operations, tag operations

**`repo_manager.dart`** — `RepoManager`
- Tracks cloned repositories in Drift database
- Default directory: `~/CodeOps/repos/`
- Platform-specific file manager opening

**`vcs_provider.dart`** — Abstract `VcsProvider` interface

### 9.6 Jira Services

**`jira_service.dart`** — `JiraService`
- Separate Dio instance for Jira Cloud REST API v3
- Basic Auth via base64 `email:apiToken`
- Methods: testConnection, searchIssues (JQL), getIssue, getComments, postComment, createIssue, createSubTask, createIssuesBulk, updateIssue, getTransitions, transitionIssue, getProjects, getSprints, getIssueTypes, searchUsers, getPriorities
- Auto-retry on 429 rate limit

**`jira_mapper.dart`** — `JiraMapper`
- Converts between CodeOps and Jira data models
- ADF (Atlassian Document Format) ↔ Markdown conversion
- Status/priority color mapping

### 9.7 Analysis Services

**`health_calculator.dart`** — Composite health scoring from findings
**`dependency_scanner.dart`** — Dependency health analysis
**`tech_debt_tracker.dart`** — Tech debt tracking and trend analysis

### 9.8 Data Services

**`sync_service.dart`** — `SyncService`
- Syncs cloud data to local Drift database for offline access
- Table-by-table sync with `SyncMetadata` timestamps

**`scribe_persistence_service.dart`** — `ScribePersistenceService`
- Persists Scribe editor tabs and settings in Drift

### 9.9 Platform Services

**`claude_code_detector.dart`** — `ClaudeCodeDetector`
- Detects Claude Code CLI installation via `which`/`where.exe` + fallback paths
- Version validation (minimum version check)

**`process_manager.dart`** — `ProcessManager`
- Low-level subprocess lifecycle with timeouts
- `ManagedProcess` wraps Process with broadcast stdout/stderr streams

### 9.10 Integration Services

**`export_service.dart`** — `ExportService`
- Multi-format export: Markdown, PDF, ZIP, CSV
- Used for findings, reports, tasks

### 9.11 Logging Services

**`log_service.dart`** — `LogService` (singleton)
- Structured logging: `[HH:MM:SS.mmm] [LEVEL] [tag] message`
- ANSI colors in debug, file output in release
- File rotation: daily, 7-day retention
- Global convenience: `final log = LogService();`

**`log_config.dart`** — Environment-aware defaults (debug vs release)

---

## 10. Security Architecture

### Authentication Flow

- **JWT-based** authentication via CodeOps-Server (`POST /api/v1/auth/login`)
- Login returns `accessToken` + `refreshToken`
- Tokens stored in `flutter_secure_storage` (encrypted platform keychain)
- `ApiClient` auth interceptor attaches `Authorization: Bearer <token>` to every request
- Token refresh interceptor: on 401, calls `POST /api/v1/auth/refresh` with refresh token, retries original request
- Logout: clears secure storage, clears all Drift tables, emits `unauthenticated` state

### Authorization Model

- **Server-enforced** — Client does not enforce authorization; all access control is on CodeOps-Server
- **Roles:** OWNER, ADMIN, LEAD, MEMBER (TeamRole enum)
- Client hides UI elements based on role (e.g., Admin Hub only visible to OWNER/ADMIN in NavigationShell)
- No client-side route guards beyond auth redirect

### GoRouter Auth Redirect

```
Unauthenticated + not on /login → redirect to /login
Authenticated + on /login → redirect to /
```

### Credential Storage

| Key | Storage | Purpose |
|---|---|---|
| auth_token | SecureStorage | JWT access token |
| refresh_token | SecureStorage | JWT refresh token |
| current_user_id | SecureStorage | Current user UUID |
| selected_team_id | SecureStorage | Active team UUID |
| github_pat | SecureStorage | GitHub Personal Access Token |
| codeops_anthropic_api_key | SecureStorage | Anthropic API key |
| jira_api_token_{id} | SecureStorage | Per-connection Jira API tokens |
| remember_me | SecureStorage | Remember me flag |
| remembered_email | SecureStorage | Remembered email |
| remembered_password | SecureStorage | Remembered password |

### Password Policy

- Minimal during development (server-enforced)
- Client-side: login form requires non-empty email + password
- Registration form: requires confirm password match

### CORS / Rate Limiting

- N/A for desktop client — no CORS concerns
- GitHub API rate limit tracked via `X-RateLimit-Remaining` header, warns at <100
- Jira auto-retry on 429 with retry-after header

---

## 11. Notification / Messaging Layer

- **No direct email/webhook sending** — This is a client application
- **Microsoft Teams webhook URL** stored on Team model (`teamsWebhookUrl`) but sent to CodeOps-Server for server-side dispatch
- **Jira integration:** Client creates issues/comments directly via Jira Cloud REST API
- **No message broker** — Client communicates only via HTTP APIs

---

## 12. Error Handling

**File:** `lib/services/cloud/api_exceptions.dart`

Sealed exception hierarchy mapping HTTP status codes:

| Exception Type | HTTP Status | User-Facing Message |
|---|---|---|
| BadRequestException | 400 | Server message or "Bad request" |
| UnauthorizedException | 401 | "Session expired" |
| ForbiddenException | 403 | "Access denied" |
| NotFoundException | 404 | "Not found" |
| ConflictException | 409 | Server message or "Conflict" |
| ValidationException | 422 | Server message or "Validation error" |
| RateLimitException | 429 | "Rate limited" |
| TimeoutException | timeout | "Request timed out" |
| NetworkException | connection | "No internet connection" |
| ServerException | 500+ | "Server error" |

**Error mapping** happens in `ApiClient` and `VaultApiClient` error interceptors. All exceptions extend `ApiException` with `message` and optional `statusCode`.

**UI Error Display:** `ErrorPanel.fromException()` maps exceptions to user-friendly titles and messages. Retry callback optional.

**GitHub/Jira error mapping:** Separate error handling in `GitHubProvider` and `JiraService` with similar patterns (status code → typed exception).

---

## 13. Test Coverage

```
=== TEST INVENTORY ===
Unit test files:         235
Integration test files:  5 (integration_test/)
Total test files:        240

--- Test Method Counts ---
Unit test():             1,802
Widget testWidgets():    829
Total:                   2,631
Test groups:             631
```

**Test framework:** flutter_test + mocktail 1.0.4 (NOT Mockito)
**Mock classes:** 58 custom mock definitions
**Test configuration:** No special test config files needed (no database/server in tests)

**Test breakdown by category:**

| Category | Files | Notes |
|---|---|---|
| Models | 22 | JSON serialization round-trips |
| Providers | 22 | Riverpod ProviderContainer tests |
| Pages | 27 | Widget tests with provider overrides |
| Services | 47 | Unit tests with mocktail mocks |
| Widgets | 107 | Widget tests with ProviderScope overrides |
| Database | 2 | Drift table tests |
| Router | 1 | Route configuration tests |
| Theme | 2 | Color/typography tests |
| Utils | 3 | Date/file/string utility tests |
| Integration | 6 | End-to-end flows (1 in test/, 5 in integration_test/) |

**Integration test flows:** persona, health_dashboard, tech_debt, dependency, directive, compliance

---

## 14. Cross-Cutting Patterns & Conventions

### Package Structure
Feature-based organization: `models/`, `services/`, `providers/`, `pages/`, `widgets/`. Services further grouped by domain (`cloud/`, `vcs/`, `orchestration/`, etc.).

### State Management
Riverpod exclusively. Provider types: `Provider` (singletons), `StateProvider` (mutable UI state), `FutureProvider` (async data), `FutureProvider.family` (parameterized), `StateNotifierProvider` (complex state machines).

### Naming Conventions
- Providers: `{entity}{Type}Provider` (e.g., `teamProjectsProvider`, `selectedProjectIdProvider`)
- API services: `{Entity}Api` (e.g., `ProjectApi`, `VaultApi`)
- Pages: `{Feature}Page` (e.g., `ProjectsPage`, `VaultDashboardPage`)
- Widgets: Descriptive names (e.g., `HealthScoreGauge`, `SeverityFilterBar`)
- Routes: lowercase kebab-case paths (`/vault/secrets`, `/tech-debt`)

### Validation Pattern
- Client-side: form-level validation in page widgets (non-empty, email format, password match)
- Server-side: full validation enforced by CodeOps-Server; client displays server error messages

### Constants
Centralized in `lib/utils/constants.dart` — `AppConstants` class with 80+ static constants. All API URLs, timeouts, limits, storage keys, and thresholds defined here.

### Error Handling Pattern
API calls wrapped in try/catch at provider or page level. `ApiException` subtypes caught and displayed via `ErrorPanel.fromException()` or snackbar notifications.

### Pagination Pattern
`PageResponse<T>` model with `content`, `totalElements`, `totalPages`, `number`, `size`. Providers accept `({String id, int page})` record parameters.

### Documentation Comments
94.6% of source files have `///` documentation comments. 6,019 total doc comment lines across 280 of 296 files.

---

## 15. Known Issues, TODOs, and Technical Debt

No `TODO`, `FIXME`, `HACK`, `XXX`, or `WORKAROUND` comments found in `lib/` source files.

The only matches are feature references (agent type descriptions mentioning "TODOs" as a concept, not code markers).

---

## 16. OpenAPI Specification

**See:** `CodeOps-Client-OpenAPI.yaml`

Since CodeOps-Client is a Flutter desktop application (not a server), the OpenAPI spec documents the **APIs it consumes** from CodeOps-Server and CodeOps-Vault. This serves as the API contract reference for understanding what endpoints the client calls.

---

## 17. Database — Local Schema

CodeOps-Client uses **Drift (SQLite)** for local offline storage, not PostgreSQL. The schema is defined in `lib/database/tables.dart` and managed by Drift migrations.

**Schema version:** 7
**Migration history:** v1 (initial 16 tables) → v2 (AgentDefinitions, AgentFiles) → v3 (QaJobs.configJson) → v4 (QaJobs.summaryMd/startedByName, Findings.statusChangedBy/statusChangedAt) → v5 (ProjectLocalConfig) → v6 (ScribeTabs, ScribeSettings) → v7 (AnthropicModels)

**23 tables** — see Section 6 for full table listing.

No live database audit needed — schema is code-defined and deterministic.

---

## 18. MESSAGE BROKER DETECTION

No message broker (Kafka, RabbitMQ, SQS/SNS) detected in this project. CodeOps-Client communicates exclusively via HTTP REST APIs.

---

## 19. CACHE DETECTION

No Redis or external caching layer detected in this project. Local SQLite (Drift) serves as the offline data cache, synced from CodeOps-Server via `SyncService`.

---

## 20. ENVIRONMENT VARIABLE INVENTORY

CodeOps-Client is a desktop application with no environment variable configuration. All settings are hardcoded in `lib/utils/constants.dart`:

| Constant | Value | Purpose |
|---|---|---|
| apiBaseUrl | `http://localhost:8090` | CodeOps-Server URL |
| apiPrefix | `/api/v1` | API path prefix |
| vaultApiBaseUrl | `http://localhost:8097` | CodeOps-Vault URL |
| vaultApiPrefix | `/api/v1/vault` | Vault API path prefix |
| anthropicApiBaseUrl | `https://api.anthropic.com` | Anthropic API URL |
| anthropicApiVersion | `2023-06-01` | Anthropic API version |
| defaultClaudeModel | `claude-sonnet-4-20250514` | Default model for UI |
| defaultClaudeModelForDispatch | `claude-sonnet-4-5-20250514` | Default model for agents |
| minClaudeCodeVersion | `1.0.0` | Minimum CLI version |

**Production considerations:** All API URLs are hardcoded for local development. Production deployment would require a configuration mechanism (compile-time constants, config file, or environment variables).

---

## 21. SERVICE DEPENDENCY MAP

CodeOps-Client is a desktop client with outbound HTTP dependencies:

```
CodeOps-Client (Flutter Desktop)
  │
  ├── CodeOps-Server (http://localhost:8090/api/v1/)
  │     ├── Auth: JWT Bearer tokens (login, refresh, logout)
  │     ├── 18 API services: admin, compliance, dependency, directive,
  │     │   finding, health, integration, job, metrics, persona,
  │     │   project, report, task, team, tech-debt, user, anthropic
  │     └── S3 file uploads/downloads via presigned URLs
  │
  ├── CodeOps-Vault (http://localhost:8097/api/v1/vault/)
  │     ├── Auth: Same JWT tokens as CodeOps-Server
  │     └── 67 endpoints: secrets, policies, rotation, transit, dynamic, seal, audit
  │
  ├── GitHub API (https://api.github.com)
  │     ├── Auth: PAT Bearer token
  │     └── Repos, branches, PRs, commits, workflows, releases, README
  │
  ├── Jira Cloud API (https://{instance}.atlassian.net/rest/api/3)
  │     ├── Auth: Basic Auth (email:apiToken)
  │     └── Issues, comments, transitions, projects, sprints, users
  │
  ├── Anthropic API (https://api.anthropic.com)
  │     ├── Auth: API key header
  │     └── Model listing
  │
  └── Claude Code CLI (subprocess)
        ├── Detected via claude_code_detector.dart
        └── Invoked: claude --print --output-format stream-json --max-turns N --model MODEL -p PROMPT
```

**Inbound dependencies:** None — this is a desktop client application.
