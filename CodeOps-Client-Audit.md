# CodeOps-Client — Comprehensive Codebase Audit

**Audit Date:** 2026-02-15T21:30:00Z
**Branch:** main
**Commit:** ad0bd82 Fix paginated API response parsing and add post-login team auto-selection
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**OpenAPI Spec:** N/A — This is a client application; the server's OpenAPI spec lives in CodeOps-Server
**Quality Grade:** A
**Overall Score:** 86/104 (83%)

> This audit is the single source of truth for the CodeOps-Client codebase.
> An AI reading only this document should be able to generate accurate code
> changes, new features, tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:           CodeOps-Client
Repository URL:         GitHub (private)
Primary Language:       Dart / Flutter
SDK Version:            Flutter 3.41.1 / Dart 3.11.0
Build Tool:             Flutter CLI + pub
Current Branch:         main
Latest Commit Hash:     ad0bd82
Latest Commit Message:  Fix paginated API response parsing and add post-login team auto-selection
Audit Timestamp:        2026-02-15T21:30:00Z
```

**Platform:** macOS desktop application (Flutter desktop)
**Architecture:** Riverpod state management + GoRouter navigation + Dio HTTP client + Drift local SQLite database

---

## 2. Directory Structure

```
CodeOps-Client/
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── assets/
│   └── personas/                    # Built-in agent persona markdown files
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # Root widget (MaterialApp.router)
│   ├── router.dart                  # GoRouter with 24 routes
│   ├── database/
│   │   ├── database.dart            # Drift SQLite database definition
│   │   └── tables.dart              # 18 Drift table definitions
│   ├── models/
│   │   ├── enums.dart               # 22 enums with JSON converters (1,481 lines)
│   │   ├── user.dart
│   │   ├── team.dart
│   │   ├── project.dart
│   │   ├── qa_job.dart
│   │   ├── finding.dart
│   │   ├── agent_run.dart
│   │   ├── health_snapshot.dart     # Also contains PageResponse, AuthResponse, TeamMetrics, etc.
│   │   ├── remediation_task.dart
│   │   ├── persona.dart
│   │   ├── directive.dart
│   │   ├── compliance_item.dart
│   │   ├── dependency_scan.dart
│   │   ├── tech_debt_item.dart
│   │   ├── jira_models.dart         # 17+ Jira model classes
│   │   ├── specification.dart
│   │   └── vcs_models.dart          # 18 VCS model classes (plain Dart, no codegen)
│   ├── pages/                       # 24 page files
│   │   ├── admin_hub_page.dart
│   │   ├── audit_wizard_page.dart
│   │   ├── bug_investigator_page.dart
│   │   ├── compliance_wizard_page.dart
│   │   ├── dependency_scan_page.dart
│   │   ├── directives_page.dart
│   │   ├── findings_explorer_page.dart
│   │   ├── github_browser_page.dart
│   │   ├── health_dashboard_page.dart
│   │   ├── home_page.dart
│   │   ├── jira_browser_page.dart
│   │   ├── job_history_page.dart
│   │   ├── job_progress_page.dart
│   │   ├── job_report_page.dart
│   │   ├── login_page.dart
│   │   ├── persona_editor_page.dart
│   │   ├── personas_page.dart
│   │   ├── placeholder_page.dart
│   │   ├── project_detail_page.dart
│   │   ├── projects_page.dart
│   │   ├── settings_page.dart
│   │   ├── task_list_page.dart
│   │   ├── task_manager_page.dart
│   │   └── tech_debt_page.dart
│   ├── providers/                   # 20 provider files (230 total providers)
│   │   ├── admin_providers.dart
│   │   ├── agent_providers.dart
│   │   ├── auth_providers.dart
│   │   ├── compliance_providers.dart
│   │   ├── dependency_providers.dart
│   │   ├── directive_providers.dart
│   │   ├── finding_providers.dart
│   │   ├── github_providers.dart
│   │   ├── health_providers.dart
│   │   ├── jira_providers.dart
│   │   ├── job_providers.dart
│   │   ├── persona_providers.dart
│   │   ├── project_providers.dart
│   │   ├── report_providers.dart
│   │   ├── settings_providers.dart
│   │   ├── task_providers.dart
│   │   ├── team_providers.dart
│   │   ├── tech_debt_providers.dart
│   │   ├── user_providers.dart
│   │   └── wizard_providers.dart
│   ├── services/
│   │   ├── agent/                   # Agent processing (3 files)
│   │   │   ├── persona_manager.dart
│   │   │   ├── report_parser.dart
│   │   │   └── task_generator.dart
│   │   ├── analysis/                # Analysis services (3 files)
│   │   │   ├── dependency_scanner.dart
│   │   │   ├── health_calculator.dart
│   │   │   └── tech_debt_tracker.dart
│   │   ├── auth/                    # Authentication (2 files)
│   │   │   ├── auth_service.dart
│   │   │   └── secure_storage.dart
│   │   ├── cloud/                   # Server API clients (18 files)
│   │   │   ├── admin_api.dart
│   │   │   ├── api_client.dart      # Dio HTTP client with interceptors
│   │   │   ├── api_exceptions.dart  # 10-class sealed exception hierarchy
│   │   │   ├── compliance_api.dart
│   │   │   ├── dependency_api.dart
│   │   │   ├── directive_api.dart
│   │   │   ├── finding_api.dart
│   │   │   ├── health_monitor_api.dart
│   │   │   ├── integration_api.dart
│   │   │   ├── job_api.dart
│   │   │   ├── metrics_api.dart
│   │   │   ├── persona_api.dart
│   │   │   ├── project_api.dart
│   │   │   ├── report_api.dart
│   │   │   ├── task_api.dart
│   │   │   ├── team_api.dart
│   │   │   ├── tech_debt_api.dart
│   │   │   └── user_api.dart
│   │   ├── data/                    # Data sync (1 file)
│   │   │   └── sync_service.dart
│   │   ├── integration/             # Export service (1 file)
│   │   │   └── export_service.dart
│   │   ├── jira/                    # Jira integration (2 files)
│   │   │   ├── jira_mapper.dart
│   │   │   └── jira_service.dart
│   │   ├── logging/                 # Structured logging (2 files)
│   │   │   ├── log_level.dart
│   │   │   └── log_service.dart
│   │   ├── orchestration/           # Job orchestration (5 files)
│   │   │   ├── agent_dispatcher.dart
│   │   │   ├── agent_monitor.dart
│   │   │   ├── bug_investigation_orchestrator.dart
│   │   │   ├── job_orchestrator.dart
│   │   │   └── progress_aggregator.dart
│   │   ├── platform/                # Platform services (2 files)
│   │   │   ├── claude_code_detector.dart
│   │   │   └── process_manager.dart
│   │   └── vcs/                     # Version control (4 files)
│   │       ├── git_service.dart
│   │       ├── github_provider.dart
│   │       ├── repo_manager.dart
│   │       └── vcs_provider.dart
│   ├── theme/
│   │   ├── app_theme.dart           # Material 3 dark theme
│   │   ├── colors.dart              # Color palette + semantic color maps
│   │   └── typography.dart          # Inter font + JetBrains Mono for code
│   ├── utils/
│   │   └── constants.dart           # All app constants (225 lines)
│   └── widgets/                     # 85+ reusable widget files
│       ├── admin/
│       ├── compliance/
│       ├── dashboard/
│       ├── dependency/
│       ├── findings/
│       ├── health/
│       ├── jira/
│       ├── personas/
│       ├── progress/
│       ├── reports/
│       ├── shared/                  # ErrorPanel, EmptyState, SearchBar, etc.
│       ├── shell/                   # NavigationShell, TeamSwitcherDialog
│       ├── tasks/
│       ├── tech_debt/
│       ├── vcs/
│       └── wizard/
├── test/                            # 192 test files
│   ├── database/
│   ├── integration/
│   ├── models/
│   ├── pages/
│   ├── providers/
│   ├── router/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── integration_test/                # 5 integration test files
├── macos/                           # macOS platform config
└── linux/                           # Linux platform config
```

**Narrative summary:**
- **Single-project Flutter desktop application** targeting macOS (primary) and Linux
- **Source code** in `lib/` (193 Dart files, 50,257 lines)
- **Tests** in `test/` (192 files) and `integration_test/` (5 files)
- **Configuration** via `pubspec.yaml`, `analysis_options.yaml`, `macos/` platform config
- **No monorepo** — standalone project that connects to CodeOps-Server backend

---

## 3. Build & Dependency Manifest

### Dependencies (30)

| Dependency | Version | Purpose |
|---|---|---|
| flutter (sdk) | 3.41.1 | Flutter framework |
| flutter_riverpod | ^2.6.1 | State management (Riverpod 2.x) |
| go_router | ^14.8.1 | Declarative routing with auth guards |
| dio | ^5.7.0 | HTTP client with interceptors |
| drift | ^2.23.1 | Local SQLite database (ORM) |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native libraries |
| flutter_secure_storage | ^9.2.4 | OS keychain storage (tokens) |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| json_serializable | ^6.9.4 | JSON code generation |
| uuid | ^4.5.1 | UUID generation (correlation IDs) |
| path_provider | ^2.1.5 | Platform-specific file paths |
| path | ^1.9.1 | Path manipulation |
| intl | ^0.19.0 | Date/number formatting |
| fl_chart | ^0.70.2 | Charts and data visualization |
| flutter_markdown | ^0.7.6+2 | Markdown rendering |
| url_launcher | ^6.3.1 | Open URLs in browser |
| file_picker | ^8.1.7 | Native file picker dialogs |
| archive | ^4.0.4 | ZIP file creation/extraction |
| pdf | ^3.11.3 | PDF document generation |
| collection | ^1.19.1 | Collection utilities |
| window_manager | ^0.4.3 | Desktop window management |
| crypto | ^3.0.6 | Cryptographic utilities |
| convert | ^3.1.2 | Encoding/decoding (base64, utf8) |

### Dev Dependencies (5)

| Dependency | Version | Purpose |
|---|---|---|
| flutter_test (sdk) | — | Widget testing framework |
| integration_test (sdk) | — | Integration testing |
| mocktail | ^1.0.4 | Mocking framework |
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.23.1 | Drift code generation |

### Build Commands

```
Install:    flutter pub get
Build:      flutter build macos
Run (dev):  flutter run -d macos
Test:       flutter test
Analyze:    flutter analyze
Codegen:    dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Configuration Files

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - sort_constructors_first
    - unnecessary_this
    - use_key_in_widget_constructors
