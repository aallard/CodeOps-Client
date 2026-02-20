# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-02-20T00:14:32Z
**Branch:** main
**Commit:** ad0e702c10465f516445e0cc92814e3a1ae728d3 CVF-010: Vault Seal & Audit — seal/unseal lifecycle, Shamir shares, audit log with filters
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml

> This audit is the single source of truth for the CodeOps-Client codebase.
> The OpenAPI spec (CodeOps-Client-OpenAPI.yaml) is the source of truth for all outbound API endpoints, request/response DTOs, and API contracts.
> An AI reading this audit + the OpenAPI spec should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:          CodeOps-Client
Repository URL:        (local — ~/Documents/Github/CodeOps-Client)
Primary Language:      Dart / Flutter
SDK Version:           Dart ^3.6.0 / Flutter >=3.27.0
Build Tool:            Flutter CLI + build_runner
Current Branch:        main
Latest Commit Hash:    ad0e702c10465f516445e0cc92814e3a1ae728d3
Latest Commit Message: CVF-010: Vault Seal & Audit — seal/unseal lifecycle, Shamir shares, audit log with filters
Audit Timestamp:       2026-02-20T00:14:32Z
```

---

## 2. Directory Structure

Single-module Flutter desktop application. Source code in `lib/`, tests in `test/` and `integration_test/`.

```
lib/
├── main.dart                    ← Entry point
├── app.dart                     ← Root ConsumerWidget
├── router.dart                  ← GoRouter with 31 routes
├── models/          (22 files)  ← Data models + enums
├── providers/       (25 files)  ← Riverpod state management (~210 providers)
├── services/        (50 files)  ← Business logic + API clients
│   ├── agent/       (4 files)   ← Agent config, persona manager, report parser, task generator
│   ├── analysis/    (3 files)   ← Dependency scanner, health calculator, tech debt tracker
│   ├── auth/        (2 files)   ← Auth service, secure storage
│   ├── cloud/       (21 files)  ← API clients (Dio-based)
│   ├── data/        (2 files)   ← Scribe persistence, sync service
│   ├── integration/ (1 file)    ← Export service
│   ├── jira/        (2 files)   ← Jira mapper, Jira service
│   ├── logging/     (3 files)   ← Log service, config, levels
│   ├── orchestration/ (6 files) ← Job orchestrator, agent dispatcher/monitor, Vera, progress
│   ├── platform/    (2 files)   ← Claude Code detector, process manager
│   └── vcs/         (4 files)   ← Git service, GitHub provider, repo manager, VCS interface
├── pages/           (32 files)  ← Full-page route widgets
├── widgets/         (138 files) ← Reusable UI components
├── database/        (2 files)   ← Drift SQLite database
├── theme/           (3 files)   ← Colors, typography, theme
└── utils/           (4 files)   ← Constants, date/file/string utils
test/                (235 files) ← Unit tests
integration_test/    (5 files)   ← Integration tests
```

**File counts:** 279 non-generated Dart files in `lib/`, 17 generated `.g.dart` files, 240 test files total.

---

## 3. Build & Dependency Manifest

**File:** `pubspec.yaml`

### Runtime Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter | sdk | UI framework |
| flutter_riverpod | ^2.6.1 | State management |
| go_router | ^14.6.2 | Declarative routing (31 routes) |
| dio | ^5.7.0 | HTTP client for API calls |
| drift | ^2.22.1 | SQLite ORM (local database) |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native bindings |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| shared_preferences | ^2.3.4 | Persistent key-value storage (tokens, settings) |
| flutter_markdown | ^0.7.4+3 | Markdown rendering |
| fl_chart | ^0.70.2 | Charts and graphs |
| file_picker | ^8.1.6 | File selection dialogs |
| path_provider | ^2.1.5 | Platform-specific directories |
| path | ^1.9.1 | Cross-platform path manipulation |
| window_manager | ^0.4.3 | Desktop window control |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.19.0 | Date/number formatting |
| url_launcher | ^6.3.1 | Opening URLs in browser |
| collection | ^1.19.1 | Enhanced collection utilities |

### Dev Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter_test | sdk | Test framework |
| integration_test | sdk | Integration test framework |
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.22.1 | Drift code generator |
| json_serializable | ^6.9.0 | JSON serialization generator |
| freezed | ^2.5.7 | Immutable class generator (available but not used) |
| freezed_annotation | ^2.4.4 | Freezed annotations |
| mocktail | ^1.0.4 | Test mocking framework |

### Build Commands

```
Build:     flutter build macos
Test:      flutter test
Run:       flutter run -d macos
Generate:  dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Configuration & Infrastructure Summary

