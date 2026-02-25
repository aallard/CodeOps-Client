# CodeOps-Client — Codebase Audit

**Audit Date:** 2026-02-25T16:13:57Z
**Branch:** main
**Commit:** fd8957b060dfb2b429e16c2a11350d877a5b761b CCA-003: Courier client data layer — enums, models, API, providers, tests
**Auditor:** Claude Code (Automated)
**Purpose:** Zero-context reference for AI-assisted development
**Audit File:** CodeOps-Client-Audit.md
**Scorecard:** CodeOps-Client-Scorecard.md
**OpenAPI Spec:** CodeOps-Client-OpenAPI.yaml (stub — client app, not a server)

> This audit is the single source of truth for the CodeOps-Client codebase.
> CodeOps-Client is a Flutter desktop application that CONSUMES APIs — it does not serve them.
> The OpenAPI spec stub exists to satisfy template requirements.
> An AI reading this audit should be able to generate accurate code changes, new features,
> tests, and fixes without filesystem access.

---

## 1. Project Identity

```
Project Name:         CodeOps-Client (codeops)
Repository URL:       https://github.com/AI-CodeOps/CodeOps-Client.git
Primary Language:     Dart / Flutter
Dart Version:         SDK ^3.6.0
Flutter Version:      >=3.27.0
Build Tool:           Flutter CLI + pub
Current Branch:       main
Latest Commit Hash:   fd8957b060dfb2b429e16c2a11350d877a5b761b
Latest Commit Msg:    CCA-003: Courier client data layer — enums, models, API, providers, tests
Audit Timestamp:      2026-02-25T16:13:57Z
```

---

## 2. Directory Structure

```
CodeOps-Client/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md                              # Master product specification
├── assets/
│   ├── personas/                          # 13 agent persona markdown files
│   └── templates/                         # 5 report template markdown files
├── integration_test/                      # 5 integration test files
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # Root MaterialApp + ProviderScope
│   ├── router.dart                        # GoRouter configuration (51 routes)
│   ├── database/
│   │   ├── database.dart                  # Drift CodeOpsDatabase (18 tables, schema v4)
│   │   └── tables.dart                    # Drift table definitions
│   ├── models/                            # 29 model/enum files
│   ├── pages/                             # 50 page files (inc. registry/ subdirectory)
│   ├── providers/                         # 28 provider files (~350 providers)
│   ├── services/                          # 56 service files across 9 subdirectories
│   ├── theme/                             # 3 theme files
│   ├── utils/                             # 6 utility files
│   └── widgets/                           # 257 widget files across 20 subdirectories
├── macos/                                 # macOS native runner
└── test/                                  # 348 test files
```

**Summary:** Single-module Flutter desktop application. Source code in `lib/` (393 non-generated Dart files, 121,202 lines). Tests in `test/` (348 files) and `integration_test/` (5 files). 20 generated `.g.dart` files from json_serializable and Drift. No `.freezed.dart` files despite freezed_annotation dependency.

---

## 3. Build & Dependency Manifest

**Build file:** `pubspec.yaml`

### Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| flutter | SDK | UI framework |
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Riverpod annotations (unused — manual providers) |
| go_router | ^14.8.1 | Declarative routing |
| drift | ^2.22.1 | Local SQLite database |
| sqlite3_flutter_libs | ^0.5.28 | SQLite native bindings |
| dio | ^5.7.0 | HTTP client |
| flutter_markdown | ^0.7.6 | Markdown rendering |
| flutter_highlight | ^0.7.0 | Syntax highlighting |
| re_editor | ^0.8.0 | Code editor widget |
| re_highlight | ^0.0.3 | Code highlighting for re_editor |
| fl_chart | ^0.70.2 | Charts and graphs |
| file_picker | ^8.1.7 | Native file dialogs |
| desktop_drop | ^0.5.0 | Drag-and-drop file support |
| window_manager | ^0.4.3 | Desktop window management |
| split_view | ^3.2.1 | Resizable split panes |
| diff_match_patch | ^0.4.1 | Text diff computation |
| path | ^1.9.0 | Path manipulation |
| path_provider | ^2.1.5 | App data directories |
| uuid | ^4.5.1 | UUID generation |
| intl | ^0.20.1 | Internationalization/date formatting |
| yaml | ^3.1.3 | YAML parsing |
| archive | ^4.0.2 | ZIP archive creation |
| url_launcher | ^6.3.1 | External URL opening |
| shared_preferences | ^2.3.4 | Key-value persistence |
| crypto | ^3.0.6 | Cryptographic utilities |
| package_info_plus | ^8.1.2 | App version info |
| connectivity_plus | ^6.1.1 | Network connectivity |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| freezed_annotation | ^2.4.4 | Immutable model annotations (present but unused) |
| collection | ^1.19.0 | Collection utilities |
| equatable | ^2.0.7 | Value equality |
| pdf | ^3.11.2 | PDF generation |
| printing | ^5.13.4 | PDF printing/saving |