```

### lib/utils/constants.dart (key values)

```
API Base URL:           http://localhost:8090
API Prefix:             /api/v1
App Name:               CodeOps
Window Min Size:        1024 × 700
Window Default Size:    1440 × 900
Sidebar Expanded:       240px
Sidebar Collapsed:      64px
Max Concurrent Agents:  1-6 (default 3)
Agent Timeout:          5-60 min
Max Turns:              10-100
Default Pass Threshold: 80
Default Warn Threshold: 60
Max Spec File Size:     50 MB
Max Live Findings:      50
Job Polling Interval:   5 seconds
Debounce Duration:      300ms
Default Page Size:      20
```

### macOS Entitlements

**Debug:** app-sandbox, JIT, network.server, network.client
**Release:** app-sandbox, network.client

### Connection Map

```
Backend API:     http://localhost:8090/api/v1 (CodeOps-Server)
GitHub API:      https://api.github.com (via GitHubProvider, PAT auth)
Jira API:        https://{instance}.atlassian.net (via JiraService, Basic auth)
Local Database:  SQLite via Drift (~/.codeops/codeops.db)
Secure Storage:  macOS Keychain / Linux libsecret
Log Files:       ~/.codeops/logs/codeops-YYYY-MM-DD.log
```

---

## 5. Startup & Runtime Behavior

### Entry Point: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogConfig.initialize();
  await windowManager.ensureInitialized();
  // Window options: size 1440×900, min 1024×700, centered, title 'CodeOps'
  log.i('App', 'CodeOps starting');
  runApp(const ProviderScope(child: CodeOpsApp()));
}
```

### Startup Sequence

1. Flutter binding initialized
2. LogConfig initialized (debug: console colors, release: file logging)
3. Window manager configured (size, min size, centering, title)
4. ProviderScope wraps app (Riverpod container)
5. CodeOpsApp builds MaterialApp.router with GoRouter
6. GoRouter redirects unauthenticated users to `/login`
7. On login success, AuthService stores tokens → authStateStream emits `authenticated`
8. app.dart `ref.listen(authStateProvider)` fires → sets `authNotifier.state` → router redirects to `/`
9. `_initTeamSelection()` auto-selects first team (or restores from secure storage)
10. Dashboard data loads: myJobs, teamProjects, teamMetrics

### Background Tasks

- **Job progress polling:** Every 5 seconds when a job is active (fallback for lifecycle stream)
- **Auth token refresh:** Automatic via Dio interceptor on 401 responses
- **Log file rotation:** 7-day retention, daily rotation

---

## 6. Data Model Layer

### Models Summary (17 files, 50+ classes)

All models use `@JsonSerializable()` with custom enum converters unless noted.

#### User (`lib/models/user.dart`)
```
Fields:
  - id: String (UUID)
  - email: String
  - displayName: String?
  - avatarUrl: String?
  - isActive: bool
  - lastLoginAt: DateTime?
  - createdAt: DateTime?
```

#### Team (`lib/models/team.dart`)
```
Classes: Team, TeamMember, Invitation

Team:
  - id: String (UUID)
  - name: String
  - description: String?
  - ownerId: String
  - ownerName: String?
  - teamsWebhookUrl: String?
  - memberCount: int?
  - createdAt, updatedAt: DateTime?

TeamMember:
  - id: String, userId: String, displayName: String, email: String
  - avatarUrl: String?, role: TeamRole (@TeamRoleConverter)
  - joinedAt: DateTime?

Invitation:
  - id: String, email: String, role: TeamRole (@TeamRoleConverter)
  - status: InvitationStatus, invitedByName: String?, expiresAt, createdAt: DateTime?
```

#### Project (`lib/models/project.dart`)
```
Fields:
  - id: String (UUID)
  - teamId: String
  - name: String
  - description: String?
  - githubConnectionId, repoUrl, repoFullName, defaultBranch: String?
  - jiraConnectionId, jiraProjectKey, jiraDefaultIssueType: String?
  - jiraLabels: List<String>?, jiraComponent: String?
  - techStack: String?
  - healthScore: int?
  - lastAuditAt: DateTime?
  - isArchived: bool
  - createdAt, updatedAt: DateTime?
```

#### QaJob (`lib/models/qa_job.dart`)
```
Classes: QaJob, JobSummary

QaJob:
  - id, projectId, projectName: String
  - mode: JobMode, status: JobStatus
  - name, branch, configJson, summaryMd: String?
  - overallResult: JobResult?
  - healthScore, totalFindings, criticalCount, highCount, mediumCount, lowCount: int?
  - jiraTicketKey, startedBy, startedByName: String?
  - startedAt, completedAt, createdAt: DateTime?

JobSummary:
  - id: String, projectName: String?
  - mode: JobMode, status: JobStatus
  - name: String?, overallResult: JobResult?
  - healthScore, totalFindings, criticalCount: int?
  - completedAt, createdAt: DateTime?
```

#### Finding (`lib/models/finding.dart`)
```
Fields:
  - id, jobId: String
  - agentType: AgentType, severity: Severity
  - title, description: String
  - filePath: String?, lineNumber: int?
  - recommendation, evidence: String?
  - effortEstimate: Effort?, debtCategory: DebtCategory?
  - status: FindingStatus
  - statusChangedBy: String?, statusChangedAt: DateTime?
  - createdAt: DateTime?
```

#### AgentRun (`lib/models/agent_run.dart`)
```
Fields:
  - id, jobId: String
  - agentType: AgentType, status: AgentStatus, result: AgentResult?
  - reportS3Key: String?
  - score, findingsCount, criticalCount, highCount: int?
  - startedAt, completedAt: DateTime?
```