- **`lib/utils/constants.dart`** — `AppConstants` class. API base URLs: CodeOps-Server `http://localhost:8090` (prefix `/api/v1/`), CodeOps-Vault `http://localhost:8097` (prefix `/api/v1/vault/`), Anthropic `https://api.anthropic.com`. All limits, storage keys, agent defaults, health scoring weights, and UI constants. Hardcoded to localhost — no environment variable support.
- **`lib/services/logging/log_config.dart`** — Debug mode: level=debug, file logging off, console colors on. Release mode: level=info, file logging on (daily rotation, 7-day retention), console colors off. Log directory: `<cwd>/logs` (debug) or `<appSupportDir>/logs` (release).
- **`analysis_options.yaml`** — Extends `flutter_lints`. No custom overrides.
- **No `.env` file** — All config is in `constants.dart`.
- **No Docker config** — Pure desktop app, no containerization.
- **No CI/CD** — No `.github/workflows`, Jenkinsfile, or pipeline config detected.

**Connection map:**
```
Database:        SQLite (local, via Drift) — file at app support directory
Cache:           None
Message Broker:  None (client-side)
External APIs:   CodeOps-Server (localhost:8090), CodeOps-Vault (localhost:8097), Anthropic API, GitHub API (api.github.com), Jira API (user-configured URL)
Cloud Services:  S3 (via CodeOps-Server proxy for report upload/download)
```

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart`

Startup sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LogConfig.initialize()` — sets log level, file logging, log directory
3. `windowManager.ensureInitialized()` — configures desktop window (1440x900 default, 1024x700 minimum)
4. `windowManager.waitUntilReadyToShow()` — sets window title "CodeOps", shows and focuses
5. `runApp(ProviderScope(child: CodeOpsApp()))` — launches Riverpod + app

**Root widget (`app.dart`):** `CodeOpsApp` is a `ConsumerWidget` that:
- Applies `AppTheme.darkTheme`
- Bridges `authStateProvider` stream to `authNotifier` for GoRouter refresh
- On authentication: auto-selects first team, seeds built-in agent definitions, refreshes Anthropic models list

**No scheduled tasks or background jobs.** Health check is via CodeOps-Server's `/auth/login` endpoint (Actuator endpoints are secured).

---

## 6. Entity / Data Model Layer

### Drift Database (SQLite)

**File:** `lib/database/database.dart`
**Schema Version:** 7
**20 tables** — local cache of server data plus client-only tables.

#### Core Tables

**Projects** — Local cache of projects.
- PK: `id` (Text)
- Fields: teamId, name, description, githubConnectionId, repoUrl, repoFullName, defaultBranch, jiraConnectionId, jiraProjectKey, jiraDefaultIssueType, jiraLabels, jiraComponent, techStack, healthScore (Int), lastAuditAt, isArchived (Bool, default false), createdAt, updatedAt

**QaJobs** — Local cache of QA jobs.
- PK: `id` (Text)
- Fields: projectId, mode, status, name, branch, configJson, summaryMd, overallResult, healthScore, totalFindings, criticalCount, highCount, mediumCount, lowCount, jiraTicketKey, startedBy, startedByName (added v4), startedAt, completedAt, createdAt