### Dev Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| build_runner | ^2.4.14 | Code generation runner |
| drift_dev | ^2.22.1 | Drift code generation |
| riverpod_generator | ^2.6.4 | Riverpod code generation (unused) |
| json_serializable | ^6.9.0 | JSON serialization code generation |
| freezed | ^2.5.7 | Immutable model code generation (present but unused) |
| flutter_test | SDK | Test framework |
| mocktail | ^1.0.4 | Mocking framework |
| integration_test | SDK | Integration test framework |
| flutter_lints | ^5.0.0 | Lint rules |

### Build Commands

```
Build:    flutter build macos
Test:     flutter test
Run:      flutter run -d macos
Codegen:  dart run build_runner build --delete-conflicting-outputs
Analyze:  flutter analyze
```

---

## 4. Configuration & Infrastructure Summary

### Configuration Files

- **`pubspec.yaml`** — Package dependencies, assets (personas/, templates/), Material Design
- **`analysis_options.yaml`** — Uses `package:flutter_lints/flutter.yaml`, no custom rules enabled
- **`lib/utils/constants.dart`** — All configuration constants (see AppConstants below)

### AppConstants (from `lib/utils/constants.dart`)

```
apiBaseUrl:          http://localhost:8090
apiPrefix:           /api/v1
registryApiPrefix:   /api/v1/registry
vaultApiBaseUrl:     http://localhost:8097
vaultApiPrefix:      /api/v1/vault
defaultClaudeModel:  claude-sonnet-4-5-20250929
maxConcurrentAgents: 6
agentTimeoutMinutes: 30
maxTurns:            200
passThreshold:       80
warnThreshold:       60
windowWidth:         1440.0
windowHeight:        900.0
minWindowWidth:      1024.0
minWindowHeight:     700.0
```

### Connection Map

```
CodeOps-Server:    HTTP, localhost:8090, /api/v1
CodeOps-Registry:  HTTP, localhost:8090, /api/v1/registry (proxied through Server)
CodeOps-Vault:     HTTP, localhost:8097, /api/v1/vault (direct connection)
GitHub API:        HTTPS, api.github.com (PAT auth)
Jira Cloud API:    HTTPS, {instance-url}/rest/api/3 (Basic auth)
Anthropic API:     HTTPS, api.anthropic.com (API key auth)
Local SQLite:      Drift database (18 tables, schema version 4)
Local Git CLI:     subprocess invocation
Claude Code CLI:   subprocess invocation
```

### CI/CD

None detected. No `.github/workflows/`, no Jenkinsfile, no `.gitlab-ci.yml`.

---

## 5. Startup & Runtime Behavior

**Entry point:** `lib/main.dart`

Startup sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `windowManager.ensureInitialized()` — Set window size (1440x900), minimum (1024x700), title "CodeOps"
3. `windowManager.waitUntilReadyToShow()` then `show()` and `focus()`
4. `runApp(ProviderScope(child: CodeOpsApp()))` — Riverpod root

**`lib/app.dart` (CodeOpsApp):**
- ConsumerWidget wrapping MaterialApp.router
- GoRouter with auth redirect guard
- Material 3 dark theme (AppTheme.darkTheme)
- Watches `authStateProvider` for auth-based redirect

**No background jobs, no health check endpoint, no PostConstruct equivalent.**
Scheduled health monitoring is configured server-side and triggered via API.

---

## 6. Data Model Layer (Drift Local Database)

**File:** `lib/database/database.dart` + `lib/database/tables.dart`
**Schema version:** 4
**18 tables** for local caching:

| Table | Key Columns | Purpose |
|---|---|---|
| Projects | id, teamId, name, description, etc. | Cache team projects |
| Findings | id, jobId, agentType, severity, etc. | Cache job findings |
| QaJobs | id, projectId, mode, status, etc. | Cache QA jobs |
| AgentRuns | id, jobId, agentType, status, etc. | Cache agent runs |
| Personas | id, name, agentType, scope, etc. | Cache personas |
| Directives | id, name, category, scope, etc. | Cache directives |
| Teams | id, name, description, ownerId, etc. | Cache teams |
| TeamMembers | id, userId, displayName, role, etc. | Cache team members |
| Users | id, email, displayName, etc. | Cache users |
| HealthSnapshots | id, projectId, healthScore, etc. | Cache health data |
| TechDebtItems | id, projectId, category, status, etc. | Cache tech debt |
| RemediationTasks | id, jobId, title, status, etc. | Cache tasks |
| ClonedRepos | repoFullName (PK), localPath | Track cloned repos |
| AnthropicModels | id, modelId, displayName, etc. | Cache AI models |
| ScribeTabs | id, title, filePath, content, etc. | Persist editor tabs |
| ScribeSettings | key (PK), value | Persist editor settings |
| ProjectLocalConfigs | projectId (PK), workingDirectory | Local project config |
| SessionMetadata | key (PK), value | Session state |

**Migration v3→v4:** Added `jiraComponent` column to Projects, `healthCheckUrl`/`docsUrl`/`contactEmail` to services cache.