#### HealthSnapshot and Related (`lib/models/health_snapshot.dart`)
```
Classes: HealthSnapshot, HealthSchedule, PageResponse<T>, AuthResponse,
         TeamMetrics, ProjectMetrics, GitHubConnection, JiraConnection,
         BugInvestigation, SystemSetting, AuditLogEntry, NotificationPreference

HealthSnapshot:
  - id, projectId, jobId: String
  - healthScore: int
  - findingsBySeverity: String? (JSON)
  - techDebtScore, dependencyScore: int?
  - testCoveragePercent: double?
  - capturedAt: DateTime?

PageResponse<T>:
  - content: List<T>
  - page, size, totalElements, totalPages: int
  - isLast: bool
  Factory: PageResponse.fromJson(Map, T Function(Object))

TeamMetrics:
  - teamId: String, totalProjects, totalJobs, totalFindings: int
  - averageHealthScore: double, projectsBelowThreshold, openCriticalFindings: int

ProjectMetrics:
  - projectId, projectName: String
  - currentHealthScore, previousHealthScore: int?
  - totalJobs, totalFindings, openCritical, openHigh: int
  - techDebtItemCount, openVulnerabilities: int
  - lastAuditAt: DateTime?
```

#### RemediationTask (`lib/models/remediation_task.dart`)
```
Fields:
  - id, jobId: String
  - taskNumber: int, title: String
  - description, promptMd, promptS3Key: String?
  - findingIds: List<String>?
  - priority: Priority, status: TaskStatus
  - assignedTo, assignedToName, jiraKey: String?
  - createdAt: DateTime?
```

#### Persona (`lib/models/persona.dart`)
```
Fields:
  - id, name: String
  - agentType: AgentType?, description, contentMd: String?
  - scope: Scope
  - teamId, createdBy, createdByName: String?
  - isDefault: bool, version: int?
  - createdAt, updatedAt: DateTime?
```

#### Directive (`lib/models/directive.dart`)
```
Classes: Directive, ProjectDirective

Directive:
  - id, name: String, description, contentMd: String?
  - category: DirectiveCategory, scope: DirectiveScope
  - teamId, projectId, createdBy, createdByName: String?
  - version: int?, createdAt, updatedAt: DateTime?

ProjectDirective:
  - projectId, directiveId, directiveName: String
  - category: DirectiveCategory, enabled: bool
```

#### VCS Models (`lib/models/vcs_models.dart`) — Plain Dart (no codegen)
```
18 classes:
  FileChangeType (enum), DiffLineType (enum),
  VcsCredentials, VcsOrganization, VcsRepository, VcsBranch,
  VcsPullRequest, CreatePRRequest, VcsCommit, VcsStash, VcsTag,
  CloneProgress, RepoStatus, FileChange, DiffResult, DiffHunk,
  DiffLine, WorkflowRun

All use manual fromGitHubJson()/fromGitJson() factories.
```

#### Additional Models
- **ComplianceItem:** id, jobId, requirement, specId, specName, status (ComplianceStatus), evidence, agentType, notes, createdAt
- **DependencyScan:** id, projectId, jobId, manifestFile, totalDependencies, outdatedCount, vulnerableCount, createdAt
- **DependencyVulnerability:** id, scanId, dependencyName, currentVersion, fixedVersion, cveId, severity, description, status (VulnerabilityStatus), createdAt
- **TechDebtItem:** id, projectId, category (DebtCategory), title, description, filePath, effortEstimate (Effort), businessImpact (BusinessImpact), status (DebtStatus), firstDetectedJobId, resolvedJobId, createdAt, updatedAt
- **Specification:** id, jobId, name, specType (SpecType), s3Key, createdAt
- **JiraModels:** 17+ classes including JiraSearchResult, JiraIssue, JiraIssueFields, JiraStatus, JiraUser, JiraComment, JiraProject, JiraSprint, JiraTransition, CreateJiraIssueRequest, etc.

---

## 7. Enum Definitions

All enums are in `lib/models/enums.dart` (1,481 lines). Each has `toJson()`, `fromJson()`, and `displayName` getter.

```
AgentResult:     pass, warn, fail
AgentStatus:     pending, running, completed, failed
AgentType:       security, codeQuality, buildHealth, completeness, apiContract,
                 testCoverage, uiUx, documentation, database, performance,
                 dependency, architecture (12 types)
BusinessImpact:  low, medium, high, critical
ComplianceStatus: met, partial, missing, notApplicable
DebtCategory:    architecture, code, test, dependency, documentation
DebtStatus:      identified, planned, inProgress, resolved
DirectiveCategory: architecture, standards, conventions, context, other
DirectiveScope:  team, project, user
Effort:          s, m, l, xl (t-shirt sizing)
FindingStatus:   open, acknowledged, falsePositive, fixed, wontFix
GitHubAuthType:  pat, oauth, ssh
InvitationStatus: pending, accepted, expired
JobMode:         audit, compliance, bugInvestigate, remediate, techDebt,
                 dependency, healthMonitor (7 modes)
JobResult:       pass, warn, fail
JobStatus:       pending, running, completed, failed, cancelled
Priority:        p0, p1, p2, p3
ScheduleType:    daily, weekly, onCommit
Scope:           system, team, user
Severity:        critical, high, medium, low
SpecType:        openapi, markdown, screenshot, figma
TaskStatus:      pending, assigned, exported, jiraCreated, completed
TeamRole:        owner, admin, member, viewer
VulnerabilityStatus: open, updating, suppressed, resolved
```

**JSON mapping convention:** camelCase strings (e.g., `codeQuality`, `bugInvestigate`, `falsePositive`)

---

## 8. Local Database Layer (Drift SQLite)

### Database: `lib/database/database.dart`

```
Engine:         SQLite via Drift
Location:       Platform-specific application support directory
Schema Version: 4
Migration:      onUpgrade with stepByStep strategy
Logout:         clearAllTables() deletes all rows
```

### Tables: `lib/database/tables.dart` (18 tables)

| Table | Primary Key | Purpose |
|---|---|---|
| Users | id (text) | User profile cache |
| Teams | id (text) | Team cache |
| Projects | id (text) | Project cache |
| QaJobs | id (text) | Job cache |
| AgentRuns | id (text) | Agent run cache |
| Findings | id (text) | Finding cache |
| RemediationTasks | id (text) | Task cache |
| Personas | id (text) | Persona cache |
| Directives | id (text) | Directive cache |
| TechDebtItems | id (text) | Debt cache |
| DependencyScans | id (text) | Scan cache |
| DependencyVulnerabilities | id (text) | Vulnerability cache |
| HealthSnapshots | id (text) | Health cache |
| ComplianceItems | id (text) | Compliance cache |
| Specifications | id (text) | Spec cache |
| ClonedRepos | repoFullName (text) | Local repo registry |
| SyncMetadata | syncTableName (text) | Sync tracking |

All tables mirror the server-side PostgreSQL schema for offline caching.

---

## 9. Cloud API Service Layer (18 files)

All API services are in `lib/services/cloud/` and share a common `ApiClient` (Dio wrapper).

### ApiClient (`api_client.dart`)

```
Base URL:        http://localhost:8090/api/v1
Interceptors:    Auth (JWT Bearer) → Token Refresh (on 401) → Error Mapper → Logging
Timeout:         Connect: 30s, Receive: 60s
Auth Header:     Authorization: Bearer {token}
Correlation ID:  X-Correlation-ID header on each request
```

**Public Methods:**
- `get<T>(path, {queryParameters})` → `Future<Response<T>>`
- `post<T>(path, {data, queryParameters})` → `Future<Response<T>>`
- `put<T>(path, {data, queryParameters})` → `Future<Response<T>>`
- `delete<T>(path, {queryParameters})` → `Future<Response<T>>`
- `uploadFile<T>(path, {filePath, fieldName})` → `Future<Response<T>>`
- `downloadFile(path, savePath)` → `Future<Response>`

### Exception Hierarchy (`api_exceptions.dart`)