**AgentRuns** — Local cache of agent runs.
- PK: `id` (Text)
- Fields: jobId, agentType, status, result, reportS3Key, score, findingsCount, criticalCount, highCount, startedAt, completedAt

**Findings** — Local cache of findings.
- PK: `id` (Text)
- Fields: jobId, agentType, severity, title, description, filePath, lineNumber, recommendation, evidence, effortEstimate, debtCategory, findingStatus, statusChangedBy (added v4), statusChangedAt (added v4), createdAt

**RemediationTasks** — Local cache of remediation tasks.
- PK: `id` (Text)
- Fields: jobId, taskNumber (Int), title, description, promptMd, priority, status, assignedTo, assignedToName, jiraKey, createdAt

**Personas** — Local cache of personas.
- PK: `id` (Text)
- Fields: name, agentType, description, contentMd, scope, teamId, createdBy, createdByName, isDefault (Bool, default false), version (Int), createdAt, updatedAt

**Directives** — Local cache of directives.
- PK: `id` (Text)
- Fields: name, description, contentMd, category, scope, teamId, projectId, createdBy, createdByName, version (Int), createdAt, updatedAt

**TechDebtItems** — Local cache of tech debt items.
- PK: `id` (Text)
- Fields: projectId, category, title, description, filePath, effortEstimate, businessImpact, status, firstDetectedJobId, resolvedJobId, createdAt, updatedAt

**DependencyScans** — Local cache of dependency scans.
- PK: `id` (Text)
- Fields: projectId, jobId, manifestFile, totalDependencies (Int), outdatedCount (Int), vulnerableCount (Int), createdAt

**DependencyVulnerabilities** — Local cache of vulnerabilities.
- PK: `id` (Text)
- Fields: scanId, dependencyName, currentVersion, fixedVersion, cveId, severity, description, status, createdAt

**HealthSnapshots** — Local cache of health snapshots.
- PK: `id` (Text)
- Fields: projectId, jobId, healthScore (Int), findingsBySeverity (Text, JSON), techDebtScore (Int), dependencyScore (Int), testCoveragePercent (Real), capturedAt

**ComplianceItems** — Local cache of compliance items.
- PK: `id` (Text)
- Fields: jobId, requirement, specId, specName, status, evidence, agentType, notes, createdAt

**Specifications** — Local cache of specifications.
- PK: `id` (Text)
- Fields: jobId, name, specType, s3Key, createdAt

#### Infrastructure Tables

**ClonedRepos** (schema v2) — Registry of cloned git repos.
- PK: `repoFullName` (Text)
- Fields: localPath, projectId, clonedAt, lastAccessedAt

**SyncMetadata** — Tracks last sync time per table.
- PK: `syncTableName` (Text)
- Fields: lastSyncAt, etag

**AnthropicModels** (schema v5) — Cached Anthropic model metadata.
- PK: `id` (Text)
- Fields: displayName, modelFamily, contextWindow (Int), maxOutputTokens (Int), fetchedAt

**AgentDefinitions** (schema v5) — Per-agent configuration.
- PK: `id` (Text)
- Fields: name, agentType, isQaManager (Bool, default false), isBuiltIn (Bool, default true), isEnabled (Bool, default true), modelId, temperature (Real, default 0.0), maxRetries (Int, default 1), timeoutMinutes (Int), maxTurns (Int, default 50), systemPromptOverride, description, sortOrder (Int, default 0), createdAt, updatedAt

**AgentFiles** (schema v5) — Files attached to agent definitions.
- PK: `id` (Text)
- Fields: agentDefinitionId, fileName, fileType, contentMd, filePath, sortOrder (Int, default 0), createdAt, updatedAt

**ProjectLocalConfig** (schema v6) — Per-machine project config.
- PK: `projectId` (Text)
- Fields: localWorkingDir

**ScribeTabs** (schema v7) — Persisted Scribe editor tabs.
- PK: `id` (Text)
- Fields: title, filePath, content, language, isDirty (Bool, default false), cursorLine (Int, default 0), cursorColumn (Int, default 0), scrollOffset (Real, default 0.0), displayOrder (Int), createdAt, lastModifiedAt