---

## 7. Enum Definitions

**57 enums** across 5 files. All use SCREAMING_SNAKE_CASE matching the Java server.

### `lib/models/enums.dart` (25 enums)

| Enum | Values | Used By |
|---|---|---|
| AgentType | security, codeQuality, buildHealth, completeness, apiContract, testCoverage, uiUx, documentation, database, performance, dependency, architecture | Persona, AgentRun, AgentProgress |
| Severity | critical, high, medium, low, info | Finding, compliance |
| FindingStatus | open, acknowledged, falsePositive, fixed, wontFix | Finding |
| JobMode | audit, compliance, bugInvestigate, remediate, techDebt, dependency, healthMonitor | QaJob |
| JobStatus | pending, running, completed, failed, cancelled | QaJob |
| JobResult | pass, warn, fail | QaJob |
| AgentStatus | pending, queued, running, completed, failed, timedOut, cancelled | AgentRun |
| AgentResult | pass, warn, fail, error | AgentRun |
| Priority | critical, high, medium, low | RemediationTask |
| TaskStatus | generated, inProgress, completed, skipped | RemediationTask |
| Scope | system, team, user | Persona, Directive |
| DirectiveCategory | architecture, standards, conventions, context, other | Directive |
| TeamRole | owner, admin, member, viewer | TeamMember |
| InvitationStatus | pending, accepted, declined, expired | Invitation |
| SpecType | openapi, design, architecture, requirements, custom | Specification |
| DebtCategory | architecture, code, test, dependency, documentation | TechDebtItem |
| DebtStatus | identified, planned, inProgress, resolved | TechDebtItem |
| Effort | trivial, small, medium, large, major | TechDebtItem |
| BusinessImpact | critical, high, medium, low, none | TechDebtItem |
| VulnerabilityStatus | open, patched, ignored, falsePositive | DependencyVulnerability |
| VulnerabilitySeverity | critical, high, medium, low, none | DependencyVulnerability |
| HealthScheduleFrequency | daily, weekly, monthly, onCommit | HealthSchedule |
| HealthScheduleStatus | active, paused, completed | HealthSchedule |
| NotificationChannel | inApp, email, teamsWebhook, slackWebhook | Notifications |
| NotificationCategory | audit, health, security, system | Notifications |

### `lib/models/courier_enums.dart` (7 enums)

| Enum | Values |
|---|---|
| HttpMethod | get, post, put, patch, delete, head, options |
| BodyType | none, formData, xWwwFormUrlencoded, rawJson, rawXml, rawHtml, rawText, rawYaml, binary, graphql |
| AuthType | noAuth, apiKey, bearerToken, basicAuth, oauth2AuthorizationCode, oauth2ClientCredentials, oauth2Implicit, oauth2Password, jwtBearer, inheritFromParent |
| ScriptType | preRequest, postResponse |
| CollectionSharePermission | viewer, editor, admin |
| RunStatus | pending, running, completed, failed, cancelled |
| CodeLanguage | curl, pythonRequests, javascriptFetch, javascriptAxios, javaHttpClient, javaOkHttp, cSharpHttpClient, goNet, rubyNet, phpCurl, swiftUrlSession, kotlinOkHttp |

### `lib/models/logger_enums.dart` (9 enums)

| Enum | Values |
|---|---|
| LogLevel | trace, debug, info, warn, error, fatal |
| TrapTriggerType | regexMatch, keywordMatch, frequencyThreshold, absenceDetection |
| AlertSeverity | info, warning, critical |
| AlertStatus | firing, acknowledged, resolved, silenced |
| AlertChannelType | email, teamsWebhook, slackWebhook, customWebhook |
| MetricType | counter, gauge, histogram, timer |
| AggregationType | sum, avg, min, max, p50, p95, p99, count |
| DashboardWidgetType | logStream, timeSeries, counter, gauge, table, heatmap, pieChart, barChart |
| RetentionAction | delete, archive |

### `lib/models/registry_enums.dart` (11 enums)

| Enum | Values |
|---|---|
| ServiceType | springBootApi, flutterWeb, flutterDesktop, flutterMobile, reactApp, nextjsApp, angularApp, nodeExpressApi, pythonFastapiApi, pythonDjangoApi, goApi, rustApi, dotnetApi, staticSite, workerService, gateway, mcpServer, cliTool, other (19) |
| ServiceStatus | active, inactive, deprecated, archived |
| HealthStatus | up, down, degraded, unknown |
| SolutionCategory | platform, application, librarySuite, infrastructure, tooling, other |
| SolutionStatus | active, inDevelopment, deprecated, archived |
| SolutionMemberRole | core, supporting, infrastructure, externalDependency |
| PortType | httpApi, frontendDev, database, redis, kafka, kafkaInternal, zookeeper, grpc, websocket, debug, actuator, custom (12) |
| DependencyType | httpRest, grpc, kafkaTopic, databaseShared, redisShared, library_, gatewayRoute, websocket, fileSystem, other (10) |
| ConfigTemplateType | dockerCompose, applicationYml, applicationProperties, envFile, dockerfile, nginxConf, makefileTarget, ciPipeline, terraformModule, helmValues, readmeSection, startupScript (12) |
| InfraResourceType | s3Bucket, rdsInstance, dynamodbTable, sqsQueue, snsTopicResource, lambdaFunction, ec2Instance, ecsService, eksCluster, cloudwatchAlarm, elasticacheCluster, redisCluster, kafkaCluster, postgresDatabase, mongoDatabase, dockerRegistry, loadBalancer, cdn, dnsRecord, dockerVolume, other (21) |
| ConfigSource | autoGenerated, manual, inherited, registryDerived |