```
ApiException (sealed base)
├── BadRequestException (400, optional field errors map)
├── UnauthorizedException (401)
├── ForbiddenException (403)
├── NotFoundException (404)
├── ConflictException (409)
├── ValidationException (422, optional fieldErrors map)
├── RateLimitException (429, optional retryAfterSeconds)
├── ServerException (500+)
├── NetworkException (no connection)
└── TimeoutException (request timeout)
```

### Complete API Surface (174 methods across 16 domain services)

#### JobApi — `/jobs` (13 methods)
```
POST   /jobs                           createJob({projectId, mode, name?, branch?, configJson?, jiraTicketKey?}) → QaJob
GET    /jobs/{jobId}                   getJob(jobId) → QaJob
PUT    /jobs/{jobId}                   updateJob(jobId, {status?, summaryMd?, overallResult?, healthScore?, ...}) → QaJob
DELETE /jobs/{jobId}                   deleteJob(jobId) → void
GET    /jobs/project/{projectId}       getProjectJobs(projectId, {page, size}) → PageResponse<JobSummary>
GET    /jobs/mine                      getMyJobs() → List<JobSummary>
POST   /jobs/{jobId}/agents            createAgentRun(jobId, {agentType}) → AgentRun
POST   /jobs/{jobId}/agents/batch      createAgentRunsBatch(jobId, agentTypes) → List<AgentRun>
GET    /jobs/{jobId}/agents            getAgentRuns(jobId) → List<AgentRun>
PUT    /jobs/agents/{agentRunId}       updateAgentRun(agentRunId, {status?, result?, ...}) → AgentRun
POST   /jobs/{jobId}/investigation     createInvestigation(jobId, {jiraKey?, ...}) → BugInvestigation
GET    /jobs/{jobId}/investigation     getInvestigation(jobId) → BugInvestigation
PUT    /jobs/investigations/{id}       updateInvestigation(id, {rcaMd?, ...}) → BugInvestigation
```

#### FindingApi — `/findings` (10 methods)
```
POST   /findings                       createFinding({jobId, agentType, severity, title, ...}) → Finding
POST   /findings/batch                 createFindingsBatch(List<Map>) → List<Finding>
GET    /findings/job/{jobId}           getJobFindings(jobId, {page, size}) → PageResponse<Finding>
GET    /findings/{findingId}           getFinding(findingId) → Finding
GET    /findings/job/{jobId}/severity/{s} getFindingsBySeverity(jobId, severity) → List<Finding>
GET    /findings/job/{jobId}/status/{s}   getFindingsByStatus(jobId, status) → List<Finding>
GET    /findings/job/{jobId}/agent/{a}    getFindingsByAgent(jobId, agentType) → List<Finding>
GET    /findings/job/{jobId}/counts       getFindingCounts(jobId) → Map<String, dynamic>
PUT    /findings/{findingId}/status       updateFindingStatus(findingId, status) → Finding
PUT    /findings/bulk-status              bulkUpdateStatus(findingIds, status) → List<Finding>
```

#### ProjectApi — `/projects` (8 methods)
```
POST   /projects/{teamId}              createProject(teamId, {name, description?, github/jira config...}) → Project
GET    /projects/team/{teamId}         getTeamProjects(teamId, {includeArchived}) → List<Project>
GET    /projects/team/{teamId}/paged   getTeamProjectsPaged(teamId, {page, size, includeArchived}) → PageResponse<Project>
GET    /projects/{projectId}           getProject(projectId) → Project
PUT    /projects/{projectId}           updateProject(projectId, {name?, ...}) → Project
DELETE /projects/{projectId}           deleteProject(projectId) → void
PUT    /projects/{projectId}/archive   archiveProject(projectId) → void
PUT    /projects/{projectId}/unarchive unarchiveProject(projectId) → void
```

#### TeamApi — `/teams` (12 methods)
```
GET    /teams                           getTeams() → List<Team>
POST   /teams                           createTeam({name, description?, teamsWebhookUrl?}) → Team
GET    /teams/{teamId}                  getTeam(teamId) → Team
PUT    /teams/{teamId}                  updateTeam(teamId, {name?, description?, teamsWebhookUrl?}) → Team
DELETE /teams/{teamId}                  deleteTeam(teamId) → void
GET    /teams/{teamId}/members          getTeamMembers(teamId) → List<TeamMember>
PUT    /teams/{teamId}/members/{userId}/role updateMemberRole(teamId, userId, role) → TeamMember
DELETE /teams/{teamId}/members/{userId} removeMember(teamId, userId) → void
POST   /teams/{teamId}/invitations      inviteMember(teamId, {email, role}) → Invitation
GET    /teams/{teamId}/invitations      getTeamInvitations(teamId) → List<Invitation>
DELETE /teams/{teamId}/invitations/{id} cancelInvitation(teamId, invitationId) → void
POST   /teams/invitations/{token}/accept acceptInvitation(token) → Team
```

#### UserApi — `/users` (6 methods)
```
GET    /users/me                        getCurrentUser() → User
GET    /users/{id}                      getUserById(id) → User
PUT    /users/{id}                      updateUser(id, {displayName?, avatarUrl?}) → User
GET    /users/search                    searchUsers(query) → List<User>
PUT    /users/{id}/deactivate           deactivateUser(id) → void
PUT    /users/{id}/activate             activateUser(id) → void
```

#### PersonaApi — `/personas` (11 methods)
```
POST   /personas                        createPersona({name, contentMd, scope, agentType?, ...}) → Persona
GET    /personas/{personaId}            getPersona(personaId) → Persona
PUT    /personas/{personaId}            updatePersona(personaId, {name?, description?, contentMd?, isDefault?}) → Persona
DELETE /personas/{personaId}            deletePersona(personaId) → void
GET    /personas/team/{teamId}          getTeamPersonas(teamId) → List<Persona>
GET    /personas/team/{teamId}/agent/{type} getTeamPersonasByAgentType(teamId, agentType) → List<Persona>
GET    /personas/team/{teamId}/default/{type} getTeamDefaultPersona(teamId, agentType) → Persona
PUT    /personas/{personaId}/set-default setAsDefault(personaId) → Persona
PUT    /personas/{personaId}/remove-default removeDefault(personaId) → Persona
GET    /personas/system                 getSystemPersonas() → List<Persona>
GET    /personas/mine                   getMyPersonas() → List<Persona>
```

#### DirectiveApi — `/directives` (11 methods)
```
POST   /directives                      createDirective({name, contentMd, scope, ...}) → Directive
GET    /directives/{directiveId}        getDirective(directiveId) → Directive
PUT    /directives/{directiveId}        updateDirective(directiveId, {name?, ...}) → Directive
DELETE /directives/{directiveId}        deleteDirective(directiveId) → void
GET    /directives/team/{teamId}        getTeamDirectives(teamId) → List<Directive>
GET    /directives/project/{projectId}  getProjectDirectives(projectId) → List<Directive>
GET    /directives/project/{id}/enabled getProjectEnabledDirectives(projectId) → List<Directive>
GET    /directives/project/{id}/assignments getProjectDirectiveAssignments(projectId) → List<ProjectDirective>
POST   /directives/assign               assignToProject({projectId, directiveId, enabled}) → ProjectDirective
PUT    /directives/project/{pId}/directive/{dId}/toggle toggleDirective(pId, dId, enabled) → ProjectDirective
DELETE /directives/project/{pId}/directive/{dId} removeFromProject(pId, dId) → void
```

#### TaskApi — `/tasks` (6 methods)
```
POST   /tasks                           createTask({jobId, taskNumber, title, ...}) → RemediationTask
POST   /tasks/batch                     createTasksBatch(List<Map>) → List<RemediationTask>
GET    /tasks/job/{jobId}              getTasksForJob(jobId) → List<RemediationTask>
GET    /tasks/{taskId}                 getTask(taskId) → RemediationTask
PUT    /tasks/{taskId}                 updateTask(taskId, {status?, assignedTo?, jiraKey?}) → RemediationTask
GET    /tasks/assigned-to-me           getAssignedTasks() → List<RemediationTask>
```