**ScribeSettings** (schema v7) — Scribe editor settings (key-value).
- PK: `key` (Text)
- Fields: value
- Custom table name: `'scribe_settings'`

**Migration strategy:** `onUpgrade` callback with version-specific handlers (v1→v2, v2→v3, v3→v4, v4→v5, v5→v6, v6→v7). Each migration adds tables or columns.

---

## 7. Enum Definitions

**File:** `lib/models/enums.dart` — 24 enums with `toJson()`, `static fromJson()`, `displayName`, and companion `JsonConverter` classes.

```
=== AgentType ===
Values: security, codeQuality, buildHealth, completeness, apiContract, testCoverage, uiUx, documentation, database, performance, dependency, architecture
Used By: AgentRun.agentType, Persona.agentType, Finding.agentType, AgentDefinition.agentType

=== Severity ===
Values: critical, high, medium, low
Used By: Finding.severity, DependencyVulnerability.severity

=== JobStatus ===
Values: pending, running, completed, failed, cancelled
Used By: QaJob.status, AgentRun.status

=== JobMode ===
Values: fullAudit, quickScan, bugInvestigate, complianceCheck
Used By: QaJob.mode

=== JobResult ===
Values: pass, warn, fail
Used By: QaJob.overallResult, AgentRun.result

=== TaskStatus ===
Values: pending, assigned, exported, jiraCreated, completed
Used By: RemediationTask.status

=== Priority ===
Values: critical, high, medium, low
Used By: RemediationTask.priority

=== Scope ===
Values: system, team, user
Used By: Persona.scope, Directive.scope

=== TeamRole ===
Values: owner, lead, member, viewer
Used By: TeamMember.role, Invitation.role

=== InvitationStatus ===
Values: pending, accepted, declined, expired, cancelled
Used By: Invitation.status

=== FindingStatus ===
Values: open, accepted, falsePositive, deferred, fixed
Used By: Finding.findingStatus

=== DebtCategory ===
Values: codeSmell, designDebt, testDebt, documentationDebt, dependencyDebt, infrastructureDebt
Used By: TechDebtItem.category

=== Effort ===
Values: trivial, small, medium, large, epic
Used By: TechDebtItem.effortEstimate

=== BusinessImpact ===
Values: critical, high, medium, low
Used By: TechDebtItem.businessImpact

=== DebtStatus ===
Values: identified, planned, inProgress, resolved
Used By: TechDebtItem.status

=== DirectiveCategory ===
Values: architecture, standards, conventions, context, other
Used By: Directive.category

=== ComplianceStatus ===
Values: compliant, nonCompliant, partiallyCompliant, notAssessed
Used By: ComplianceItem.status

=== SpecType ===
Values: requirements, design, testPlan, api, other
Used By: Specification.specType

=== VulnerabilityStatus ===
Values: open, updating, suppressed, resolved
Used By: DependencyVulnerability.status

=== GitHubAuthType ===
Values: pat, oauth, app
Used By: VcsCredentials.authType

=== SyncState ===
Values: idle, syncing, success, error
Used By: projectSyncStateProvider

=== PageResponse<T> ===
(Generic wrapper, not an enum — but widely used)
Fields: content (List<T>), totalElements (int), totalPages (int), number (int), size (int)
```

**File:** `lib/models/vault_enums.dart` — 6 enums for Vault domain.

```
SecretType: static_, dynamic_, reference
SealStatus: sealed, unsealed, unsealing
PolicyPermission: read, write, delete, list, rotate
BindingType: user, team, service
RotationStrategy: randomGenerate, externalApi, customScript
LeaseStatus: active, expired, revoked
```

**File:** `lib/models/vcs_models.dart` — 2 enums.

```
FileChangeType: added, modified, deleted, renamed, copied, untracked
DiffLineType: context, addition, deletion, header
```

