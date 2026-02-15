# CodeOps-Client Codebase Audit

**Service:** CodeOps-Client
**Type:** Flutter/Dart Desktop Application (macOS, Windows, Linux)
**Audit Date:** 2026-02-14
**Auditor:** Claude Opus 4.6

---

## Table of Contents

1. [Project Identity](#1-project-identity)
2. [Directory Structure](#2-directory-structure)
3. [Build & Run](#3-build--run)
4. [Configuration & Environment](#4-configuration--environment)
5. [Entry Point & Application Bootstrap](#5-entry-point--application-bootstrap)
6. [Database Schema](#6-database-schema)
7. [Models / DTOs](#7-models--dtos)
8. [Enumerations](#8-enumerations)
9. [Services / Business Logic](#9-services--business-logic)
10. [State Management (Riverpod Providers)](#10-state-management-riverpod-providers)
11. [Consumed REST API Surface](#11-consumed-rest-api-surface)
12. [Inbound REST API](#12-inbound-rest-api)
13. [Navigation & Routing](#13-navigation--routing)
14. [Pages (Screens)](#14-pages-screens)
15. [Widgets](#15-widgets)
16. [Theme & Styling](#16-theme--styling)
17. [Utilities & Helpers](#17-utilities--helpers)
18. [Error Handling & Exceptions](#18-error-handling--exceptions)
19. [Authentication & Authorization](#19-authentication--authorization)
20. [External Integrations](#20-external-integrations)
21. [Event / Messaging System](#21-event--messaging-system)
22. [Infrastructure / Docker](#22-infrastructure--docker)
23. [OpenAPI / Swagger](#23-openapi--swagger)
24. [Tests](#24-tests)
25. [Cross-Cutting Concerns](#25-cross-cutting-concerns)
26. [Quality Scorecard](#26-quality-scorecard)

---

## 1. Project Identity

| Field | Value |
|-------|-------|
| **Name** | CodeOps-Client |
| **Description** | Desktop client for the CodeOps AI-Powered Software Maintenance Platform. Orchestrates multi-agent Claude Code QA jobs, manages projects via a REST API backend, and provides GitHub/Jira integrations. |
| **Language** | Dart 3.6+ |
| **Framework** | Flutter 3.27+ |
| **Platform targets** | macOS, Windows, Linux (desktop only) |
| **SDK constraint** | `>=3.6.0 <4.0.0` |
| **Flutter constraint** | `>=3.27.0` |
| **State management** | Riverpod 2.x (manual providers, no `@riverpod` codegen) |
| **Navigation** | GoRouter 14.8.1 |
| **HTTP client** | Dio 5.7.0 (centralized ApiClient) |
| **Local database** | Drift 2.22.1 (SQLite) |
| **Code generation** | JsonSerializable (models), Drift (database) |
| **Auth mechanism** | JWT Bearer tokens, FlutterSecureStorage |
| **Package manager** | pub (pubspec.yaml) |
| **Backend API base** | `http://localhost:8090/api/v1` |

### Key Dependencies (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `go_router` | ^14.8.1 | Declarative routing |
| `drift` | ^2.22.1 | SQLite ORM / local cache |
| `sqlite3_flutter_libs` | ^0.5.28 | SQLite native bindings |
| `dio` | ^5.7.0 | HTTP client |
| `flutter_secure_storage` | ^9.2.3 | Keychain/keystore token storage |
| `window_manager` | ^0.4.3 | Desktop window configuration |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `fl_chart` | ^0.70.2 | Charts and graphs |
| `pdf` | ^3.11.2 | PDF document generation |
| `archive` | ^4.0.2 | ZIP archive creation |
| `file_picker` | ^8.1.7 | Native file save dialogs |
| `intl` | ^0.19.0 | Date/number formatting |
| `path` | ^1.9.1 | Path manipulation |
| `url_launcher` | ^6.3.1 | Open URLs in browser |
| `package_info_plus` | ^8.1.3 | App version info |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.14 | Code generation runner |
| `json_serializable` | ^6.9.2 | JSON code generation |
| `drift_dev` | ^2.22.1 | Drift code generation |
| `flutter_lints` | ^5.0.0 | Lint rules |
| `mocktail` | ^1.0.4 | Mocking framework for tests |

---

## 2. Directory Structure

```
CodeOps-Client/
  lib/
    main.dart                     # App entry point
    app.dart                      # Root MaterialApp.router widget
    router.dart                   # GoRouter with 24 routes + AuthNotifier
    database/
      database.dart               # Drift database class, migrations, singleton
      database.g.dart             # Generated Drift code
      tables.dart                 # 17 Drift table definitions
    models/
      agent_run.dart              # AgentRun model
      compliance_item.dart        # ComplianceItem model
      dependency_scan.dart        # DependencyScan, DependencyVulnerability
      directive.dart              # Directive, ProjectDirective
      enums.dart                  # 22 enums with JSON converters
      finding.dart                # Finding model
      health_snapshot.dart        # 12 models (HealthSnapshot, PageResponse<T>, AuthResponse, etc.)
      jira_models.dart            # 21 Jira-specific model classes
      persona.dart                # Persona model
      project.dart                # Project model
      qa_job.dart                 # QaJob, JobSummary
      remediation_task.dart       # RemediationTask model
      specification.dart          # Specification model
      team.dart                   # Team, TeamMember, Invitation
      tech_debt_item.dart         # TechDebtItem model
      user.dart                   # User model
      vcs_models.dart             # 16 VCS model classes + 2 enums
    pages/
      admin_hub_page.dart
      audit_wizard_page.dart
      bug_investigator_page.dart
      compliance_wizard_page.dart
      dependency_scan_page.dart
      directives_page.dart
      findings_explorer_page.dart
      github_browser_page.dart
      health_dashboard_page.dart
      home_page.dart
      jira_browser_page.dart
      job_history_page.dart
      job_progress_page.dart
      job_report_page.dart
      login_page.dart
      persona_editor_page.dart
      personas_page.dart
      placeholder_page.dart
      project_detail_page.dart
      projects_page.dart
      settings_page.dart
      task_list_page.dart
      task_manager_page.dart
      tech_debt_page.dart
    providers/
      admin_providers.dart
      agent_providers.dart
      auth_providers.dart
      compliance_providers.dart
      dependency_providers.dart
      directive_providers.dart
      finding_providers.dart
      github_providers.dart
      health_providers.dart
      jira_providers.dart
      job_providers.dart
      persona_providers.dart
      project_providers.dart
      report_providers.dart
      settings_providers.dart
      task_providers.dart
      tech_debt_providers.dart
      user_providers.dart
      wizard_providers.dart
    services/
      agent/
        persona_manager.dart       # Prompt assembly (persona + directives + context)
        report_parser.dart         # Markdown report -> structured data
        task_generator.dart        # Findings -> remediation tasks + prompts
      analysis/
        dependency_scanner.dart    # Dependency health score + report generation
        health_calculator.dart     # Composite health score from agent runs
        tech_debt_tracker.dart     # Debt scoring, priority matrix, reports
      auth/
        auth_service.dart          # Login, register, refresh, logout
        secure_storage.dart        # FlutterSecureStorage wrapper
      cloud/
        admin_api.dart             # Admin endpoints
        api_client.dart            # Centralized Dio wrapper with interceptors
        api_exceptions.dart        # Sealed ApiException hierarchy
        compliance_api.dart        # Compliance spec/item endpoints
        dependency_api.dart        # Dependency scan/vulnerability endpoints
        directive_api.dart         # Directive CRUD endpoints
        finding_api.dart           # Finding CRUD endpoints
        health_monitor_api.dart    # Health schedule/snapshot endpoints
        integration_api.dart       # GitHub/Jira connections + all domain endpoints
        job_api.dart               # Job/AgentRun/BugInvestigation endpoints
        metrics_api.dart           # Team/project metrics endpoints
        persona_api.dart           # Persona CRUD endpoints
        project_api.dart           # Project CRUD endpoints
        report_api.dart            # Report upload/download endpoints
        task_api.dart              # Remediation task endpoints
        team_api.dart              # Team/member/invitation endpoints
        tech_debt_api.dart         # Tech debt CRUD endpoints
        user_api.dart              # User profile endpoints
      data/
        sync_service.dart          # Cloud-to-local project sync
      integration/
        export_service.dart        # Markdown/PDF/ZIP/CSV export
      jira/
        jira_mapper.dart           # Jira ADF <-> Markdown + model mapping
        jira_service.dart          # Direct Jira Cloud REST API client
      orchestration/
        agent_dispatcher.dart      # Claude Code subprocess spawner w/ concurrency
        agent_monitor.dart         # Process output collection + timeout enforcement
        bug_investigation_orchestrator.dart  # Jira -> bug investigation job flow
        job_orchestrator.dart      # 10-step job lifecycle coordinator
        progress_aggregator.dart   # Real-time multi-agent progress stream
        vera_manager.dart          # Vera consolidation engine (dedup, scoring, summary)
      platform/
        claude_code_detector.dart  # Claude Code CLI detection + version validation
        process_manager.dart       # Subprocess lifecycle management
      vcs/
        git_service.dart           # Git CLI wrapper (20+ operations)
        github_provider.dart       # GitHub REST API v3 implementation
        repo_manager.dart          # Local cloned repo registry
        vcs_provider.dart          # Abstract VCS provider interface
    theme/
      app_theme.dart              # AppTheme.darkTheme (Material 3)
      colors.dart                 # CodeOpsColors constants + severity/status maps
      typography.dart             # CodeOpsTypography (Inter + JetBrains Mono)
    utils/
      constants.dart              # AppConstants (60+ config values)
      date_utils.dart             # Date formatting helpers
      file_utils.dart             # File size/extension/name helpers
      string_utils.dart           # String manipulation helpers
    widgets/
      shell/
        navigation_shell.dart      # Sidebar + top bar shell
      (87+ widget files across subdirectories)
  assets/
    personas/                     # Built-in agent persona markdown files
  test/                           # Test files
  pubspec.yaml                    # Package manifest
  analysis_options.yaml           # Lint configuration
```

---

## 3. Build & Run

### Prerequisites

- Flutter SDK 3.27+ (`flutter --version`)
- Dart SDK 3.6+
- Claude Code CLI installed and on PATH (for agent dispatch)
- CodeOps-Server running on `localhost:8090`

### Install Dependencies

```bash
cd CodeOps-Client
flutter pub get
```

### Code Generation (after model/database changes)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run (macOS)

```bash
flutter run -d macos
```

### Run (Linux)

```bash
flutter run -d linux
```

### Run (Windows)

```bash
flutter run -d windows
```

### Run Tests

```bash
flutter test
```

### Build Release

```bash
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

---

## 4. Configuration & Environment

### AppConstants (`lib/utils/constants.dart`)

All configuration is centralized in `AppConstants` as `static const` values. There are no `.env` files or runtime environment variable lookups beyond platform environment (`HOME` for repo paths).

| Constant | Value | Purpose |
|----------|-------|---------|
| `apiBaseUrl` | `'http://localhost:8090'` | CodeOps server base URL |
| `apiPrefix` | `'/api/v1'` | API path prefix |
| `maxTeamMembers` | `50` | Team member limit |
| `maxProjectsPerTeam` | `100` | Project limit per team |
| `jwtExpiryHours` | `24` | Token lifetime |
| `refreshTokenExpiryDays` | `30` | Refresh token lifetime |
| `defaultClaudeModel` | `'claude-sonnet-4-20250514'` | Default Claude model |
| `defaultClaudeModelForDispatch` | `'claude-sonnet-4-5-20250514'` | Model for agent dispatch |
| `minClaudeCodeVersion` | `'1.0.0'` | Minimum Claude CLI version |
| `defaultMaxConcurrentAgents` | `3` | Max parallel agents |
| `defaultAgentTimeoutMinutes` | `30` | Agent timeout |
| `defaultMaxTurns` | `50` | Max Claude CLI turns |
| `healthScoreGreenThreshold` | `80` | Green health threshold |
| `healthScoreYellowThreshold` | `60` | Yellow health threshold |
| `securityAgentWeight` | `1.5` | Security agent weight multiplier |
| `architectureAgentWeight` | `1.5` | Architecture agent weight multiplier |
| `defaultAgentWeight` | `1.0` | Default agent weight |
| `criticalScoreReduction` | `20.0` | Points deducted per critical finding |
| `highScoreReduction` | `10.0` | Points deducted per high finding |
| `mediumScoreReduction` | `3.0` | Points deducted per medium finding |
| `lowScoreReduction` | `1.0` | Points deducted per low finding |
| `deduplicationLineThreshold` | `5` | Lines proximity for dedup |
| `deduplicationTitleSimilarityThreshold` | `0.8` | Title similarity for dedup |
| `maxExportFilenameLength` | `100` | Export filename max chars |
| `maxAgentTypes` | `12` | Total agent type count |
| `maxSpecsPerJob` | `10` | Spec upload limit |
| `minHealthScore` | `0` | Health score floor |
| `maxHealthScore` | `100` | Health score ceiling |

#### Secure Storage Keys

| Key | Purpose |
|-----|---------|
| `codeops_auth_token` | JWT access token |
| `codeops_refresh_token` | Refresh token |
| `codeops_user_id` | Current user UUID |
| `codeops_team_id` | Selected team UUID |

#### S3 Prefix Constants

| Constant | Value |
|----------|-------|
| `s3SummaryPrefix` | `'reports/summary/'` |
| `s3AgentPrefix` | `'reports/agents/'` |
| `s3SpecPrefix` | `'specs/'` |

### Window Configuration (main.dart)

| Setting | Value |
|---------|-------|
| Default size | 1440 x 900 |
| Minimum size | 1024 x 700 |
| Title | `'CodeOps'` |
| Title bar style | Hidden |
| Center on launch | `true` |
| Skip task bar | `false` |

---

## 5. Entry Point & Application Bootstrap

### `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(1024, 700),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'CodeOps',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: CodeOpsApp()));
}
```

- Initializes `WidgetsBinding` and `WindowManager`
- Configures window with hidden title bar, 1440x900 default, 1024x700 minimum
- Wraps the entire app in Riverpod `ProviderScope`

### `lib/app.dart`

```dart
class CodeOpsApp extends ConsumerWidget {
  const CodeOpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CodeOps',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- Uses `MaterialApp.router` with GoRouter
- Dark theme only (no light theme)
- `ConsumerWidget` for Riverpod access

---

## 6. Database Schema

### Technology

- **ORM:** Drift 2.22.1
- **Engine:** SQLite (via `sqlite3_flutter_libs`)
- **File location:** `getApplicationSupportDirectory()/codeops.db`
- **Schema version:** 2
- **Migration:** v1 -> v2 creates `clonedRepos` table

### Singleton Access

```dart
CodeOpsDatabase get database => _database ??= CodeOpsDatabase();
```

### Tables (17 total) - `lib/database/tables.dart`

#### Users

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| email | String | text | No | |
| displayName | String | text | No | |
| avatarUrl | String? | text | Yes | |
| isActive | bool | boolean | Yes | Default `true` |
| lastLoginAt | DateTime? | dateTime | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### Teams

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| name | String | text | No | |
| description | String? | text | Yes | |
| ownerId | String | text | No | |
| memberCount | int? | integer | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### Projects

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| teamId | String | text | No | |
| name | String | text | No | |
| description | String? | text | Yes | |
| githubConnectionId | String? | text | Yes | |
| repoUrl | String? | text | Yes | |
| repoFullName | String? | text | Yes | e.g. `owner/repo` |
| defaultBranch | String? | text | Yes | |
| jiraConnectionId | String? | text | Yes | |
| jiraProjectKey | String? | text | Yes | |
| techStack | String? | text | Yes | |
| healthScore | int? | integer | Yes | 0-100 |
| isArchived | bool | boolean | No | Default `false` |

#### QaJobs

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| projectId | String | text | No | |
| mode | String | text | No | JobMode enum as text |
| status | String | text | No | JobStatus enum as text |
| name | String? | text | Yes | |
| branch | String? | text | Yes | |
| overallResult | String? | text | Yes | JobResult enum |
| healthScore | int? | integer | Yes | |
| totalFindings | int? | integer | Yes | |
| criticalCount | int? | integer | Yes | |
| highCount | int? | integer | Yes | |
| summaryReportS3Key | String? | text | Yes | |
| createdAt | DateTime? | dateTime | Yes | |
| startedAt | DateTime? | dateTime | Yes | |
| completedAt | DateTime? | dateTime | Yes | |

#### AgentRuns

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| jobId | String | text | No | |
| agentType | String | text | No | AgentType enum |
| status | String | text | No | AgentStatus enum |
| result | String? | text | Yes | AgentResult enum |
| reportS3Key | String? | text | Yes | |
| score | int? | integer | Yes | |
| findingsCount | int? | integer | Yes | |
| criticalCount | int? | integer | Yes | |
| highCount | int? | integer | Yes | |
| startedAt | DateTime? | dateTime | Yes | |
| completedAt | DateTime? | dateTime | Yes | |

#### Findings

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| jobId | String | text | No | |
| agentType | String | text | No | AgentType enum |
| severity | String | text | No | Severity enum |
| title | String | text | No | |
| description | String? | text | Yes | |
| filePath | String? | text | Yes | |
| lineNumber | int? | integer | Yes | |
| recommendation | String? | text | Yes | |
| evidence | String? | text | Yes | |
| effortEstimate | String? | text | Yes | Effort enum |
| debtCategory | String? | text | Yes | DebtCategory enum |
| status | String | text | No | FindingStatus enum |
| createdAt | DateTime? | dateTime | Yes | |

#### RemediationTasks

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| jobId | String | text | No | |
| taskNumber | int | integer | No | |
| title | String | text | No | |
| description | String? | text | Yes | |
| promptMd | String? | text | Yes | |
| promptS3Key | String? | text | Yes | |
| findingIds | String? | text | Yes | JSON array string |
| priority | String? | text | Yes | Priority enum |
| status | String | text | No | TaskStatus enum |
| assignedTo | String? | text | Yes | |
| jiraKey | String? | text | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### Personas

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| name | String | text | No | |
| agentType | String? | text | Yes | AgentType enum |
| description | String? | text | Yes | |
| contentMd | String? | text | Yes | Full markdown content |
| scope | String | text | No | Scope enum |
| teamId | String? | text | Yes | |
| createdBy | String? | text | Yes | |
| isDefault | bool? | boolean | Yes | |
| version | int? | integer | Yes | |
| createdAt | DateTime? | dateTime | Yes | |
| updatedAt | DateTime? | dateTime | Yes | |

#### Directives

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| name | String | text | No | |
| description | String? | text | Yes | |
| contentMd | String? | text | Yes | |
| category | String? | text | Yes | DirectiveCategory enum |
| scope | String | text | No | DirectiveScope enum |
| teamId | String? | text | Yes | |
| projectId | String? | text | Yes | |
| createdBy | String? | text | Yes | |
| version | int? | integer | Yes | |
| createdAt | DateTime? | dateTime | Yes | |
| updatedAt | DateTime? | dateTime | Yes | |

#### TechDebtItems

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| projectId | String | text | No | |
| category | String | text | No | DebtCategory enum |
| title | String | text | No | |
| description | String? | text | Yes | |
| filePath | String? | text | Yes | |
| effortEstimate | String? | text | Yes | Effort enum |
| businessImpact | String? | text | Yes | BusinessImpact enum |
| status | String | text | No | DebtStatus enum |
| firstDetectedJobId | String? | text | Yes | |
| resolvedJobId | String? | text | Yes | |
| createdAt | DateTime? | dateTime | Yes | |
| updatedAt | DateTime? | dateTime | Yes | |

#### DependencyScans

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| projectId | String | text | No | |
| jobId | String? | text | Yes | |
| manifestFile | String? | text | Yes | |
| totalDependencies | int? | integer | Yes | |
| outdatedCount | int? | integer | Yes | |
| vulnerableCount | int? | integer | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### DependencyVulnerabilities

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| scanId | String | text | No | |
| dependencyName | String | text | No | |
| currentVersion | String? | text | Yes | |
| fixedVersion | String? | text | Yes | |
| cveId | String? | text | Yes | |
| severity | String | text | No | Severity enum |
| description | String? | text | Yes | |
| status | String | text | No | VulnerabilityStatus enum |
| createdAt | DateTime? | dateTime | Yes | |

#### HealthSnapshots

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| projectId | String | text | No | |
| healthScore | int | integer | No | |
| jobId | String? | text | Yes | |
| findingsBySeverity | String? | text | Yes | JSON string |
| techDebtScore | int? | integer | Yes | |
| dependencyScore | int? | integer | Yes | |
| testCoveragePercent | double? | real | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### ComplianceItems

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| jobId | String | text | No | |
| requirement | String | text | No | |
| specId | String? | text | Yes | |
| status | String | text | No | ComplianceStatus enum |
| evidence | String? | text | Yes | |
| agentType | String? | text | Yes | AgentType enum |
| notes | String? | text | Yes | |
| createdAt | DateTime? | dateTime | Yes | |

#### Specifications

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | String | text | No | Primary key |
| jobId | String | text | No | |
| name | String | text | No | |
| specType | String? | text | Yes | SpecType enum |
| s3Key | String | text | No | |
| createdAt | DateTime? | dateTime | Yes | |

#### ClonedRepos (added in schema v2)

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| id | int | integer | No | Auto-increment PK |
| repoFullName | String | text | No | Unique constraint |
| localPath | String | text | No | Filesystem path |
| projectId | String? | text | Yes | |
| clonedAt | DateTime? | dateTime | Yes | |
| lastAccessedAt | DateTime? | dateTime | Yes | |

#### SyncMetadata

| Column | Dart Type | Drift Type | Nullable | Notes |
|--------|-----------|------------|----------|-------|
| syncTableName | String | text | No | Primary key |
| lastSyncAt | DateTime | dateTime | No | |

### Database Operations

```dart
/// File: lib/database/database.dart
class CodeOpsDatabase extends _$CodeOpsDatabase {
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(clonedRepos);
      }
    },
  );

  /// Clears all tables (called on logout).
  Future<void> clearAllTables() async { ... }
}
```

---

## 7. Models / DTOs

All models use `@JsonSerializable()` with `fromJson`/`toJson` factory constructors unless otherwise noted. File: `lib/models/`.

### User (`user.dart`)

```dart
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool? isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
}
```

### Team, TeamMember, Invitation (`team.dart`)

```dart
@JsonSerializable()
class Team {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String? ownerName;
  final String? teamsWebhookUrl;
  final int? memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

@JsonSerializable()
class TeamMember {
  final String id;
  final String userId;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final TeamRole role;
  final DateTime? joinedAt;
}

@JsonSerializable()
class Invitation {
  final String id;
  final String email;
  final TeamRole role;
  final InvitationStatus status;
  final String? invitedByName;
  final DateTime? expiresAt;
  final DateTime? createdAt;
}
```

### Project (`project.dart`)

```dart
@JsonSerializable()
class Project {
  final String id;
  final String teamId;
  final String name;
  final String? description;
  final String? githubConnectionId;
  final String? repoUrl;
  final String? repoFullName;
  final String? defaultBranch;
  final String? jiraConnectionId;
  final String? jiraProjectKey;
  final String? jiraDefaultIssueType;
  final List<String>? jiraLabels;
  final String? jiraComponent;
  final String? techStack;
  final int? healthScore;
  final DateTime? lastAuditAt;
  final String? settingsJson;
  final bool? isArchived;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### QaJob, JobSummary (`qa_job.dart`)

```dart
@JsonSerializable()
class QaJob {
  final String id;
  final String projectId;
  final String? projectName;
  final JobMode mode;
  final JobStatus status;
  final String? name;
  final String? branch;
  final String? jiraTicketKey;
  final JobResult? overallResult;
  final int? healthScore;
  final int? totalFindings;
  final int? criticalCount;
  final int? highCount;
  final int? mediumCount;
  final int? lowCount;
  final String? summaryReportS3Key;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

@JsonSerializable()
class JobSummary {
  final String id;
  final String projectId;
  final JobMode mode;
  final JobStatus status;
  final String? name;
  final JobResult? overallResult;
  final int? healthScore;
  final int? totalFindings;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
```

### AgentRun (`agent_run.dart`)

```dart
@JsonSerializable()
class AgentRun {
  final String id;
  final String jobId;
  final AgentType agentType;
  final AgentStatus status;
  final AgentResult? result;
  final String? reportS3Key;
  final int? score;
  final int? findingsCount;
  final int? criticalCount;
  final int? highCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
```

### Finding (`finding.dart`)

```dart
@JsonSerializable()
class Finding {
  final String id;
  final String jobId;
  final AgentType agentType;
  final Severity severity;
  final String title;
  final String? description;
  final String? filePath;
  final int? lineNumber;
  final String? recommendation;
  final String? evidence;
  final Effort? effortEstimate;
  final DebtCategory? debtCategory;
  final FindingStatus status;
  final DateTime? createdAt;
}
```

### RemediationTask (`remediation_task.dart`)

```dart
@JsonSerializable()
class RemediationTask {
  final String id;
  final String jobId;
  final int taskNumber;
  final String title;
  final String? description;
  final String? promptMd;
  final String? promptS3Key;
  final List<String>? findingIds;
  final Priority? priority;
  final TaskStatus status;
  final String? assignedTo;
  final String? assignedToName;
  final String? jiraKey;
  final DateTime? createdAt;
}
```

### Persona (`persona.dart`)

```dart
@JsonSerializable()
class Persona {
  final String id;
  final String name;
  final AgentType? agentType;
  final String? description;
  final String? contentMd;
  final Scope scope;
  final String? teamId;
  final String? createdBy;
  final String? createdByName;
  final bool? isDefault;
  final int? version;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Directive, ProjectDirective (`directive.dart`)

```dart
@JsonSerializable()
class Directive {
  final String id;
  final String name;
  final String? description;
  final String? contentMd;
  final DirectiveCategory? category;
  final DirectiveScope scope;
  final String? teamId;
  final String? projectId;
  final String? createdBy;
  final String? createdByName;
  final int? version;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

@JsonSerializable()
class ProjectDirective {
  final String projectId;
  final String directiveId;
  final String? directiveName;
  final DirectiveCategory? category;
  final bool? enabled;
}
```

### Specification (`specification.dart`)

```dart
@JsonSerializable()
class Specification {
  final String id;
  final String jobId;
  final String name;
  final SpecType? specType;
  final String s3Key;
  final DateTime? createdAt;
}
```

### ComplianceItem (`compliance_item.dart`)

```dart
@JsonSerializable()
class ComplianceItem {
  final String id;
  final String jobId;
  final String requirement;
  final String? specId;
  final String? specName;
  final ComplianceStatus status;
  final String? evidence;
  final AgentType? agentType;
  final String? notes;
  final DateTime? createdAt;
}
```

### TechDebtItem (`tech_debt_item.dart`)

```dart
@JsonSerializable()
class TechDebtItem {
  final String id;
  final String projectId;
  final DebtCategory category;
  final String title;
  final String? description;
  final String? filePath;
  final Effort? effortEstimate;
  final BusinessImpact? businessImpact;
  final DebtStatus status;
  final String? firstDetectedJobId;
  final String? resolvedJobId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### DependencyScan, DependencyVulnerability (`dependency_scan.dart`)

```dart
@JsonSerializable()
class DependencyScan {
  final String id;
  final String projectId;
  final String? jobId;
  final String? manifestFile;
  final int? totalDependencies;
  final int? outdatedCount;
  final int? vulnerableCount;
  final DateTime? createdAt;
}

@JsonSerializable()
class DependencyVulnerability {
  final String id;
  final String scanId;
  final String dependencyName;
  final String? currentVersion;
  final String? fixedVersion;
  final String? cveId;
  final Severity severity;
  final String? description;
  final VulnerabilityStatus status;
  final DateTime? createdAt;
}
```

### HealthSnapshot and Related (`health_snapshot.dart`)

This file contains 12 model classes:

```dart
@JsonSerializable() class HealthSnapshot { ... }
@JsonSerializable() class HealthSchedule { ... }
class PageResponse<T> { ... }  // Generic paginated response
@JsonSerializable() class AuthResponse { ... }
@JsonSerializable() class TeamMetrics { ... }
@JsonSerializable() class ProjectMetrics { ... }
@JsonSerializable() class GitHubConnection { ... }
@JsonSerializable() class JiraConnection { ... }
@JsonSerializable() class BugInvestigation { ... }
@JsonSerializable() class SystemSetting { ... }
@JsonSerializable() class AuditLogEntry { ... }
@JsonSerializable() class NotificationPreference { ... }
```

### VCS Models (`vcs_models.dart`)

Plain Dart classes (no `@JsonSerializable`). Uses `fromGitHubJson` factory constructors and manual `fromGitLine`/`fromGitJson` parsers.

16 model classes: `VcsCredentials`, `VcsOrganization`, `VcsRepository`, `VcsBranch`, `VcsPullRequest`, `CreatePRRequest`, `VcsCommit`, `VcsStash`, `VcsTag`, `CloneProgress`, `RepoStatus`, `FileChange`, `DiffResult`, `DiffHunk`, `DiffLine`, `WorkflowRun`.

2 enums: `FileChangeType`, `DiffLineType`.

### Jira Models (`jira_models.dart`)

21 model classes with manual `fromJson`/`toJson`: `JiraSearchResult`, `JiraIssue`, `JiraIssueFields`, `JiraStatus`, `JiraStatusCategory`, `JiraIssueType`, `JiraPriority`, `JiraUser`, `JiraAvatarUrls`, `JiraProject`, `JiraComponent`, `JiraSprint`, `JiraComment`, `JiraCommentPage`, `JiraAttachment`, `JiraIssueLink`, `JiraIssueLinkType`, `JiraTransition`, `CreateJiraIssueRequest`, `CreateJiraSubTaskRequest`, `UpdateJiraIssueRequest`, `JiraIssueDisplayModel`.

### Report Parser Models (`report_parser.dart`)

Internal data classes: `ParsedReport`, `ReportMetadata`, `ParsedFinding`, `ReportMetrics`.

---

## 8. Enumerations

File: `lib/models/enums.dart`

All enums include `toJson()` (returns SCREAMING_SNAKE_CASE string), `fromJson(String)` static constructor, `displayName` getter, and a `JsonConverter` class for `@JsonSerializable` integration.

| Enum | Values | JSON Format |
|------|--------|-------------|
| `AgentResult` | `pass`, `warn`, `fail` | `PASS`, `WARN`, `FAIL` |
| `AgentStatus` | `pending`, `running`, `completed`, `failed` | `PENDING`, `RUNNING`, `COMPLETED`, `FAILED` |
| `AgentType` | `security`, `codeQuality`, `buildHealth`, `completeness`, `apiContract`, `testCoverage`, `uiUx`, `documentation`, `database`, `performance`, `dependency`, `architecture` | `SECURITY`, `CODE_QUALITY`, etc. |
| `BusinessImpact` | `low`, `medium`, `high`, `critical` | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| `ComplianceStatus` | `met`, `partial`, `missing`, `notApplicable` | `MET`, `PARTIAL`, `MISSING`, `NOT_APPLICABLE` |
| `DebtCategory` | `architecture`, `code`, `test`, `dependency`, `documentation` | `ARCHITECTURE`, `CODE`, `TEST`, `DEPENDENCY`, `DOCUMENTATION` |
| `DebtStatus` | `identified`, `acknowledged`, `inProgress`, `resolved`, `accepted` | `IDENTIFIED`, `ACKNOWLEDGED`, `IN_PROGRESS`, `RESOLVED`, `ACCEPTED` |
| `DirectiveCategory` | `coding`, `security`, `testing`, `documentation`, `architecture`, `process`, `other` | `CODING`, `SECURITY`, etc. |
| `DirectiveScope` | `team`, `project` | `TEAM`, `PROJECT` |
| `Effort` | `s`, `m`, `l`, `xl` | `S`, `M`, `L`, `XL` |
| `FindingStatus` | `open`, `acknowledged`, `falsePositive`, `fixed`, `wontFix` | `OPEN`, `ACKNOWLEDGED`, `FALSE_POSITIVE`, `FIXED`, `WONT_FIX` |
| `GitHubAuthType` | `pat`, `oauth`, `ssh` | `PAT`, `OAUTH`, `SSH` |
| `InvitationStatus` | `pending`, `accepted`, `declined`, `expired`, `cancelled` | `PENDING`, `ACCEPTED`, etc. |
| `JobMode` | `audit`, `compliance`, `bugInvestigate`, `remediate`, `techDebt`, `dependency`, `healthMonitor` | `AUDIT`, `COMPLIANCE`, `BUG_INVESTIGATE`, etc. |
| `JobResult` | `pass`, `warn`, `fail` | `PASS`, `WARN`, `FAIL` |
| `JobStatus` | `pending`, `running`, `completed`, `failed`, `cancelled` | `PENDING`, `RUNNING`, `COMPLETED`, `FAILED`, `CANCELLED` |
| `Priority` | `p0`, `p1`, `p2`, `p3` | `P0`, `P1`, `P2`, `P3` |
| `ScheduleType` | `daily`, `weekly`, `onCommit` | `DAILY`, `WEEKLY`, `ON_COMMIT` |
| `Scope` | `system`, `team`, `user` | `SYSTEM`, `TEAM`, `USER` |
| `Severity` | `critical`, `high`, `medium`, `low` | `CRITICAL`, `HIGH`, `MEDIUM`, `LOW` |
| `SpecType` | `regulation`, `standard`, `policy`, `requirement`, `guideline` | `REGULATION`, `STANDARD`, etc. |
| `TaskStatus` | `pending`, `inProgress`, `completed`, `skipped` | `PENDING`, `IN_PROGRESS`, `COMPLETED`, `SKIPPED` |
| `TeamRole` | `owner`, `admin`, `member`, `viewer` | `OWNER`, `ADMIN`, `MEMBER`, `VIEWER` |
| `VulnerabilityStatus` | `open`, `acknowledged`, `resolved`, `falsePositive` | `OPEN`, `ACKNOWLEDGED`, `RESOLVED`, `FALSE_POSITIVE` |

### Additional Enums (not in enums.dart)

| Enum | File | Values |
|------|------|--------|
| `FileChangeType` | `vcs_models.dart` | `added`, `modified`, `deleted`, `renamed`, `copied`, `unmerged`, `unknown` |
| `DiffLineType` | `vcs_models.dart` | `context`, `addition`, `deletion`, `header` |
| `ClaudeCodeStatus` | `claude_code_detector.dart` | `available`, `notInstalled`, `versionTooOld`, `error` |
| `AgentMonitorStatus` | `agent_monitor.dart` | `completed`, `failed`, `timedOut`, `cancelled` |
| `AgentPhase` | `progress_aggregator.dart` | `queued`, `running`, `parsing`, `completed`, `failed`, `timedOut` |
| `ExportFormat` | `export_service.dart` | `markdown`, `pdf`, `zip`, `csv` |
| `SyncState` | `sync_service.dart` | `idle`, `syncing`, `synced`, `error` |
| `AuthState` | `auth_service.dart` | `unknown`, `authenticated`, `unauthenticated` |

---

## 9. Services / Business Logic

### 9.1 Authentication (`lib/services/auth/`)

#### AuthService (`auth_service.dart`)

```dart
class AuthService {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String displayName);
  Future<void> refreshToken();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logout();
  Future<void> tryAutoLogin();
  void dispose();
}
```

#### SecureStorageService (`secure_storage.dart`)

```dart
class SecureStorageService {
  Future<String?> getAuthToken();
  Future<void> setAuthToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String token);
  Future<String?> getCurrentUserId();
  Future<void> setCurrentUserId(String userId);
  Future<String?> getSelectedTeamId();
  Future<void> setSelectedTeamId(String teamId);
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clearAll();
}
```

### 9.2 Cloud API Services (`lib/services/cloud/`)

#### ApiClient (`api_client.dart`)

Centralized Dio wrapper. Base: `http://localhost:8090/api/v1`. Timeouts: connect=15s, receive=30s, send=15s. Three interceptors: auth (Bearer token), refresh (401 retry), error (DioException -> ApiException).

#### 18 API Service Classes

- **UserApi** (6 methods): getCurrentUser, getUserById, updateUser, searchUsers, deactivateUser, activateUser
- **TeamApi** (12 methods): getTeams, createTeam, getTeam, updateTeam, deleteTeam, getTeamMembers, updateMemberRole, removeMember, inviteMember, getTeamInvitations, cancelInvitation, acceptInvitation
- **ProjectApi** (8 methods): createProject, getTeamProjects, getTeamProjectsPaged, getProject, updateProject, deleteProject, archiveProject, unarchiveProject
- **JobApi** (13 methods): createJob, getJob, updateJob, deleteJob, getProjectJobs, getMyJobs, createAgentRun, createAgentRunsBatch, getAgentRuns, updateAgentRun, createInvestigation, getInvestigation, updateInvestigation
- **FindingApi** (10 methods): createFinding, createFindingsBatch, getJobFindings, getFinding, getFindingsBySeverity, getFindingsByStatus, getFindingsByAgent, getFindingCounts, updateFindingStatus, bulkUpdateStatus
- **ReportApi** (5 methods): uploadSummaryReport, uploadAgentReport, uploadSpecification, downloadReport, downloadSpecReport
- **PersonaApi** (11 methods): createPersona, getPersona, updatePersona, deletePersona, getTeamPersonas, getTeamPersonasByAgentType, getTeamDefaultPersona, setAsDefault, removeDefault, getSystemPersonas, getMyPersonas
- **DirectiveApi** (11 methods): createDirective, getDirective, updateDirective, deleteDirective, getTeamDirectives, getProjectDirectives, getProjectEnabledDirectives, getProjectDirectiveAssignments, assignToProject, toggleDirective, removeFromProject
- **MetricsApi** (3 methods): getTeamMetrics, getProjectMetrics, getProjectTrend
- **AdminApi** (9 methods): getAllUsers, getUserById, updateUserStatus, getAllSettings, getSetting, updateSetting, getUsageStats, getTeamAuditLog, getUserAuditLog
- **IntegrationApi** (40+ methods): GitHub/Jira connections, dependency scans, vulnerabilities, compliance, tasks, tech debt, health monitor
- **ComplianceApi** (7 methods): createSpecification, getSpecificationsForJob, createComplianceItem, createComplianceItems, getComplianceItemsForJob, getComplianceItemsByStatus, getComplianceSummary
- **TaskApi** (6 methods): createTask, createTasksBatch, getTasksForJob, getTask, updateTask, getAssignedTasks
- **TechDebtApi** (9 methods): createTechDebtItem, createTechDebtItems, getTechDebtItem, getTechDebtForProject, getTechDebtByStatus, getTechDebtByCategory, updateTechDebtStatus, deleteTechDebtItem, getDebtSummary
- **DependencyApi** (10 methods): createScan, getScan, getScansForProject, getLatestScan, addVulnerability, addVulnerabilities, getVulnerabilities, getVulnerabilitiesBySeverity, getOpenVulnerabilities, updateVulnerabilityStatus
- **HealthMonitorApi** (8 methods): createSchedule, getSchedulesForProject, updateSchedule, deleteSchedule, createSnapshot, getSnapshots, getLatestSnapshot, getHealthTrend

### 9.3 Orchestration (`lib/services/orchestration/`)

- **JobOrchestrator**: 10-step job lifecycle (create, batch agent runs, dispatch, monitor, parse, consolidate, upload, finalize)
- **AgentDispatcher**: Spawns Claude Code CLI subprocesses with semaphore-based concurrency control (max 3)
- **AgentMonitor**: Collects stdout/stderr, enforces timeouts, reports terminal status
- **VeraManager**: Consolidation engine (deduplication, weighted health scoring, executive summary generation)
- **ProgressAggregator**: Real-time progress stream for UI binding
- **BugInvestigationOrchestrator**: Jira issue -> bug investigation job flow

### 9.4 Agent Services (`lib/services/agent/`)

- **PersonaManager**: Assembles prompts (persona + directives + job context + report format)
- **ReportParser**: Regex-based markdown report parser (tolerant of AI formatting variations)
- **TaskGenerator**: Groups findings by file, generates remediation prompts, batch-creates tasks

### 9.5 Analysis Services (`lib/services/analysis/`)

- **HealthCalculator**: Weighted composite health scores from agent runs
- **TechDebtTracker**: Debt scoring (category*effort*impact), priority matrix, markdown reports
- **DependencyScanner**: Dependency health scores (100 - severity deductions), vulnerability grouping

### 9.6 Platform Services (`lib/services/platform/`)

- **ProcessManager**: Subprocess lifecycle management with timeout support
- **ClaudeCodeDetector**: Claude Code CLI detection, version validation, executable path resolution

### 9.7 VCS Services (`lib/services/vcs/`)

- **VcsProvider**: Abstract VCS interface (13 methods)
- **GitHubProvider**: GitHub REST API v3 implementation with rate limit tracking
- **GitService**: Git CLI wrapper (20+ operations, GIT_TERMINAL_PROMPT=0)
- **RepoManager**: Local cloned repo registry (Drift-backed)

### 9.8 Data Services (`lib/services/data/`)

- **SyncService**: Cloud-to-local project sync with offline fallback

### 9.9 Integration Services (`lib/services/integration/`)

- **ExportService**: Markdown/PDF/ZIP/CSV export with section selection and file save dialogs

### 9.10 Jira Services (`lib/services/jira/`)

- **JiraService**: Direct Jira Cloud REST API client (Basic Auth, ADF conversion, rate limit handling)
- **JiraMapper**: Bidirectional Jira<->CodeOps model mapping, ADF<->Markdown conversion

---

## 10. State Management (Riverpod Providers)

File: `lib/providers/`

All providers use manual Riverpod 2.x patterns (no `@riverpod` code generation). 19 provider files covering all domains.

### Key Provider Patterns

```dart
// Service providers (singleton)
final apiClientProvider = Provider<ApiClient>((ref) => ...);

// Data providers (async, cached)
final teamProjectsProvider = FutureProvider<List<Project>>((ref) => ...);

// Parameterized data providers
final projectProvider = FutureProvider.family<Project, String>((ref, id) => ...);

// UI state providers
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

// Complex state (StateNotifier)
final favoriteProjectIdsProvider = StateNotifierProvider<FavoriteProjectsNotifier, Set<String>>(...);

// Auto-disposing providers (for per-page data)
final jobFindingsProvider = FutureProvider.autoDispose.family<List<Finding>, String>(...);
```

---

## 11. Consumed REST API Surface

The CodeOps-Client consumes the CodeOps-Server REST API at `http://localhost:8090/api/v1`. All calls go through the centralized `ApiClient` Dio wrapper. The full endpoint catalog spans 100+ endpoints across Authentication, Users, Teams, Projects, Jobs, Agent Runs, Bug Investigations, Findings, Reports, Personas, Directives, Integrations (GitHub/Jira), Dependencies, Vulnerabilities, Compliance, Tasks, Tech Debt, Health Monitor, Metrics, and Admin.

See Section 9.2 for the complete API service method signatures.

---

## 12. Inbound REST API

**N/A** -- This is a desktop client application. It does not expose any REST endpoints.

---

## 13. Navigation & Routing

File: `lib/router.dart`

- **Framework:** GoRouter 14.8.1
- **Initial location:** `/login`
- **Refresh listenable:** `AuthNotifier` (bridges AuthService -> GoRouter)
- **Transition:** `NoTransitionPage` for all authenticated routes (SPA feel)
- **Shell:** `ShellRoute` wraps all authenticated routes in `NavigationShell`

### Route Table (24 routes)

| # | Path | Name | Page | Shell |
|---|------|------|------|-------|
| 1 | `/login` | `login` | LoginPage | No |
| 2 | `/setup` | `setup` | PlaceholderPage | No |
| 3 | `/` | `home` | HomePage | Yes |
| 4 | `/projects` | `projects` | ProjectsPage | Yes |
| 5 | `/projects/:id` | `projectDetail` | ProjectDetailPage | Yes |
| 6 | `/repos` | `repos` | GitHubBrowserPage | Yes |
| 7 | `/audit` | `audit` | AuditWizardPage | Yes |
| 8 | `/compliance` | `compliance` | ComplianceWizardPage | Yes |
| 9 | `/dependencies` | `dependencies` | DependencyScanPage | Yes |
| 10 | `/bugs` | `bugs` | BugInvestigatorPage | Yes |
| 11 | `/bugs/jira` | `jiraBrowser` | JiraBrowserPage | Yes |
| 12 | `/tasks` | `tasks` | TaskManagerPage | Yes |
| 13 | `/tech-debt` | `techDebt` | TechDebtPage | Yes |
| 14 | `/health` | `health` | HealthDashboardPage | Yes |
| 15 | `/history` | `history` | JobHistoryPage | Yes |
| 16 | `/jobs/:id` | `jobProgress` | JobProgressPage | Yes |
| 17 | `/jobs/:id/report` | `jobReport` | JobReportPage | Yes |
| 18 | `/jobs/:id/findings` | `findingsExplorer` | FindingsExplorerPage | Yes |
| 19 | `/jobs/:id/tasks` | `taskList` | TaskListPage | Yes |
| 20 | `/personas` | `personas` | PersonasPage | Yes |
| 21 | `/personas/:id/edit` | `personaEditor` | PersonaEditorPage | Yes |
| 22 | `/directives` | `directives` | DirectivesPage | Yes |
| 23 | `/settings` | `settings` | SettingsPage | Yes |
| 24 | `/admin` | `admin` | AdminHubPage | Yes |

### Redirect Logic

- Unauthenticated users on any page except `/login` -> redirected to `/login`
- Authenticated users on `/login` -> redirected to `/`
- Authenticated users on `/setup` -> no redirect

---

## 14. Pages (Screens)

File: `lib/pages/` -- 24 page files.

| Page | Description |
|------|-------------|
| LoginPage | Email/password authentication form |
| HomePage | Dashboard with project overview, recent jobs, quick actions |
| ProjectsPage | Team project listing with search, sort, archive filter |
| ProjectDetailPage | Single project view with settings, integrations, jobs |
| GitHubBrowserPage | Browse GitHub orgs, repos, branches, PRs, workflows |
| AuditWizardPage | Multi-step wizard for launching QA audit jobs |
| ComplianceWizardPage | Multi-step wizard for compliance check jobs |
| DependencyScanPage | View dependency scans and vulnerabilities |
| BugInvestigatorPage | Launch bug investigation from Jira issue |
| JiraBrowserPage | Browse and search Jira issues |
| TaskManagerPage | View and manage remediation tasks across jobs |
| TechDebtPage | Tech debt tracking with category/status filters |
| HealthDashboardPage | Health score trends, schedules, snapshots |
| JobHistoryPage | Historical job listing with filters |
| JobProgressPage | Live job execution monitoring with agent status |
| JobReportPage | View and export job reports |
| FindingsExplorerPage | Browse/filter/manage findings for a job |
| TaskListPage | View remediation tasks for a specific job |
| PersonasPage | Manage team and system personas |
| PersonaEditorPage | Edit persona content (markdown editor) |
| DirectivesPage | Manage team and project directives |
| SettingsPage | Application and user settings |
| AdminHubPage | Admin panel (user management, settings, audit log) |
| PlaceholderPage | Generic placeholder for unimplemented features |

---

## 15. Widgets

File: `lib/widgets/`

### NavigationShell (`shell/navigation_shell.dart`)

Primary scaffold wrapping all authenticated pages. Collapsible sidebar (64px/240px), top bar, content area.

Sidebar sections: NAVIGATE (Home, Projects), SOURCE (GitHub Browser), ANALYZE (Audit, Compliance, Dependencies, Bug Investigator), MAINTAIN (Jira Browser, Tasks, Tech Debt), MONITOR (Health, Job History), TEAM (Personas, Directives). Bottom: Settings, Admin (role-gated), User Profile with team switcher and logout.

The `widgets/` directory contains 87+ reusable widget files organized by domain.

---

## 16. Theme & Styling

### Dark Theme Only (`lib/theme/app_theme.dart`)

Material 3 dark theme with custom `ColorScheme`.

### Colors (`lib/theme/colors.dart`)

```
background     = #1A1B2E (Deep navy)
surface        = #222442
surfaceVariant = #2A2D52
primary        = #6C63FF (Purple-blue)
primaryVariant = #5A52D5
secondary      = #00D9FF (Cyan)
success        = #4ADE80 (Green)
warning        = #FBBF24 (Amber)
error          = #EF4444 (Red)
critical       = #DC2626 (Dark red)
textPrimary    = #E2E8F0
textSecondary  = #94A3B8
textTertiary   = #64748B
border         = #334155
divider        = #1E293B
```

Color maps for: `severityColors`, `jobStatusColors`, `agentTypeColors` (12 unique colors).

### Typography (`lib/theme/typography.dart`)

Font family: Inter. Code font: JetBrains Mono. 12 text styles from headlineLarge (32px) to labelSmall (11px).

---

## 17. Utilities & Helpers

### Date Utilities (`lib/utils/date_utils.dart`)

`formatDateTime`, `formatDate`, `formatTimeAgo`, `formatDuration`

### String Utilities (`lib/utils/string_utils.dart`)

`truncate`, `pluralize`, `camelToTitle`, `snakeToTitle`, `isValidEmail`

### File Utilities (`lib/utils/file_utils.dart`)

`formatFileSize`, `getFileExtension`, `getFileName`

---

## 18. Error Handling & Exceptions

### ApiException Hierarchy (`lib/services/cloud/api_exceptions.dart`)

```
ApiException (sealed)
  +-- BadRequestException       (400)
  +-- UnauthorizedException     (401)
  +-- ForbiddenException        (403)
  +-- NotFoundException         (404)
  +-- ConflictException         (409)
  +-- ValidationException       (422)
  +-- RateLimitException        (429)
  +-- ServerException           (500+)
  +-- NetworkException          (connection errors)
  +-- TimeoutException          (timeout errors)
```

### Error Flow

1. **ApiClient error interceptor**: DioException -> typed ApiException
2. **Refresh interceptor**: 401 -> single token refresh retry
3. **GitHubProvider**: Maps GitHub DioExceptions to ApiException
4. **JiraService**: 429 -> automatic retry after Retry-After delay
5. **GitService**: Git command failures -> GitException
6. **SyncService**: NetworkException/TimeoutException -> local DB fallback

---

## 19. Authentication & Authorization

### Auth Flow

1. Login with email/password -> JWT tokens
2. Tokens stored in platform keychain (FlutterSecureStorage)
3. AuthNotifier triggers GoRouter redirect
4. ApiClient attaches Bearer token to all requests
5. On 401, refresh interceptor tries token refresh once
6. Logout clears storage + wipes local database

### Token Lifecycle

| Token | Lifetime | Storage Key |
|-------|----------|-------------|
| Access | 24 hours | `codeops_auth_token` |
| Refresh | 30 days | `codeops_refresh_token` |

Public paths (no auth): `/auth/login`, `/auth/register`, `/auth/refresh`, `/health`

---

## 20. External Integrations

### GitHub REST API v3

- Client: `GitHubProvider`, separate Dio instance
- Auth: Bearer token (PAT)
- Base URL: `https://api.github.com`
- Rate limit tracking via response headers

### Jira Cloud REST API v3

- Client: `JiraService`, separate Dio instance
- Auth: Basic Auth (email:apiToken base64)
- Rate limiting: auto-retry on 429
- ADF <-> Markdown conversion

### Claude Code CLI

- Detection: `ClaudeCodeDetector` (which/where.exe)
- Dispatch: `AgentDispatcher` -> `ProcessManager` -> Process.run
- CLI: `claude --print --output-format json --max-turns 50 --model <model> -p <prompt>`
- Concurrency: max 3, timeout: 30min

### Git CLI

- Client: `GitService`, 20+ operations
- Environment: `GIT_TERMINAL_PROMPT=0`

---

## 21. Event / Messaging System

Internal Dart `StreamController` broadcast streams only (no external message broker):

- `JobLifecycleEvent` stream (9 event types)
- `AgentDispatchEvent` stream (6 event types)
- `AgentMonitorEvent` stream (3 event types)
- `JobProgress` stream (real-time progress snapshots)
- `AuthState` stream (auth state changes)

**Kafka:** N/A (server-side only)
**Redis:** N/A (server-side only)

---

## 22. Infrastructure / Docker

**N/A** -- Desktop application. No Docker, Kubernetes, or containerized deployment.

---

## 23. OpenAPI / Swagger

**N/A** -- Client application. No exposed API. Consumes server Swagger at `http://localhost:8090/swagger-ui.html`.

---

## 24. Tests

- **Framework:** `flutter_test` (built-in)
- **Mocking:** `mocktail` 1.0.4
- **Location:** `test/` directory

---

## 25. Cross-Cutting Concerns

### Caching

- Local Drift/SQLite database for persistent cache
- SyncService: server -> local DB with offline fallback
- Riverpod FutureProvider: in-memory cache until invalidated

### Offline Support

Partial: projects cached locally; other operations require network.

### Concurrency

- Agent dispatch: semaphore-based (max 3 concurrent)
- ProcessManager: tracks active subprocesses, kill-all support
- Token refresh: single-retry pattern

### Security

- Platform-native secure storage for all credentials
- No hardcoded secrets
- GIT_TERMINAL_PROMPT=0 blocks interactive git prompts

### Code Generation

- JsonSerializable: model fromJson/toJson
- Drift: database accessor code
- Command: `dart run build_runner build --delete-conflicting-outputs`

---

## 26. Quality Scorecard

| Category | Weight | Score (0-10) | Weighted |
|----------|--------|:------------:|----------|
| Architecture & Separation of Concerns | 15% | 9 | 1.35 |
| State Management | 12% | 8 | 0.96 |
| Error Handling | 10% | 9 | 0.90 |
| Type Safety & Null Safety | 10% | 9 | 0.90 |
| Code Organization | 10% | 9 | 0.90 |
| API Layer Design | 10% | 8 | 0.80 |
| Database Layer | 8% | 8 | 0.64 |
| Security | 8% | 9 | 0.72 |
| Navigation & Routing | 5% | 9 | 0.45 |
| Theme & UI Consistency | 5% | 9 | 0.45 |
| Testing | 5% | 4 | 0.20 |
| Documentation | 2% | 8 | 0.16 |
| **TOTAL** | **100%** | | **8.43/10** |

### Overall Assessment

The CodeOps-Client is a well-architected Flutter desktop application with strong separation of concerns, comprehensive error handling, and thorough type safety. The orchestration layer for multi-agent Claude Code jobs is particularly well-designed with clear event hierarchies and concurrency control. The main area for improvement is test coverage. The codebase is clean, consistent, and ready for an AI agent to understand and modify.