### `lib/models/vault_enums.dart` (6 enums)

| Enum | Values |
|---|---|
| SecretType | static_, dynamic_, reference |
| SealStatus | sealed, unsealed, unsealing |
| PolicyPermission | read, write, delete, list, rotate |
| BindingType | user, team, service |
| RotationStrategy | randomGenerate, externalApi, customScript |
| LeaseStatus | active, expired, revoked |

---

## 8. Model Layer

**29 model files** producing ~120 classes. All use `@JsonSerializable()` with generated `.g.dart` files or plain Dart with manual `toJson`/`fromJson`. **No Freezed** is used despite the annotation dependency.

### Core Domain Models (with `@JsonSerializable`)

| Model | Fields | File |
|---|---|---|
| User | 7 (id, email, displayName, avatarUrl, isActive, lastLoginAt, createdAt) | user.dart |
| Team | 9 (id, name, description, ownerId, ownerName, teamsWebhookUrl, memberCount, createdAt, updatedAt) | team.dart |
| TeamMember | 7 (id, userId, displayName, email, avatarUrl, role, joinedAt) | team.dart |
| Invitation | 7 (id, email, role, status, invitedByName, expiresAt, createdAt) | team.dart |
| Project | 19 (id, teamId, name, description, githubConnectionId, repoUrl, repoFullName, defaultBranch, jiraConnectionId, jiraProjectKey, jiraDefaultIssueType, jiraLabels, jiraComponent, techStack, healthScore, lastAuditAt, isArchived, createdAt, updatedAt) | project.dart |
| QaJob | 22 (id, projectId, projectName, mode, status, name, branch, configJson, summaryMd, overallResult, healthScore, totalFindings, criticalCount, highCount, mediumCount, lowCount, jiraTicketKey, startedBy, startedByName, startedAt, completedAt, createdAt) | qa_job.dart |
| AgentRun | 14 (id, jobId, agentType, status, result, healthScore, findingCount, reportS3Key, outputLog, errorMessage, startedAt, completedAt, durationSeconds, createdAt) | agent_run.dart |
| Persona | 13 (id, name, agentType, description, contentMd, scope, teamId, createdBy, createdByName, isDefault, version, createdAt, updatedAt) | persona.dart |
| Directive | 12 (id, name, description, category, contentMd, scope, teamId, createdBy, createdByName, isShared, createdAt, updatedAt) | directive.dart |
| RemediationTask | 14 (id, jobId, taskNumber, title, description, promptMd, promptS3Key, findingIds, priority, status, assignedTo, assignedToName, jiraKey, createdAt) | remediation_task.dart |
| TechDebtItem | 13 (id, projectId, category, title, description, filePath, effortEstimate, businessImpact, status, firstDetectedJobId, resolvedJobId, createdAt, updatedAt) | tech_debt_item.dart |
| HealthSnapshot | 17 (id, projectId, jobId, healthScore, etc.) | health_snapshot.dart |
| Specification | 6 (id, jobId, name, specType, s3Key, createdAt) | specification.dart |
| ComplianceItem | 14 (id, specId, title, etc.) | compliance_item.dart |
| DependencyScan | 12 + DependencyVulnerability(11) | dependency_scan.dart |

### Pagination Model

```dart
@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;
  final bool first;
  final bool last;
}
```

### Domain-Specific Models

- **Courier:** ~20 classes (CollectionResponse, FolderTreeResponse, RequestDetailResponse, EnvironmentResponse, RunResultResponse, etc.) in `courier_models.dart`
- **Logger:** ~30 classes (LogSourceResponse, LogEntryResponse, TrapResponse, AlertChannelResponse, MetricResponse, DashboardResponse, TraceFlowResponse, RetentionPolicyResponse, AnomalyBaselineResponse, etc.) in `logger_models.dart`
- **Registry:** ~33 classes (ServiceRegistrationResponse, SolutionResponse, PortAllocationResponse, DependencyGraphResponse, TopologyResponse, WorkstationProfileResponse, etc.) in `registry_models.dart`
- **Vault:** ~14 classes (SecretResponse, SecretValueResponse, AccessPolicyResponse, RotationPolicyResponse, TransitKeyResponse, DynamicLeaseResponse, SealStatusResponse, AuditEntryResponse, etc.) in `vault_models.dart`
- **VCS:** 2 enums + 16 classes (VcsRepository, VcsBranch, VcsPullRequest, VcsCommit, VcsStash, RepoStatus, DiffResult, WorkflowRun, etc.) in `vcs_models.dart` — plain Dart with `fromGitHubJson()` factories
- **Jira:** 12 classes (JiraIssue, JiraProject, JiraSprint, JiraComment, JiraTransition, etc.) in `jira_models.dart` — `@JsonSerializable` with `@JsonKey` remapping
- **Scribe:** ScribeTab (12 fields), ScribeSettings (15 fields), DiffState, DiffLine, DiffSummary in `scribe_models.dart` + `scribe_diff_models.dart` — plain Dart
- **OpenAPI:** 9 classes (OpenApiSpec, OpenApiEndpoint, OpenApiSchema, etc.) in `openapi_spec.dart` — plain Dart