---

## 8. Repository Layer

Not applicable (client app). Local data access is via Drift database direct queries. No repository interface pattern — providers query `CodeOpsDatabase` directly or via service classes.

---

## 9. Service Layer

### Authentication Services

**=== AuthService ===**
File: `lib/services/auth/auth_service.dart`
Dependencies: ApiClient, SecureStorageService, CodeOpsDatabase

Methods:
- `login(String email, String password) → Future<User>` — POST `/auth/login`, stores tokens + userId, broadcasts `authenticated` state
- `register(String email, String password, String displayName) → Future<User>` — POST `/auth/register`, stores tokens + userId
- `refreshToken() → Future<void>` — POST `/auth/refresh` with refresh token, updates stored tokens
- `changePassword(String currentPassword, String newPassword) → Future<void>` — POST `/auth/change-password`
- `logout() → Future<void>` — Clears stored tokens (preserves remember-me), broadcasts `unauthenticated`
- `tryAutoLogin() → Future<bool>` — Checks stored tokens, validates via `/users/me`, refreshes if 401
- `get authStateStream → Stream<AuthState>` — Broadcast stream

**=== SecureStorageService ===**
File: `lib/services/auth/secure_storage.dart`
Dependencies: SharedPreferences

SharedPreferences-backed storage (replaced flutter_secure_storage to avoid macOS Keychain dialogs). `clearAll()` preserves remember-me credentials and Anthropic API key across logout.

### Cloud API Services (21 files)

All cloud API services follow the same pattern: constructor takes `ApiClient` (or `VaultApiClient`), all methods delegate HTTP calls through the client, zero local error handling — errors handled by interceptor chain.

**See `CodeOps-Client-OpenAPI.yaml` for complete endpoint catalog.**

Key services and their method counts:
- `AdminApi` — 4 methods (team audit log, system health, system stats, all users)
- `ComplianceApi` — 5 methods (create, get by job, get by id, update status, delete)
- `DependencyApi` — 5 methods (create scan, get scans, get vulnerabilities, update status, delete)
- `DirectiveApi` — 8 methods (CRUD + team/project listing, category filter)
- `FindingApi` — 7 methods (get by job/paged, counts, single, update status, batch create, search)
- `HealthMonitorApi` — 2 methods (get snapshot, create snapshot)
- `IntegrationApi` — 9 methods (GitHub + Jira connection CRUD)
- `JobApi` — 14 methods (CRUD + agent runs + investigation)
- `MetricsApi` — 3 methods (team metrics, project metrics, project trend)
- `PersonaApi` — 11 methods (CRUD + team/system/mine + default management)
- `ProjectApi` — 8 methods (CRUD + archive/unarchive + paged)
- `ReportApi` — 5 methods (upload summary/agent/spec, download report/spec)
- `TaskApi` — 6 methods (CRUD + batch + assigned-to-me)
- `TeamApi` — 12 methods (CRUD + members + invitations)
- `TechDebtApi` — 9 methods (CRUD + batch + by status/category + summary)
- `UserApi` — 6 methods (me, get, update, search, activate/deactivate)
- `VaultApi` — 66 methods across 7 areas (secrets 19, policies 12, rotation 8, transit 12, dynamic 7, seal 5, audit 3)
- `AnthropicApiService` — 3 methods (list models via Anthropic API with own Dio client)

### Orchestration Services

**=== JobOrchestrator ===**
File: `lib/services/orchestration/job_orchestrator.dart`
Dependencies: AgentDispatcher, AgentMonitor, VeraManager, ProgressAggregator, ReportParser, JobApi, FindingApi, ReportApi, AgentProgressNotifier?

10-step job lifecycle: create job → create agent runs → set RUNNING → dispatch agents → parse/upload reports → Vera consolidation → upload findings → upload summary → final status sync → emit completion.

**=== AgentDispatcher ===**
File: `lib/services/orchestration/agent_dispatcher.dart`
Dependencies: ProcessManager, PersonaManager, ClaudeCodeDetector