#### Additional APIs (ComplianceApi, DependencyApi, TechDebtApi, HealthMonitorApi, MetricsApi, IntegrationApi, AdminApi, ReportApi)

- **ComplianceApi** (7 methods): specs CRUD, compliance items CRUD, summary
- **DependencyApi** (10 methods): scans CRUD, vulnerabilities CRUD, status updates
- **TechDebtApi** (9 methods): debt items CRUD, filtering, summary
- **HealthMonitorApi** (8 methods): schedules, snapshots, trends
- **MetricsApi** (3 methods): team metrics, project metrics, project trend
- **IntegrationApi** (8 methods): GitHub connections, Jira connections
- **AdminApi** (9 methods): users, settings, usage stats, audit logs
- **ReportApi** (5 methods): upload summary/agent reports, upload specs, download

---

## 10. Service Layer (Non-Cloud)

### Auth Services

#### AuthService (`lib/services/auth/auth_service.dart`)
```
Dependencies: ApiClient, SecureStorageService, CodeOpsDatabase
Methods:
  - login(email, password) → User        — POST /auth/login, stores tokens
  - register(email, password, displayName) → User — POST /auth/register
  - refreshToken() → void                — POST /auth/refresh
  - changePassword(current, newPassword) → void
  - logout() → void                      — Clears tokens, DB, emits unauthenticated
  - tryAutoLogin() → void                — Restores session from stored tokens
  - authStateStream → Stream<AuthState>  — Broadcast stream
```

#### SecureStorageService (`lib/services/auth/secure_storage.dart`)
```
Dependencies: FlutterSecureStorage (OS keychain)
Methods:
  - getAuthToken/setAuthToken       — JWT access token
  - getRefreshToken/setRefreshToken — Refresh token
  - getCurrentUserId/setCurrentUserId
  - getSelectedTeamId/setSelectedTeamId
  - read(key)/write(key, value)/delete(key)/clearAll()
```

### Orchestration Services

#### JobOrchestrator (`lib/services/orchestration/job_orchestrator.dart`)
```
Dependencies: AgentDispatcher, AgentMonitor, VeraManager, ProgressAggregator,
              ReportParser, JobApi, FindingApi, ReportApi
Methods:
  - executeJob({...}) → JobResult        — Full 10-step job lifecycle
  - cancelJob(jobId) → void              — Cancels running job
  - lifecycleStream → Stream<JobLifecycleEvent>
  - activeJobId → String?
```

10-step lifecycle:
1. Create job record (API)
2. Create agent run records (API)
3. Dispatch agent subprocesses (Claude Code CLI)
4. Monitor agent output streams
5. Parse agent reports (markdown → structured data)
6. Vera consolidation (dedup, score, summary)
7. Upload agent reports to S3 (API)
8. Batch-create findings (API)
9. Upload executive summary (API)
10. Update job status to completed/failed (API)

#### AgentDispatcher (`lib/services/orchestration/agent_dispatcher.dart`)
```
Dependencies: ProcessManager, PersonaManager, ClaudeCodeDetector
Methods:
  - dispatchAgent({...}) → ManagedProcess     — Spawn single Claude Code subprocess
  - dispatchAll({...}) → Stream<AgentDispatchEvent> — Concurrent dispatch with semaphore
  - cancelAll() → void
```

#### AgentMonitor, VeraManager, ProgressAggregator, BugInvestigationOrchestrator
- Monitor agent process output to completion
- Consolidate reports: dedup findings, compute health score, determine result
- Real-time progress aggregation across agents
- Launch bug investigation jobs from Jira issues

### VCS Services

#### GitService (`lib/services/vcs/git_service.dart`)
```
Methods: clone, pull, push, fetchAll, checkout, createBranch, status, diff,
         diffStat, log, commit, merge, blame, stash ops, tag ops, currentBranch, remoteUrl
All via dart:io Process calls to git CLI
```

#### GitHubProvider (`lib/services/vcs/github_provider.dart`)
```
Dependencies: Dio (separate instance targeting api.github.com)
Methods: authenticate, getOrganizations, getRepositories, searchRepositories,
         getBranches, getPullRequests, createPullRequest, mergePullRequest,
         getCommitHistory, getWorkflowRuns, getReleases
Auth: PAT Bearer token
```

#### RepoManager (`lib/services/vcs/repo_manager.dart`)
```
Dependencies: GitService, CodeOpsDatabase
Methods: registerRepo, unregisterRepo, getAllRepos, isCloned, getRepoStatus, openInFileManager
Default repo dir: ~/CodeOps/repos/
```

### Jira Services

#### JiraService (`lib/services/jira/jira_service.dart`)
```
Dependencies: Dio (separate instance targeting Jira Cloud)
Auth: Basic (email:apiToken base64)
Methods: configure, testConnection, searchIssues (JQL), getIssue, getComments,
         postComment, createIssue, createSubTask, createIssuesBulk, updateIssue,
         getTransitions, transitionIssue, getProjects, getSprints, getIssueTypes,
         searchUsers, getPriorities
```

#### JiraMapper (`lib/services/jira/jira_mapper.dart`)
```
Static methods: toInvestigationFields, taskToJiraIssue, tasksToJiraIssues,
                toDisplayModel, adfToMarkdown, markdownToAdf, mapStatusColor, mapPriority
```

### Agent Services
- **PersonaManager:** Assembles agent prompts (persona + directives + context)
- **ReportParser:** Parses markdown reports → structured models (findings, metadata, metrics)
- **TaskGenerator:** Groups findings → creates remediation tasks with Claude Code prompts

### Analysis Services
- **HealthCalculator:** Weighted composite health scores from agent runs
- **TechDebtTracker:** Debt scoring, category/status breakdowns, markdown reports
- **DependencyScanner:** Vulnerability health scoring, grouping, reports

### Platform Services
- **ProcessManager:** Subprocess lifecycle with ManagedProcess wrapper, timeouts
- **ClaudeCodeDetector:** Detects Claude Code CLI (installed, version, path)

### Data & Integration Services
- **SyncService:** Cloud ↔ local DB project sync
- **ExportService:** Export as markdown, PDF, ZIP, CSV with file save dialogs

### Logging Service
- **LogService:** Singleton with v/d/i/w/e/f methods, ANSI colors in debug, file logging in release
- **LogLevel:** verbose, debug, info, warning, error, fatal
- **LogConfig:** Level, file logging, console colors, muted tags, log directory

---

## 11. Provider Layer (230 providers across 20 files)

### Provider Architecture

All providers are in `lib/providers/`. The app uses Riverpod 2.x with manual provider definitions (not @riverpod codegen).

**Provider Types Used:**
- `Provider` (36): API service instances, computed values
- `StateProvider` (51): UI state (selected IDs, filters, search queries)
- `FutureProvider` (55): Async data loading
- `FutureProvider.family` (61): Parameterized async loading
- `FutureProvider.autoDispose` (10): Auto-disposing async data
- `FutureProvider.autoDispose.family` (9): Parameterized auto-disposing
- `StreamProvider` (2): Reactive streams (jobProgress, jobLifecycle)
- `StateNotifierProvider` (4): Complex state (wizards, favorites, dispatch config)

### Key Providers