---

## 9. Service Layer

### HTTP Client Architecture (3 dedicated clients)

| Client | Base URL | Auth | Used By |
|---|---|---|---|
| `ApiClient` | `localhost:8090/api/v1` | JWT Bearer + auto-refresh | 16 API service classes |
| `RegistryApiClient` | `localhost:8090/api/v1/registry` | JWT Bearer + auto-refresh | RegistryApi |
| `VaultApiClient` | `localhost:8097/api/v1/vault` | JWT Bearer + auto-refresh | VaultApi |

All three share identical interceptor patterns: auth token injection, 401 auto-refresh (via CodeOps-Server `/auth/refresh`), error mapping to `ApiException` sealed hierarchy, correlation-ID logging.

### Cloud API Services (~420 total HTTP methods)

| Service | Methods | Backend |
|---|---|---|
| AdminApi | 8 | CodeOps-Server |
| AuthService | login, register, logout, refreshToken, forgotPassword, resetPassword, verifyMfa, setupMfa | CodeOps-Server |
| ComplianceApi | 11 | CodeOps-Server |
| CourierApiService | 73 | CodeOps-Server |
| DependencyApi | 21 | CodeOps-Server |
| DirectiveApi | 11 | CodeOps-Server |
| FindingApi | 8 | CodeOps-Server |
| HealthMonitorApi | 10 | CodeOps-Server |
| IntegrationApi | 3 | CodeOps-Server |
| JobApi | 11 | CodeOps-Server |
| LoggerApi | 104 | CodeOps-Server |
| MetricsApi | 4 | CodeOps-Server |
| PersonaApi | 11 | CodeOps-Server |
| ProjectApi | 9 | CodeOps-Server |
| RegistryApi | 77 | CodeOps-Registry |
| ReportApi | 7 | CodeOps-Server |
| TaskApi | 11 | CodeOps-Server |
| TeamApi | 8 | CodeOps-Server |
| TechDebtApi | 17 | CodeOps-Server |
| UserApi | 6 | CodeOps-Server |
| VaultApi | 67 | CodeOps-Vault |

### External API Services

| Service | Methods | Target |
|---|---|---|
| GitHubProvider | 13 | GitHub REST API v3 |
| JiraService | 17 | Jira Cloud REST API v3 |
| AnthropicApiService | 1 (listModels) | Anthropic API |

### Local Services

| Service | Purpose |
|---|---|
| AuthService | Login/logout, JWT storage in OS keychain |
| SecureStorageService | OS keychain read/write (macOS Keychain, Linux libsecret) |
| GitService | Local git CLI wrapper (clone, commit, push, branch, diff, stash, blame) |
| RepoManager | Local repo registration tracking in Drift DB |
| ProcessManager | Subprocess spawning with streaming stdout/stderr |
| ClaudeCodeDetector | Claude Code CLI detection (which, version, validate) |
| AgentDispatcher | Dispatches Claude CLI agent subprocesses with semaphore concurrency |
| AgentMonitor | Monitors agent processes with timeout |
| JobOrchestrator | 10-step job lifecycle (create → dispatch → parse → consolidate → sync) |
| VeraManager | QA consolidation: deduplication, health scoring, executive summary |
| ProgressAggregator | Real-time agent progress tracking via streams |
| AgentConfigService | Agent configuration (model, timeout, persona, files) from Drift DB |
| PersonaManager | Persona loading from assets + API |
| ReportParser | Parses agent Markdown reports into structured findings |
| TaskGenerator | Generates remediation task prompts from findings |
| HealthCalculator | Computes health scores from agent results |
| TechDebtTracker | Debt scoring, category breakdown, trend computation |
| DependencyScanner | Dependency health analysis |
| ScribeDiffService | Character-level and line-level diff computation |
| ScribeFileService | File open/save with native dialogs |
| ScribePersistenceService | Tab/settings persistence to Drift DB |
| SyncService | Cloud sync with local cache fallback |
| ExportService | Export to Markdown, PDF, ZIP, CSV |
| JiraMapper | Data transformation between CodeOps and Jira formats |
| OpenApiParser | Parses OpenAPI 3.0 specs into structured models |
| LogService | Singleton structured logger with ANSI colors and daily-rotated files |