Dispatches Claude Code CLI agents as subprocesses. Assembles persona-driven prompts, spawns `claude` CLI processes with `--print --output-format stream-json --max-turns N --model M -p PROMPT`. Semaphore-based concurrency control.

**=== VeraManager ===**
File: `lib/services/orchestration/vera_manager.dart`

Consolidation engine: deduplicates findings (same file path + line within ±5 + Levenshtein title similarity ≥0.8), computes weighted health scores (Security/Architecture get 1.5x weight), determines overall result (any critical=FAIL, any high=WARN, else PASS), generates markdown executive summary.

### VCS Services

**=== GitService ===**
File: `lib/services/vcs/git_service.dart`
Dependencies: ProcessRunner (injectable, defaults to SystemProcessRunner)

Local git CLI wrapper: clone (with progress streaming), pull, push, fetch, checkout, branch, status (porcelain v2), diff, log, commit, merge, blame, stash, tag. Sets `GIT_TERMINAL_PROMPT=0` on all commands.

**=== GitHubProvider ===**
File: `lib/services/vcs/github_provider.dart` (implements `VcsProvider`)
Dependencies: Dio (targeting api.github.com)

GitHub REST API v3: authenticate, orgs, repos, branches, PRs, commits, workflow runs, releases. Tracks rate limits from response headers.

### Platform Services

**=== ClaudeCodeDetector ===**
File: `lib/services/platform/claude_code_detector.dart`

Detects Claude Code CLI: `which`/`where.exe` first, then probes Homebrew (Apple Silicon + Intel), npm global, nvm, `.local/bin`. Version validation against `AppConstants.minClaudeCodeVersion`. Desktop apps don't inherit shell PATH, hence fallback probing.

**=== ProcessManager ===**
File: `lib/services/platform/process_manager.dart`

Spawns, tracks, and tears down subprocesses. `ManagedProcess` wraps `dart:io Process` with decoded line-by-line streams, elapsed time, and timeout-based kill.

---

## 10. Security Architecture

**Authentication Flow:**
- JWT Bearer token via CodeOps-Server's `/auth/login` endpoint
- Token stored in SharedPreferences (`keyAuthToken`, `keyRefreshToken`)
- `ApiClient` attaches `Authorization: Bearer <token>` to all requests except public paths (`/auth/login`, `/auth/register`, `/auth/refresh`, `/health`)
- On 401: single automatic retry via refresh token (`POST /auth/refresh`), then updates stored tokens
- Logout: clears tokens from SharedPreferences, broadcasts `unauthenticated` to GoRouter

**VaultApiClient:** Identical JWT pattern. Only public path: `/seal/status`. Token refresh hits CodeOps-Server (not Vault).

**AnthropicApiService:** Uses `x-api-key` header per request. Key stored in SharedPreferences under `keyAnthropicApiKey`.

**Authorization Model:** Role-based on server side (OWNER, LEAD, MEMBER, VIEWER). Client does not enforce roles — relies on server 403 responses.

**Token Storage:** SharedPreferences (NOT Keychain). `clearAll()` preserves remember-me credentials and Anthropic API key. This is a conscious design choice to avoid macOS Keychain dialog popups.

**Correlation IDs:** All API clients add `X-Correlation-ID` header (UUID) for request tracing.

**No CORS** — Desktop app, not browser-based.

**No encryption** — Tokens stored in plaintext via SharedPreferences.

---

## 11. Notification / Messaging Layer

No email, webhook, or message broker integration on the client side. Notifications are handled via:
- `Stream<AuthState>` broadcast for auth state changes
- `Stream<JobLifecycleEvent>` broadcast for job progress
- `Stream<JobProgress>` for real-time agent progress (via ProgressAggregator)
- Riverpod `StateNotifier` / `StreamProvider` for reactive UI updates

---

## 12. Error Handling