```
auth_providers.dart:
  secureStorageProvider → SecureStorageService (singleton)
  apiClientProvider → ApiClient (singleton, depends on secureStorage)
  databaseProvider → CodeOpsDatabase (singleton)
  authServiceProvider → AuthService
  authStateProvider → Stream<AuthState>
  currentUserProvider → User? (mutable)

team_providers.dart:
  teamApiProvider → TeamApi
  teamsProvider → List<Team>
  selectedTeamIdProvider → String? (CRITICAL: null → all team-scoped providers return empty)
  selectedTeamProvider → Team?
  teamMembersProvider → List<TeamMember>
  teamInvitationsProvider → List<Invitation>

project_providers.dart:
  projectApiProvider → ProjectApi
  selectedProjectIdProvider → String?
  teamProjectsProvider → List<Project> (depends on selectedTeamIdProvider)
  filteredProjectsProvider → List<Project> (search, sort, archive filter)

job_providers.dart:
  jobApiProvider → JobApi
  myJobsProvider → List<JobSummary>
  projectJobsProvider(projectId) → PageResponse<JobSummary>
  jobDetailProvider(jobId) → QaJob
  activeJobIdProvider → String?

agent_providers.dart:
  jobOrchestratorProvider → JobOrchestrator
  jobProgressProvider → Stream<JobProgress>
  jobLifecycleProvider → Stream<JobLifecycleEvent>
  agentDispatchConfigProvider → AgentDispatchConfig

health_providers.dart:
  metricsApiProvider → MetricsApi
  teamMetricsProvider → TeamMetrics? (depends on selectedTeamIdProvider)

settings_providers.dart:
  claudeModelProvider → String (default model selection)
  maxConcurrentAgentsProvider → int
  agentTimeoutMinutesProvider → int
  sidebarCollapsedProvider → bool
```

---

## 12. Router & Navigation (24 Routes)

### GoRouter Configuration (`lib/router.dart`)

```
Initial Location:  /login
Auth Guard:        AuthNotifier (ChangeNotifier bridged from AuthService stream)
Redirect Logic:    Unauthenticated → /login, Authenticated on /login → /
Shell Route:       NavigationShell wraps all authenticated routes
Transitions:       NoTransitionPage for SPA feel (no page transitions)
```

### Route Table

| # | Path | Page | Params | Shell |
|---|------|------|--------|-------|
| 1 | `/login` | LoginPage | — | No |
| 2 | `/setup` | PlaceholderPage | — | No |
| 3 | `/` | HomePage | — | Yes |
| 4 | `/projects` | ProjectsPage | — | Yes |
| 5 | `/projects/:id` | ProjectDetailPage | id (path) | Yes |
| 6 | `/repos` | GitHubBrowserPage | — | Yes |
| 7 | `/audit` | AuditWizardPage | — | Yes |
| 8 | `/compliance` | ComplianceWizardPage | — | Yes |
| 9 | `/dependencies` | DependencyScanPage | — | Yes |
| 10 | `/bugs` | BugInvestigatorPage | jiraKey (query) | Yes |
| 11 | `/bugs/jira` | JiraBrowserPage | — | Yes |
| 12 | `/tasks` | TaskManagerPage | — | Yes |
| 13 | `/tech-debt` | TechDebtPage | — | Yes |
| 14 | `/health` | HealthDashboardPage | — | Yes |
| 15 | `/history` | JobHistoryPage | — | Yes |
| 16 | `/jobs/:id` | JobProgressPage | id (path) | Yes |
| 17 | `/jobs/:id/report` | JobReportPage | id (path) | Yes |
| 18 | `/jobs/:id/findings` | FindingsExplorerPage | id (path) | Yes |
| 19 | `/jobs/:id/tasks` | TaskListPage | id (path) | Yes |
| 20 | `/personas` | PersonasPage | — | Yes |
| 21 | `/personas/:id/edit` | PersonaEditorPage | id (path) | Yes |
| 22 | `/directives` | DirectivesPage | — | Yes |
| 23 | `/settings` | SettingsPage | — | Yes |
| 24 | `/admin` | AdminHubPage | — | Yes |

### Navigation Shell (`lib/widgets/shell/navigation_shell.dart`)

Sidebar sections:
- **NAVIGATE:** Home, Projects
- **SOURCE:** GitHub Browser
- **ANALYZE:** Audit, Compliance, Dependencies, Bug Investigator
- **MAINTAIN:** Jira Browser, Task Manager, Tech Debt
- **TOOLS:** Directives, Health Dashboard, History, Personas, Settings
- **ADMIN:** Admin Hub

Animated sidebar: collapsed (64px) ↔ expanded (240px)

---

## 13. Security Architecture

### Authentication Flow (Client-Side)

1. User submits email/password on LoginPage
2. AuthService calls `POST /api/v1/auth/login`
3. Server returns `AuthResponse` with `token` + `refreshToken` + `User`
4. Tokens stored in OS keychain via SecureStorageService
5. ApiClient's auth interceptor attaches `Authorization: Bearer {token}` to all requests
6. On 401, refresh interceptor attempts `POST /api/v1/auth/refresh` with refresh token
7. If refresh fails, `onAuthFailure` callback triggers logout

### Token Storage

```
Storage:     Flutter Secure Storage (macOS Keychain, Linux libsecret)
Keys:        codeops_auth_token, codeops_refresh_token, codeops_user_id, codeops_selected_team_id
Cleared on:  Logout (clearAll)
```

### RBAC (Client-Side Enforcement)

Roles displayed in UI: `owner`, `admin`, `member`, `viewer`
Admin Hub page checks `teamMembersProvider` for current user's role (OWNER/ADMIN only)
Server-side enforcement is the actual security boundary.

### Sensitive Data Handling

- **NEVER logged:** Tokens, passwords, request/response bodies, Authorization headers
- **Logged:** API paths, HTTP methods, status codes, correlation IDs, timing
- **Keychain:** Tokens stored via OS-native encryption

---

## 14. Error Handling

### ErrorPanel Widget (`lib/widgets/shared/error_panel.dart`)

```
ApiException mapping → User-facing messages:
  NetworkException     → "No Internet" / "Check your network connection"
  TimeoutException     → "Request Timed Out" / "The server took too long"
  ServerException      → "Server Error" / "Something went wrong on the server"
  UnauthorizedException → "Session Expired" / "Please log in again"
  ForbiddenException   → "Access Denied" / "You do not have permission"
  Default              → "Something Went Wrong" / "An unexpected error occurred"
```

All async providers use `.when(loading:, error:, data:)` pattern.
Error states show `ErrorPanel.fromException(error, onRetry: () => ref.invalidate(provider))`.

### ApiClient Error Mapping

Dio `DioException` → `ApiException` subtypes based on HTTP status code.
Network-level errors → `NetworkException` or `TimeoutException`.
No stack traces or raw error messages exposed to UI.

---

## 15. Theme & UI

### Dark Theme (`lib/theme/`)

```
Background:     #1A1B2E (deep navy)
Surface:        #222442 (card/panel)
Surface Variant: #2A2D52
Primary:        #6C63FF (indigo/purple)
Secondary:      #00D9FF (cyan)
Success:        #4ADE80 (green)
Warning:        #FBBF24 (amber)
Error:          #EF4444 (red)
Critical:       #DC2626 (deeper red)
Text Primary:   #E2E8F0
Text Secondary: #94A3B8
Text Tertiary:  #64748B
Border:         #334155
Divider:        #1E293B
```

**Typography:** Inter (primary), JetBrains Mono (code)
**Spacing:** 4px base
**Cards:** 0 elevation, 1px border, 8px border radius
**Buttons:** 8px border radius, 24×12 padding

### Semantic Color Maps
- `severityColors` → Severity → Color
- `jobStatusColors` → JobStatus → Color
- `agentTypeColors` → AgentType → Color (12 unique colors)
- `taskStatusColors` → TaskStatus → Color
- `debtStatusColors` → DebtStatus → Color
- `directiveCategoryColors` → DirectiveCategory → Color
- `vulnerabilityStatusColors` → VulnerabilityStatus → Color

---

## 16. Test Coverage

### Test Inventory

| Category | Files | Test Methods | % of Total |
|----------|-------|-------------|------------|
| Services | 43 | 685 | 34.1% |
| Widgets | 85 | 478 | 23.8% |
| Models | 17 | 344 | 17.1% |
| Providers | 18 | 269 | 13.4% |
| Pages | 20 | 137 | 6.8% |
| Utils | 5 | 39 | 1.9% |
| Integration (test/) | 1 | 20 | 1.0% |
| Database | 2 | 13 | 0.6% |
| Router | 1 | 13 | 0.6% |
| Integration (root) | 5 | 9 | 0.4% |
| **TOTAL** | **197** | **2,007** | **100%** |

