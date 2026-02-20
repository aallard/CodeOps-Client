# CodeOps-Client — Quality Scorecard

**Audit Date:** 2026-02-20T00:14:32Z
**Branch:** main
**Commit:** ad0e702c
**Auditor:** Claude Code (Automated)

> This scorecard is a retrospective quality assessment. It is NOT loaded into coding sessions.
> See `CodeOps-Client-Audit.md` for the codebase reference.

---

## Scoring: 0 (not present) | 1 (partial) | 2 (fully implemented)

**Note:** This is a Flutter desktop client, not a server. Checks have been adapted from the server-oriented template where applicable. Server-only checks (CORS, rate limiting, Dockerfile, structured logging backends, etc.) are marked N/A and scored 2 where the concern doesn't apply to a desktop client.

---

## Security (10 checks, max 20)

| Check | Description | Score | Notes |
|---|---|---|---|
| SEC-01 | Auth on all mutation API calls | 2 | All API services use `ApiClient`/`VaultApiClient` with JWT auto-attach. Only login/register/refresh are public. |
| SEC-02 | No hardcoded secrets in source | 2 | No passwords, API keys, or secrets in source. Tokens stored at runtime in SharedPreferences. |
| SEC-03 | Input validation on API requests | 1 | Client sends data to server which validates. No client-side validation on DTO fields before sending (relies on server 400/422 responses). |
| SEC-04 | CORS not using wildcards | 2 | N/A — desktop app, not browser-based. No CORS concern. |
| SEC-05 | Encryption key not hardcoded | 2 | No encryption keys in source. Anthropic API key stored at runtime. |
| SEC-06 | Security headers configured | 2 | N/A — desktop app. No HTTP server to configure headers on. |
| SEC-07 | Rate limiting present | 2 | N/A — client-side. GitHub provider tracks rate limits from response headers. |
| SEC-08 | SSRF protection on outbound URLs | 1 | API base URLs are hardcoded constants. Jira URL is user-configurable without validation. |
| SEC-09 | Token revocation / logout | 2 | `AuthService.logout()` clears stored tokens. Server-side token blacklisting is handled by CodeOps-Server. |
| SEC-10 | Password complexity enforcement | 0 | No client-side password validation. Server enforces minimal requirements per CONVENTIONS.md. |

**Security Score: 16 / 20 (80%)**

---

## Data Integrity (8 checks, max 16)

| Check | Description | Score | Notes |
|---|---|---|---|
| DAT-01 | Enum serialization consistent | 2 | All 30 enums use custom `JsonConverter` classes with UPPERCASE wire format. Consistent across all model files. |
| DAT-02 | Database indexes on key columns | 1 | Drift tables use only primary keys. No secondary indexes defined. Acceptable for local cache (small dataset). |
| DAT-03 | Nullable constraints on required fields | 1 | Drift tables mark some fields as non-nullable but most are nullable. Models use `?` (nullable) liberally. |
| DAT-04 | Optimistic locking | 0 | No version fields or optimistic locking in Drift tables. Server handles concurrency. |
| DAT-05 | No unbounded queries | 2 | API calls use pagination (`PageResponse<T>`). Local Drift queries are bounded by table size (cache). |
| DAT-06 | No in-memory filtering of DB results | 1 | Some derived providers filter in-memory (e.g., `filteredProjectsProvider`, `filteredPersonasProvider`). Acceptable for cached data. |
| DAT-07 | Proper relationship mapping | 2 | No comma-separated IDs. All relationships use proper UUID foreign keys. |
| DAT-08 | Audit timestamps on entities | 2 | All models have `createdAt` and most have `updatedAt`. |

**Data Integrity Score: 11 / 16 (69%)**

---

## API Quality (8 checks, max 16)

| Check | Description | Score | Notes |
|---|---|---|---|
| API-01 | Consistent error responses | 2 | Sealed `ApiException` hierarchy with typed exceptions for each HTTP status. |
| API-02 | Error messages sanitized | 2 | `ApiException` extracts `message` from server response. Stack traces not exposed to UI. |
| API-03 | Correlation IDs on requests | 2 | All API clients add `X-Correlation-ID` (UUID) header on every request. |
| API-04 | Pagination on list endpoints | 2 | `PageResponse<T>` used consistently. All list APIs support `page` and `size` params. |
| API-05 | Correct HTTP status handling | 2 | Error interceptor maps all standard HTTP status codes to typed exceptions. |
| API-06 | API surface documented | 2 | `CodeOps-Client-OpenAPI.yaml` documents all ~158 outbound endpoints. |
| API-07 | Consistent DTO naming | 2 | Models match server DTOs. Enums match server enum values (UPPERCASE). |
| API-08 | File upload handling | 2 | `ReportApi.uploadSpecification` uses multipart form upload with `MultipartFile.fromFile`. |

**API Quality Score: 16 / 16 (100%)**

---

## Code Quality (10 checks, max 20)