**File:** `lib/services/cloud/api_exceptions.dart`

Sealed class hierarchy: `ApiException` (extends `Exception`, has `message` and `statusCode?`).

```
Exception Type          → HTTP Status → Behavior
BadRequestException     → 400         → "Bad request: {message}"
UnauthorizedException   → 401         → Triggers token refresh, then logout on second 401
ForbiddenException      → 403         → "Forbidden: {message}"
NotFoundException       → 404         → "Not found: {message}"
ConflictException       → 409         → "Conflict: {message}"
ValidationException     → 422         → "Validation error: {message}"
RateLimitException      → 429         → "Rate limit exceeded: {message}"
ServerException         → 500+        → "Server error: {message}"
NetworkException        → (no status) → "Network error: {message}"
TimeoutException        → (no status) → "Request timed out: {message}"
```

Mapping done in `ApiClient._errorInterceptor()` — converts `DioException` based on status code. Server error messages from `response.data['message']` are extracted. The same pattern applies to `VaultApiClient`, `GitHubProvider`, and `AnthropicApiService`.

---

## 13. Test Coverage

```
=== TEST INVENTORY ===
Unit test files (test/):                235
Integration test files (integration_test/): 5
Total test files:                       240

test() calls:          1,802
testWidgets() calls:      837
Total test cases:       2,639
group() calls:            631
Mock class declarations:   60

Framework:     mocktail (mock classes extend Mock)
Widget tests:  ProviderScope wrapper with overridden providers
Integration:   5 flow tests (dependency, directive, health dashboard, persona, tech debt)
```

**Test file distribution:**
- `test/models/` — 22 files
- `test/providers/` — 22 files
- `test/services/` — 47 files (cloud: 20, auth: 2, vcs: 3, orchestration: 6, agent: 4, analysis: 3, platform: 2, data: 2, jira: 2, logging: 2, integration: 1)
- `test/pages/` — 27 files
- `test/widgets/` — 107 files
- `test/database/` — 2 files
- `test/theme/` — 2 files
- `test/utils/` — 3 files
- `test/router/` — 1 file, `test/navigation/` — 1 file, `test/integration/` — 1 file

---

## 14. Cross-Cutting Patterns & Conventions

**State Management:** Riverpod throughout. ~210 providers across 25 files. Pattern: API providers (`Provider<XxxApi>`) → data providers (`FutureProvider<T>`) → UI state providers (`StateProvider<T>`) → derived/filtered providers (`Provider<AsyncValue<T>>`).

**Root dependency chain:** `secureStorageProvider` → `apiClientProvider` → all API providers. `databaseProvider` feeds local data services.

**Navigation:** GoRouter with 31 routes. `AuthNotifier` bridges `AuthService` state to router. Login/Setup outside `ShellRoute`. All authenticated routes inside `ShellRoute` with `NavigationShell` (collapsible sidebar 64px/240px, 7 sections).

**HTTP Pattern:** Centralized Dio client with 4 interceptors (auth, refresh, error, logging). All 18 domain API services have zero local error handling — delegate to interceptor chain.

**Model Serialization:** `json_serializable` (14 model files generate `.g.dart`). Enums use custom `JsonConverter` classes (30 converters). VCS models use manual `fromGitHubJson()` factories.

**Naming Conventions:**
- API services: `XxxApi` (e.g., `ProjectApi`, `VaultApi`)
- Providers: `xxxProvider` (e.g., `teamProjectsProvider`, `filteredPersonasProvider`)
- Pages: `XxxPage` (e.g., `HomePage`, `VaultDashboardPage`)
- Models: domain names (e.g., `Project`, `QaJob`, `Finding`)

**Constants:** Centralized in `AppConstants` class. Mirrors server's `AppConstants.java`.

**Logging:** `LogService` singleton with `v/d/i/w/e/f` methods (verbose through fatal). ANSI colors in debug. Daily file rotation with 7-day retention in release.