### Test Framework
- **Framework:** Flutter Test (dart:test)
- **Mocking:** mocktail 1.0.4 (39+ test files use Mock classes)
- **Widget Testing:** `testWidgets()` with `ProviderScope(overrides:)`
- **Provider Testing:** Direct `ProviderContainer` usage
- **Integration Testing:** `IntegrationTestWidgetsFlutterBinding` with mocked APIs

### Test Patterns
```dart
// Service test pattern
test('login returns user on success', () async {
  when(() => mockClient.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
      .thenAnswer((_) async => Response(...));
  final user = await authService.login('test@test.com', 'pass');
  expect(user.email, 'test@test.com');
});

// Widget test pattern
testWidgets('shows error panel on failure', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [myJobsProvider.overrideWith((ref) => throw NetworkException(...))],
      child: MaterialApp(home: RecentActivity()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('No Internet'), findsOneWidget);
});
```

### Top 5 Test-Heavy Files
1. `enums_test.dart` — 109 methods
2. `enums_alignment_test.dart` — 96 methods
3. `jira_mapper_test.dart` — 46 methods
4. `report_parser_test.dart` — 38 methods
5. `jira_models_test.dart` — 38 methods

### Integration Tests (5 files)
- `dependency_flow_test.dart`
- `directive_flow_test.dart`
- `health_dashboard_flow_test.dart`
- `persona_flow_test.dart`
- `tech_debt_flow_test.dart`

---

## 17. Infrastructure & Deployment

### Platform Configuration
- **macOS:** `macos/Runner/Info.plist`, `macos/Podfile`
- **Linux:** `linux/` directory (standard Flutter Linux setup)
- **Min macOS Deployment Target:** 10.15
- **App Sandbox:** Enabled (network client only in release)
- **CocoaPods:** `inhibit_all_warnings!` suppresses third-party warnings

### No CI/CD Configuration
No `.github/workflows/`, `Jenkinsfile`, or CI config files detected.

### No Dockerfile
This is a desktop application, not containerized.

---

## 18. Cross-Cutting Patterns & Conventions

### Naming Conventions
- **Files:** snake_case (e.g., `auth_service.dart`, `job_providers.dart`)
- **Classes:** PascalCase (e.g., `AuthService`, `JobOrchestrator`)
- **Providers:** camelCase with `Provider` suffix (e.g., `teamApiProvider`, `selectedTeamIdProvider`)
- **API paths:** kebab-case (e.g., `/assigned-to-me`, `/tech-debt`)
- **Enum JSON values:** camelCase (e.g., `codeQuality`, `bugInvestigate`)