---

## 10. Security Architecture

### Authentication Flow

1. User enters email/password on LoginPage
2. `AuthService.login()` → POST `/api/v1/auth/login` → receives JWT access + refresh tokens
3. Tokens stored in OS keychain via `SecureStorageService` (macOS Keychain)
4. `ApiClient` Dio interceptor attaches `Authorization: Bearer {token}` to all requests
5. On 401 → automatic refresh via `/api/v1/auth/refresh` with refresh token
6. If refresh fails → logout, clear keychain, redirect to login

### Token Storage

- Access token: OS keychain key `codeops_access_token`
- Refresh token: OS keychain key `codeops_refresh_token`
- GitHub PAT: OS keychain key `github_pat`
- Jira API tokens: OS keychain key `jira_api_token_{connectionId}`
- Anthropic API key: OS keychain key `anthropic_api_key`
- **Never stored in plaintext files or SharedPreferences**

### Authorization Model

- RBAC enforced server-side (OWNER, ADMIN, MEMBER, VIEWER)
- Client-side auth guard in GoRouter redirects unauthenticated users to `/login`
- `authStateProvider` (StreamProvider) tracks auth state across the app

### CORS / Network Security

- Client app — no CORS configuration needed
- All HTTP requests include `X-Correlation-ID` header (UUID v4 prefix)
- `GIT_TERMINAL_PROMPT=0` env var prevents git from prompting for credentials

---

## 11. Error Handling

### API Exception Hierarchy (Sealed Class)

```
ApiException (sealed)
├── BadRequestException      → 400
├── UnauthorizedException    → 401
├── ForbiddenException       → 403
├── NotFoundException        → 404
├── ConflictException        → 409
├── ValidationException      → 422
├── RateLimitException       → 429
├── ServerException          → 500+
├── NetworkException         → connection errors
└── TimeoutException         → request timeout
```

**File:** `lib/services/cloud/api_exceptions.dart`

### Error Display Pattern

- `ErrorPanel.fromException(error, onRetry)` — maps ApiException subtypes to user-friendly messages
- Every async view uses `.when(loading:, error:, data:)` pattern with retry
- `showToast()` for transient errors (SnackBar with accent border)
- `showConfirmDialog()` for destructive actions

### Service-Level Error Handling

- `SyncService` falls back to local Drift cache on `NetworkException`/`TimeoutException`
- `ClaudeCodeDetector` and `LogService` never throw (catch-all returns null/false)
- `JiraService` handles 429 rate limiting with Retry-After header parsing
- `GitHubProvider` tracks rate limits and warns when low

---

## 12. Notification / Messaging Layer

- **No local push notifications** — desktop app, not mobile
- **No message broker client** — all communication via HTTP to CodeOps-Server
- **Server-side notifications** — CodeOps-Server handles email (AWS SES), Teams/Slack webhooks
- **In-app notifications** — `showToast()` for transient messages
- **Claude Code subprocess communication** — streaming stdout/stderr via `ProcessManager`

---

## 13. Test Coverage

### Test Inventory

| Category | Files | Test Methods |
|---|---|---|
| Models | 30 | 1,264 |
| Services | 53 | 854 |
| Providers | 25 | 560 |
| Widgets | 195 | 1,516 |
| Pages | 45 | 489 |
| Router | 1 | 4 |
| Navigation | 1 | 9 |
| Database | 2 | 13 |
| Theme | 2 | 8 |
| Utils | 5 | 68 |
| Integration (in-tree) | 1 | 20 |
| Integration (standalone) | 5 | 8 |
| **TOTAL** | **353** | **4,221** |

### Test Infrastructure

- **Framework:** `flutter_test` (SDK) — all files
- **Mocking:** `mocktail ^1.0.4` — 46 files
- **State testing:** `flutter_riverpod` ProviderContainer — 153 files
- **Integration tests:** `integration_test` SDK — 5 files
- **No Testcontainers** — client app, not server
- **No test-specific config files** — mocks defined inline per test

---

## 14. Cross-Cutting Patterns & Conventions

### Architecture Pattern

**Pages → Providers → Services → API Client → Server**

- `Provider` for singletons (API services, database)
- `StateProvider` for simple UI state (filters, selections, toggles)
- `FutureProvider` / `.family` for async data
- `StreamProvider` for reactive streams (auth state, job progress, seal status polling)
- `StateNotifierProvider` for complex state machines (wizards, scribe tabs, agent progress)

### Provider Distribution (~350 total)

| Type | Count |
|---|---|
| Provider (singletons/derived) | ~60 |
| StateProvider (UI state) | ~120 |
| FutureProvider (async data) | ~100 |
| FutureProvider.family (parameterized) | ~50 |
| FutureProvider.autoDispose | ~15 |
| StreamProvider | 4 |
| StateNotifierProvider | 8 |

### Naming Conventions