**Documentation:** 94.6% DartDoc coverage (280/296 files). Only generated `.g.dart` files lack DartDoc. All service and provider classes have DartDoc on class declarations.

**Known duplicate providers:**
- `findingApiProvider` defined in both `finding_providers.dart` and `job_providers.dart`
- `jiraConnectionsProvider` defined in both `jira_providers.dart` and `project_providers.dart`

---

## 15. Known Issues, TODOs, and Technical Debt

**Zero TODO/FIXME/HACK/XXX comments** in `lib/`. The only matches for "TODO" are inside string literals describing agent capabilities (not actual TODO comments).

---

## 16. OpenAPI Specification

See `CodeOps-Client-OpenAPI.yaml` — documents all outbound API calls the client makes to CodeOps-Server (~92 endpoints) and CodeOps-Vault (~66 endpoints). Total: ~158 endpoints.

---

## 17. Database — Local Schema

SQLite via Drift. Schema version 7. 20 tables. See Section 6 for complete table definitions. No live server database — this is a client-side SQLite database.

Migration history:
- v1: Initial 13 tables (Projects, QaJobs, AgentRuns, Findings, RemediationTasks, Personas, Directives, TechDebtItems, DependencyScans, DependencyVulnerabilities, HealthSnapshots, ComplianceItems, Specifications)
- v2: Added ClonedRepos, SyncMetadata
- v3: (minor alterations)
- v4: Added startedByName to QaJobs, statusChangedBy/statusChangedAt to Findings
- v5: Added AnthropicModels, AgentDefinitions, AgentFiles
- v6: Added ProjectLocalConfig
- v7: Added ScribeTabs, ScribeSettings (custom table name)

---

## 18. Kafka / Message Broker

No message broker (Kafka, RabbitMQ, SQS/SNS) detected in this project. This is a desktop client application.

---

## 19. Redis / Cache Layer

No Redis or caching layer detected in this project. Local data caching is handled by the Drift SQLite database.

---

## 20. Environment Variable Inventory

No environment variables used. All configuration is hardcoded in `lib/utils/constants.dart`. API base URLs, storage keys, limits, and feature constants are all compile-time constants.

| Constant | Value | Risk |
|---|---|---|
| `apiBaseUrl` | `http://localhost:8090` | Hardcoded — no production URL support |
| `vaultApiBaseUrl` | `http://localhost:8097` | Hardcoded — no production URL support |
| `anthropicApiBaseUrl` | `https://api.anthropic.com` | Correct for all environments |

**Note:** API keys (Anthropic, GitHub PAT) are stored at runtime in SharedPreferences, not compiled in.

---

## 21. Inter-Service Communication Map

**Outbound dependencies (this client → external services):**

| Target Service | Client Class | Transport | Auth | Methods |
|---|---|---|---|---|
| CodeOps-Server (localhost:8090) | `ApiClient` (Dio) | HTTP REST | JWT Bearer (auto-refresh on 401) | ~92 endpoints across 16 API service classes |
| CodeOps-Vault (localhost:8097) | `VaultApiClient` (Dio) | HTTP REST | JWT Bearer (refresh via Server) | ~66 endpoints in VaultApi |
| Anthropic API (api.anthropic.com) | `AnthropicApiService` (Dio) | HTTP REST | `x-api-key` header | 3 methods (all GET /v1/models) |
| GitHub API (api.github.com) | `GitHubProvider` (Dio) | HTTP REST | Bearer token | 13 methods (repos, branches, PRs, etc.) |
| Jira API (user-configured URL) | `JiraService` (Dio) | HTTP REST | Basic auth (email + API token) | ~15 methods (issues, projects, sprints, etc.) |
| Claude Code CLI | `AgentDispatcher` (Process) | Subprocess | N/A (inherits env) | Spawns `claude` with `--print --output-format stream-json` |
| Local git | `GitService` (Process) | Subprocess | N/A | 20+ git commands via `dart:io Process` |

**Inbound dependencies:** None. This is a desktop client — no services call it.