### Architecture Patterns
- **Layered:** Pages → Providers → Services → API Client → Server
- **No direct HTTP calls from UI** — all go through providers → API services
- **Singleton services** via `Provider` (never `new`'d inline)
- **Immutable state** via Riverpod providers and copyWith patterns
- **Master-detail layouts** for list+detail views (directives, findings, tasks)
- **Wizard pattern** for multi-step flows (audit, compliance, bug investigator)
- **Error boundary** via `ErrorPanel.fromException` with retry

### Pagination Pattern
Server returns: `{"content": [...], "page": N, "size": N, "totalElements": N, "totalPages": N, "last": bool}`
Client wrapper: `PageResponse<T>` generic class with factory `fromJson(map, elementParser)`

### DartDoc Coverage
- **100% file-level DartDoc** (193/193 lib files have `///` or `library;` documentation)
- **Every public class and method** has DartDoc comments
- **Every enum value** has documentation

### Constants
All in `lib/utils/constants.dart` — no magic numbers or strings in other files.

### Code Quality
- Zero `debugPrint()` calls (removed, replaced with `log.d()`)
- Only `print()` in `log_service.dart` (intentional, with `// ignore: avoid_print`)
- Zero TODO/FIXME/HACK markers in production code
- Strict analyzer: `strict-casts`, `strict-inference`, `strict-raw-types`

---

## 19. Known Issues & Technical Debt

```bash
# Search results:
grep -rn "TODO|FIXME|HACK|XXX|WORKAROUND|TEMPORARY" lib/ → 0 results
```

No TODO/FIXME markers exist in production code.

**Known architectural observations (not actionable TODOs):**
1. `selectedTeamIdProvider` starts null — if team auto-selection fails, dashboard shows empty
2. VCS models use manual JSON parsing (not codegen) — intentional for GitHub API compatibility
3. No offline-first architecture — app requires server connectivity for most operations
4. Integration test coverage is minimal (9 methods across 5 files)

---

## 20. OpenAPI Specification

**Not applicable.** CodeOps-Client is a Flutter desktop client application, not a server. The API specification lives in the CodeOps-Server repository. The client's API service layer (`lib/services/cloud/`) implements the client-side SDK for that server API, documented in Section 9.

---

## 21. Quality Assessment Scorecard

### 21a. Security (adapted for client app)

| Check | Score | Notes |
|-------|-------|-------|
| SEC-01 Auth on all API calls | 2 | ApiClient interceptor adds JWT to every request |
| SEC-02 No hardcoded secrets | 2 | No passwords/tokens in source; secure storage used |
| SEC-03 Secure token storage | 2 | OS keychain (macOS Keychain, Linux libsecret) |
| SEC-04 Token refresh on expiry | 2 | Automatic 401 → refresh → retry interceptor |
| SEC-05 Logout clears all data | 2 | clearAll() on secure storage + clearAllTables() on DB |
| SEC-06 No sensitive data in logs | 2 | Never logs bodies, tokens, passwords |
| SEC-07 App sandbox enabled | 2 | macOS app sandbox in entitlements |
| SEC-08 SSRF N/A (client app) | 1 | GitHub/Jira URLs from user config (validated by server) |
| SEC-09 Token never exposed to UI | 2 | Tokens in interceptors only, never in widget state |
| SEC-10 .env not committed | 2 | No .env files exist |

**Security Score: 19/20 (95%)**

### 21b. Data Integrity (adapted for client app)

| Check | Score | Notes |
|-------|-------|-------|
| DAT-01 Enum serialization consistent | 2 | All enums have toJson/fromJson with explicit maps |
| DAT-02 Paginated response handling | 2 | PageResponse<T> for all paginated endpoints |
| DAT-03 Type-safe JSON parsing | 2 | @JsonSerializable with strict types |
| DAT-04 Null safety | 2 | Full null safety, nullable fields explicit |
| DAT-05 Local DB schema versioned | 2 | Drift schema version 4 with migration strategy |
| DAT-06 DB cleared on logout | 2 | clearAllTables() prevents data leakage |
| DAT-07 No unbounded lists from server | 1 | Some endpoints fetch without pagination (getTeams, getMyJobs) |
| DAT-08 Timestamps preserved | 2 | DateTime? fields with ISO 8601 parsing |

**Data Integrity Score: 15/16 (94%)**

### 21c. API Quality (adapted for client SDK)

| Check | Score | Notes |
|-------|-------|-------|
| API-01 Consistent error handling | 2 | Sealed ApiException hierarchy, ErrorPanel mapping |
| API-02 Error messages sanitized | 2 | No raw exceptions shown to user |
| API-03 Typed API methods | 2 | Every endpoint returns typed model (not dynamic) |
| API-04 Pagination support | 2 | PageResponse<T> with page/size params |
| API-05 Correlation IDs | 2 | X-Correlation-ID header on every request |
| API-06 Consistent HTTP method usage | 2 | GET=read, POST=create, PUT=update, DELETE=delete |
| API-07 Retry on auth failure | 2 | Automatic token refresh interceptor |
| API-08 No inline Dio instances | 1 | JiraService and GitHubProvider use separate Dio (by design) |

**API Quality Score: 15/16 (94%)**

### 21d. Code Quality

| Check | Score | Notes |
|-------|-------|-------|
| CQ-01 No TODO/FIXME/HACK | 2 | Zero markers in production code |
| CQ-02 Consistent exception hierarchy | 2 | 10-class sealed hierarchy |
| CQ-03 Constants centralized | 2 | All in constants.dart (225 lines) |
| CQ-04 No print/debugPrint | 2 | Only in LogService (annotated) |
| CQ-05 Structured logging | 2 | LogService singleton with 6 levels |
| CQ-06 No inline HTTP clients | 2 | All via providers (ApiClient, separate Dio) |
| CQ-07 DartDoc on classes | 2 | 193/193 files (100%) |
| CQ-08 DartDoc on public methods | 2 | All public methods documented |
| CQ-09 Strict analyzer config | 2 | strict-casts, strict-inference, strict-raw-types |
| CQ-10 Clean separation of concerns | 2 | Pages → Providers → Services → API Client |

**Code Quality Score: 20/20 (100%)**

### 21e. Test Quality

| Check | Score | Notes |
|-------|-------|-------|
| TST-01 Unit test files exist | 2 | 192 test files |
| TST-02 Integration tests exist | 1 | 5 integration tests (minimal) |
| TST-03 Mocking framework used | 2 | mocktail in 39+ files |
| TST-04 Source-to-test ratio | 2 | 197 test files / 193 source files = 1.02:1 |
| TST-05 Test method count | 2 | 2,007 test methods |
| TST-06 Widget tests present | 2 | 85 widget test files (478 methods) |
| TST-07 Provider tests present | 2 | 18 provider test files (269 methods) |
| TST-08 Page tests present | 1 | 20 page test files (137 methods, could be deeper) |
| TST-09 Model/enum tests present | 2 | 17 model test files (344 methods, 205 enum-focused) |
| TST-10 Test patterns consistent | 2 | ProviderScope overrides, mocktail, group/test |

**Test Quality Score: 18/20 (90%)**

### 21f. Infrastructure

| Check | Score | Notes |
|-------|-------|-------|
| INF-01 macOS entitlements configured | 2 | Sandbox + network client |
| INF-02 No exposed secrets in config | 2 | No .env files, no hardcoded credentials |
| INF-03 Multi-platform support | 1 | macOS primary, Linux configured, Windows not yet |
| INF-04 Structured logging to file | 2 | Daily rotation, 7-day retention |
| INF-05 CI/CD pipeline | 0 | **BLOCKING: No CI/CD configuration** |
| INF-06 Code generation automated | 2 | build_runner for Drift, JSON serializable |

**Infrastructure Score: 9/12 (75%)**

### Quality Scorecard Summary

```
╔══════════════════════════════════════════════════════════════╗
║                 QUALITY SCORECARD SUMMARY                    ║
╠══════════════════════════╦═══════╦═══════╦═══════════════════╣
║ Category                 ║ Score ║  Max  ║ Percentage        ║
╠══════════════════════════╬═══════╬═══════╬═══════════════════╣
║ Security                 ║   19  ║   20  ║   95%             ║
║ Data Integrity           ║   15  ║   16  ║   94%             ║
║ API Quality              ║   15  ║   16  ║   94%             ║
║ Code Quality             ║   20  ║   20  ║  100%             ║
║ Test Quality             ║   18  ║   20  ║   90%             ║
║ Infrastructure           ║    9  ║   12  ║   75%             ║
╠══════════════════════════╬═══════╬═══════╬═══════════════════╣
║ OVERALL                  ║   96  ║  104  ║   92%             ║
╚══════════════════════════╩═══════╩═══════╩═══════════════════╝

Grade: A (85-100%) | B (70-84%) | C (55-69%) | D (40-54%) | F (<40%)
Overall Grade: A
```

**Blocking Issue:**
- **INF-05:** No CI/CD pipeline. Add GitHub Actions workflow for `flutter analyze`, `flutter test`, and build verification.

**Areas for Improvement:**
- **TST-02:** Integration tests are minimal (5 files, 9 methods). Expand to cover auth flow, job lifecycle, and data sync end-to-end.
- **INF-03:** Windows platform not configured yet.

---

## 22. Local Database — Schema Audit

The app uses Drift SQLite, not a server database. The schema is defined in code (`lib/database/tables.dart`) and auto-created by Drift.

### Schema Version: 4

18 tables (all local cache of server data):

| Table | Columns | Primary Key | Purpose |
|-------|---------|-------------|---------|
| Users | 7 | id | User profiles |
| Teams | 9 | id | Teams |
| Projects | 18 | id | Projects with GitHub/Jira config |
| QaJobs | 21 | id | QA job records |
| AgentRuns | 12 | id | Agent execution records |
| Findings | 17 | id | Audit findings |
| RemediationTasks | 13 | id | Fix tasks |
| Personas | 14 | id | Agent personas |
| Directives | 13 | id | QA directives |
| TechDebtItems | 13 | id | Tech debt items |
| DependencyScans | 7 | id | Dependency scans |
| DependencyVulnerabilities | 10 | id | Vulnerabilities |
| HealthSnapshots | 9 | id | Health history |
| ComplianceItems | 10 | id | Compliance results |
| Specifications | 6 | id | Uploaded specs |
| ClonedRepos | 5 | repoFullName | Local repo registry |
| SyncMetadata | 3 | syncTableName | Sync tracking |

All string/text columns, no foreign key constraints enforced at DB level (application-level only).

---

## 23. Message Broker

No message broker (Kafka, RabbitMQ, SQS/SNS) detected in this client application.

The CodeOps-Server backend uses Kafka, but this client communicates with the server via REST API only.

---

## 24. Cache Layer

No Redis or caching layer detected in this client application.

Local caching is handled by the Drift SQLite database (Section 22), which caches server responses for offline access via the SyncService.

---

## 25. Environment Variable Inventory

This Flutter desktop application does not use environment variables in the traditional sense. Configuration is embedded in `lib/utils/constants.dart`.

| Setting | Location | Default | Purpose |
|---------|----------|---------|---------|
| API Base URL | constants.dart | `http://localhost:8090` | Backend server URL |
| API Prefix | constants.dart | `/api/v1` | API path prefix |
| Window Size | constants.dart | 1440×900 | Default window dimensions |
| Min Window Size | constants.dart | 1024×700 | Minimum window dimensions |
| Max Concurrent Agents | constants.dart | 3 (range 1-6) | Agent parallelism |
| Agent Timeout | constants.dart | 30 min (range 5-60) | Agent execution timeout |
| Pass Threshold | constants.dart | 80 | Health score pass threshold |
| Warn Threshold | constants.dart | 60 | Health score warn threshold |

**No `.env` files exist.** Configuration is compile-time only.

**Production deployment note:** API Base URL would need to be changed via `--dart-define=API_BASE_URL=https://api.codeops.io` at build time, or the constant updated.

---

## 26. Inter-Service Communication Map

```
=== SERVICE DEPENDENCY MAP ===

  ┌────────────────────┐
  │   CodeOps-Client   │
  │   (Flutter macOS)  │
  └──────┬─────────────┘
         │
    Outbound calls:
         ├──→ CodeOps-Server (REST, JWT Bearer auth, http://localhost:8090/api/v1)
         │    All 174 API methods via 16 domain services
         │
         ├──→ GitHub API (REST, PAT Bearer, https://api.github.com)
         │    GitHubProvider: orgs, repos, branches, PRs, commits, workflows, releases
         │
         ├──→ Jira Cloud API (REST, Basic auth, https://{instance}.atlassian.net)
         │    JiraService: issues, comments, transitions, projects, sprints
         │
         ├──→ Local Git CLI (subprocess via ProcessManager)
         │    GitService: clone, pull, push, checkout, diff, log, stash, tag
         │
         └──→ Claude Code CLI (subprocess via AgentDispatcher)
              12 agent types dispatched as Claude Code subprocesses

    Local Infrastructure:
         ├──→ SQLite (Drift, ~/.codeops/codeops.db)
         ├──→ OS Keychain (flutter_secure_storage)
         └──→ Log Files (~/.codeops/logs/)

    Inbound from:
         └──← No inbound — this is a desktop client application
```

---

## Appendix A: File Metrics

```
Source files (lib/):           193
Lines of Dart code:            50,257
Test files:                    197
Test methods:                  2,007
DartDoc coverage:              100%
Providers:                     230
API methods:                   174
Routes:                        24
Enum types:                    24
Model classes:                 50+
Database tables:               18
Widget files:                  85+
```