- **Pages:** `{Feature}Page` (ConsumerStatefulWidget or ConsumerWidget)
- **Widgets:** `{Feature}{Role}` (e.g., `DebtInventory`, `SealStatusBadge`)
- **Providers:** `{feature}{Entity}Provider` (e.g., `teamProjectsProvider`, `vaultSecretsProvider`)
- **API services:** `{Domain}Api` (e.g., `VaultApi`, `RegistryApi`, `CourierApiService`)
- **Enum values:** camelCase in Dart, SCREAMING_SNAKE_CASE in JSON (custom converters)

### Package Structure

```
lib/
├── models/       — DTOs, enums, view models (29 files)
├── services/     — Business logic, HTTP clients, platform (56 files)
│   ├── agent/    — AI agent config, persona, report parsing, task generation
│   ├── analysis/ — Health, tech debt, dependency analysis
│   ├── auth/     — Authentication, secure storage
│   ├── cloud/    — All HTTP API clients (16+ domain APIs)
│   ├── data/     — Scribe persistence, diff, file I/O, sync
│   ├── integration/ — Export service
│   ├── jira/     — Jira API integration
│   ├── logging/  — Structured log service
│   ├── orchestration/ — Job lifecycle, agent dispatch, monitoring
│   ├── platform/ — Claude Code detection, process management
│   └── vcs/      — Git, GitHub, repo management
├── providers/    — Riverpod state management (28 files)
├── pages/        — Route-level screens (50 files)
├── widgets/      — Reusable UI components (257 files)
├── theme/        — Colors, typography, theme data
├── utils/        — Date, file, string, fuzzy matcher utilities
└── database/     — Drift tables and database
```

### Widget Type Distribution (257 files)

| Type | Count |
|---|---|
| ConsumerStatefulWidget | ~62 |
| StatelessWidget | ~82 |
| ConsumerWidget | ~38 |
| StatefulWidget | ~42 |
| Non-widget (controllers, utilities) | ~15 |
| Top-level functions | ~5 |

### Documentation Comments

- **DartDoc present on all classes and public methods** — 100% coverage across lib/
- File-level `/// description` + `library;` directive on every file
- Method-level `/// description` on every public method

### Logging

- Centralized via `LogService` singleton (accessed as `log` global)
- Daily-rotated log files with 7-day auto-purge
- ANSI color codes for console output
- Level/tag gating
- Never crashes the app (all I/O wrapped in catch-all)

---

## 15. Known Issues, TODOs, and Technical Debt

**Zero TODO/FIXME/HACK/XXX/WORKAROUND/TEMPORARY markers found in `lib/`.**

The only matches are string literals describing what agents check for:
- `lib/services/agent/agent_config_service.dart:427` — `description: 'Checks for missing features, TODOs, and incomplete implementations'`
- `lib/widgets/progress/agent_card.dart:54` — `description: 'TODOs, stubs, placeholders, dead code'`

### Observations (from audit analysis)

1. **Duplicate provider declarations:** `findingApiProvider` and `jobFindingsProvider` declared in both `finding_providers.dart` and `job_providers.dart`. `jiraConnectionsProvider` declared in both `jira_providers.dart` and `project_providers.dart`.
2. **Unused dev dependencies:** `freezed` and `riverpod_generator` are in dev_dependencies but no `.freezed.dart` files exist and no `@riverpod` annotations are used. All models use `@JsonSerializable` and providers are manually defined.
3. **No custom lint rules:** `analysis_options.yaml` uses default `flutter_lints` with no custom rules enabled.

---

## 16. OpenAPI Specification

**Not applicable.** CodeOps-Client is a Flutter desktop application that consumes APIs. It does not expose HTTP endpoints. A stub file (`CodeOps-Client-OpenAPI.yaml`) has been created to satisfy the audit template requirement.

For the ~420 API methods the client calls, see Section 9 (Service Layer).

---

## 17. Database — Local Schema

CodeOps-Client uses **Drift** (SQLite) for local caching. The database has **18 tables** at **schema version 4**. This is a client-side cache — the source of truth is CodeOps-Server's PostgreSQL database. See Section 6 for the full table inventory.

No live database audit is applicable — the SQLite database is created/managed by Drift's schema migration system at app startup.

---

## 18. MESSAGE BROKER DETECTION

No message broker (Kafka, RabbitMQ, SQS/SNS) detected in this project. CodeOps-Client is a desktop application that communicates with backends via HTTP only.

---

## 19. CACHE DETECTION

No Redis or external caching layer detected. Local caching is handled by the Drift SQLite database (18 tables). The `SyncService` manages cloud-to-local cache synchronization with fallback to local data on network errors.

---

## 20. Environment Variable Inventory

CodeOps-Client is a Flutter desktop application. It does not use environment variables. All configuration is in `lib/utils/constants.dart` (AppConstants class).