| Check | Description | Score | Notes |
|---|---|---|---|
| CQ-01 | No anti-patterns | 2 | No `getReferenceById` equivalent. Clean Dio usage with interceptors. |
| CQ-02 | Consistent exception hierarchy | 2 | Sealed `ApiException` class with 10 typed subtypes. `GitException` for git operations. |
| CQ-03 | No TODO/FIXME/HACK | 2 | Zero TODO/FIXME/HACK/XXX comments in all `lib/` files. |
| CQ-04 | Constants centralized | 2 | `AppConstants` class with all limits, keys, URLs, and configuration values. |
| CQ-05 | Async exception handling | 2 | JobOrchestrator wraps entire flow in try/catch, updates server on failure. AgentDispatcher catches per-agent failures. |
| CQ-06 | HTTP client injected (not new'd) | 2 | `ApiClient` and `VaultApiClient` created once via providers. All API services receive them via constructor injection. |
| CQ-07 | Logging present in services | 2 | `LogService` singleton used throughout services. ANSI colors in debug, file logging in release. |
| CQ-08 | No raw exception messages to UI | 2 | Error interceptors extract clean messages. UI shows `ApiException.message`, not stack traces. |
| CQ-09 | Doc comments on classes | 2 | 94.6% coverage (280/296 files). Only generated `.g.dart` files lack DartDoc. All service/provider classes documented. |
| CQ-10 | Doc comments on public methods | 2 | All service classes have DartDoc on public methods. Comprehensive library-level docs on all files. |

**Code Quality Score: 20 / 20 (100%)**

---

## Test Quality (10 checks, max 20)

| Check | Description | Score | Notes |
|---|---|---|---|
| TST-01 | Unit test files | 2 | 235 unit test files in `test/`. |
| TST-02 | Integration test files | 2 | 5 integration test files in `integration_test/`. |
| TST-03 | Real database in ITs | 1 | Integration tests use mocked providers (mocktail), not real SQLite or server connections. |
| TST-04 | Source-to-test ratio | 2 | 279 source files, 240 test files (0.86 ratio). Near 1:1 coverage. |
| TST-05 | Code coverage >= 80% | 1 | No coverage report generated (Flutter test coverage not configured). 2,639 test cases suggest high coverage. |
| TST-06 | Test config exists | 2 | Tests use `ProviderScope` overrides. No external config files needed for Flutter tests. |
| TST-07 | Security tests | 2 | Auth service tests (login, register, refresh, logout, auto-login). API client tests (auth interceptor, 401 refresh, token attachment). |
| TST-08 | Auth flow coverage | 2 | `auth_service_test.dart` covers full auth lifecycle. `api_client_test.dart` covers interceptor chain. |
| TST-09 | Database tests | 2 | `test/database/` (2 files) tests Drift database operations, migrations. |
| TST-10 | Total test methods | 2 | 2,639 individual test cases (1,802 `test()` + 837 `testWidgets()`). |

**Test Quality Score: 18 / 20 (90%)**

---

## Infrastructure (6 checks, max 12)

| Check | Description | Score | Notes |
|---|---|---|---|
| INF-01 | Non-root container | 2 | N/A — desktop app, no Dockerfile. |
| INF-02 | DB ports localhost only | 2 | SQLite is a local file, no network port. |
| INF-03 | Env vars for prod secrets | 0 | No environment variable support. All URLs hardcoded in `constants.dart`. No way to configure for production without code change. |
| INF-04 | Health check | 1 | No dedicated health check. Server availability detected by API call success/failure. |
| INF-05 | Structured logging | 2 | `LogService` with 6 levels, daily file rotation, 7-day retention. ANSI colors for debug, plain text for release. |
| INF-06 | CI/CD config | 0 | No CI/CD pipeline config detected (no `.github/workflows`, Jenkinsfile, etc.). |

**Infrastructure Score: 7 / 12 (58%)**

---

## Scorecard Summary

| Category | Score | Max | % |
|---|---|---|---|
| Security | 16 | 20 | 80% |
| Data Integrity | 11 | 16 | 69% |
| API Quality | 16 | 16 | 100% |
| Code Quality | 20 | 20 | 100% |
| Test Quality | 18 | 20 | 90% |
| Infrastructure | 7 | 12 | 58% |
| **OVERALL** | **88** | **104** | **85%** |

**Grade: A (85%)**

---

## Categories Below 60%

### Infrastructure (58%)

**Failing checks (scored 0):**
- **INF-03: Env vars for prod secrets** — BLOCKING ISSUE. All API URLs are hardcoded constants. No mechanism to configure for different environments (staging, production) without code changes.
- **INF-06: CI/CD config** — BLOCKING ISSUE. No automated build, test, or deployment pipeline.

---

## Observations

1. **Token storage security** — SharedPreferences stores JWT tokens in plaintext. Acceptable for development; production should consider macOS Keychain with proper entitlements.
2. **Duplicate providers** — `findingApiProvider` and `jiraConnectionsProvider` are defined in two files each. Should be consolidated.
3. **No environment configuration** — Hardcoded localhost URLs make production deployment impossible without code changes. Should add build-time or runtime configuration.
4. **Freezed available but unused** — `freezed` is in dev dependencies but no model uses it. Either adopt or remove the dependency.