| Constant | Value | Purpose |
|---|---|---|
| apiBaseUrl | `http://localhost:8090` | CodeOps-Server URL |
| apiPrefix | `/api/v1` | API path prefix |
| registryApiPrefix | `/api/v1/registry` | Registry API prefix |
| vaultApiBaseUrl | `http://localhost:8097` | Vault server URL |
| vaultApiPrefix | `/api/v1/vault` | Vault API prefix |
| defaultClaudeModel | `claude-sonnet-4-5-20250929` | Default AI model |
| maxConcurrentAgents | 6 | Max parallel agents |
| agentTimeoutMinutes | 30 | Agent timeout |
| maxTurns | 200 | Max agent turns |
| passThreshold | 80 | Health pass threshold |
| warnThreshold | 60 | Health warn threshold |

**Note:** API URLs are hardcoded for local development. Production deployment would require making these configurable (e.g., via `--dart-define` or settings).

---

## 21. Inter-Service Communication Map

### Outbound HTTP Dependencies

| Target | Client Class | Auth | Purpose |
|---|---|---|---|
| CodeOps-Server (:8090) | ApiClient | JWT Bearer | All core platform APIs (16 services) |
| CodeOps-Registry (:8090/registry) | RegistryApiClient | JWT Bearer | Service registry APIs |
| CodeOps-Vault (:8097) | VaultApiClient | JWT Bearer | Secrets management APIs |
| GitHub API | GitHubProvider (Dio) | PAT Bearer | Repos, branches, PRs, commits, CI |
| Jira Cloud API | JiraService (Dio) | Basic Auth | Issues, comments, projects, sprints |
| Anthropic API | AnthropicApiService (Dio) | x-api-key | Model listing |

### Local Process Dependencies

| Target | Service | Purpose |
|---|---|---|
| `git` CLI | GitService | Clone, commit, push, branch, diff, stash |
| `claude` CLI | AgentDispatcher | AI agent subprocess execution |

### Inbound Dependencies

None — CodeOps-Client is a desktop application, not a server.

---

## Router — Full Route Inventory (51 routes)

**File:** `lib/router.dart`

| Route | Page | Section |
|---|---|---|
| `/login` | LoginPage | Auth |
| `/` | HomePage | Dashboard |
| `/projects` | ProjectsPage | Projects |
| `/projects/:id` | ProjectDetailPage | Projects |
| `/audit` | AuditWizardPage | QA |
| `/bug-investigator` | BugInvestigatorPage | QA |
| `/jobs` | JobHistoryPage | QA |
| `/jobs/:id/progress` | JobProgressPage | QA |
| `/jobs/:id/report` | JobReportPage | QA |
| `/findings` | FindingsExplorerPage | QA |
| `/compliance` | ComplianceWizardPage | QA |
| `/tasks` | TaskListPage | QA |
| `/tasks/manager` | TaskManagerPage | QA |
| `/tech-debt` | TechDebtPage | Maintain |
| `/dependencies` | DependencyScanPage | Maintain |
| `/health` | HealthDashboardPage | Maintain |
| `/personas` | PersonasPage | Configure |
| `/personas/new` | PersonaEditorPage | Configure |
| `/personas/:id/edit` | PersonaEditorPage | Configure |
| `/directives` | DirectivesPage | Configure |
| `/github` | GitHubBrowserPage | VCS |
| `/jira` | JiraBrowserPage | Integrations |
| `/settings` | SettingsPage | Settings |
| `/admin` | AdminHubPage | Admin |
| `/scribe` | ScribePage | Tools |
| `/registry` | RegistryDashboardPage | Registry |
| `/registry/services` | ServiceListPage | Registry |
| `/registry/services/new` | ServiceFormPage | Registry |
| `/registry/services/:id` | ServiceDetailPage | Registry |
| `/registry/services/:id/edit` | ServiceFormPage | Registry |
| `/registry/solutions` | SolutionListPage | Registry |
| `/registry/solutions/:id` | SolutionDetailPage | Registry |
| `/registry/ports` | PortAllocationPage | Registry |
| `/registry/dependencies` | DependencyGraphPage | Registry |
| `/registry/impact` | ImpactAnalysisPage | Registry |
| `/registry/topology` | TopologyPage | Registry |
| `/registry/infra` | InfraResourcesPage | Registry |
| `/registry/routes` | ApiRoutesPage | Registry |
| `/registry/config` | ConfigGeneratorPage | Registry |
| `/registry/workstations` | WorkstationListPage | Registry |
| `/registry/workstations/:id` | WorkstationDetailPage | Registry |
| `/registry/api-docs` | ApiDocsPage | Registry |
| `/vault` | VaultDashboardPage | Vault |
| `/vault/secrets` | VaultSecretsPage | Vault |
| `/vault/secrets/:id` | VaultSecretDetailPage | Vault |
| `/vault/policies` | VaultPoliciesPage | Vault |
| `/vault/policies/:id` | VaultPolicyDetailPage | Vault |
| `/vault/rotation` | VaultRotationPage | Vault |
| `/vault/transit` | VaultTransitPage | Vault |
| `/vault/seal` | VaultSealPage | Vault |
| `/vault/audit` | VaultAuditPage | Vault |
