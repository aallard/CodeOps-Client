# CodeOps-Client — Quality Scorecard

**Audit Date:** 2026-03-03T16:14:05Z
**Branch:** main
**Commit:** bbb93bdc7a5ebbd549c273b2de0fe3e02e50000e
**Purpose:** Quality assessment (NOT loaded into coding sessions)

---

## Security (10 checks, max 20)

*Adapted for Flutter desktop client — server-side checks (CSRF, HTTPS, rate limiting) are N/A.*

| Check | Result | Score |
|---|---|---|
| SEC-01 Token storage uses platform keychain | YES — flutter_secure_storage (macOS Keychain) | 2 |
| SEC-02 JWT token attached via interceptor | YES — ApiClient auth interceptor on all non-public paths | 2 |
| SEC-03 SQL injection prevention (parameterized queries) | YES — Drift uses parameterized queries; DataLens raw SQL is user-intentional | 2 |
| SEC-04 No hardcoded secrets in source | YES — tokens in Keychain, no secrets in source code | 2 |
| SEC-05 Token refresh on 401 | YES — refresh interceptor retries once, then logout | 2 |
| SEC-06 Sensitive data logging prevented | YES — LogService does not log tokens/passwords | 2 |
| SEC-07 Auth state reactive redirect | YES — GoRouter redirects unauthenticated users to /login | 2 |
| SEC-08 Secure storage cleared on logout | YES — AuthService.logout() calls clearAll() on SecureStorage + DB | 2 |
| SEC-09 No plaintext password storage | PARTIAL — DataLens connection passwords stored as plaintext in SQLite (TD-07) | 1 |
| SEC-10 Public paths restricted | YES — only /auth/login, /auth/register, /auth/refresh, /health are public | 2 |

**Security Score: 19 / 20 (95%)**

---

## Data Integrity (8 checks, max 16)

*Adapted for Flutter client — checks focus on local cache and data handling.*

| Check | Result | Score |
|---|---|---|
| DI-01 All tables have audit fields (createdAt/updatedAt) | 23/25 tables have createdAt; SyncMetadata and ScribeSettings lack it | 1 |
| DI-02 Primary keys defined on all tables | YES — all 25 tables have explicit primaryKey override | 2 |
| DI-03 Schema migrations sequential and complete | YES — v1→v9 migrations handle all column/table additions | 2 |
| DI-04 Nullable fields properly marked | YES — Drift nullable() used consistently | 2 |
| DI-05 Enum fields stored consistently | YES — all enums as text (SCREAMING_SNAKE_CASE) | 2 |
| DI-06 Sync metadata tracked | YES — SyncMetadata table with ETag support | 2 |
| DI-07 Transaction boundaries defined | YES — clearAllTables() uses transaction(); DataLens supports explicit transactions | 2 |
| DI-08 Offline cache cleared on logout | YES — CodeOpsDatabase.clearAllTables() called on logout | 2 |

**Data Integrity Score: 15 / 16 (94%)**

---

## API Quality (8 checks, max 16)

*Adapted for Flutter client — checks focus on API consumption patterns.*

| Check | Result | Score |
|---|---|---|
| API-01 Consistent error handling | YES — ApiException hierarchy with typed exceptions mapped from HTTP codes | 2 |
| API-02 Pagination supported | YES — API services accept page/size params where server supports it | 2 |
| API-03 Request/response logging | YES — ApiClient logging interceptor with request ID correlation | 2 |
| API-04 Proper timeout configuration | YES — connect 15s, receive 30s, send 15s | 2 |
| API-05 API versioning in paths | YES — all paths use /api/v1/ prefix | 2 |
| API-06 Token refresh mechanism | YES — automatic 401 retry with token refresh | 2 |
| API-07 Typed error responses | YES — server errors mapped to ApiException subtypes | 2 |
| API-08 Multiple API client separation | YES — ApiClient (8090), RegistryApiClient (8090), VaultApiClient (8097) | 2 |

**API Quality Score: 16 / 16 (100%)**

---

## Code Quality (11 checks, max 22)

| Check | Result | Score |
|---|---|---|
| CQ-01 Riverpod dependency injection | YES — all services created via Provider, no service locator or global singletons except database | 2 |
| CQ-02 Consistent state management | YES — Riverpod exclusively, 6 provider patterns used appropriately | 2 |
| CQ-03 No print() / debugPrint() in production | YES — LogService used consistently | 2 |
| CQ-04 Logging framework used | YES — centralized LogService with log levels | 2 |
| CQ-05 Constants extracted | YES — AppConstants class with 120+ static constants | 2 |
| CQ-06 Models separate from UI | YES — models/, services/, providers/ clearly separated from pages/, widgets/ | 2 |
| CQ-07 Service layer exists | YES — 89 service files across 14 subdirectories | 2 |
| CQ-08 Consistent serialization pattern | YES — @JsonSerializable with .g.dart code generation | 2 |
| CQ-09 Doc comments on classes/modules = 100% | **FAIL (1,615/2,337 = 69.1%) — BLOCKING** | 0 |
| CQ-10 Doc comments on public methods = 100% | **FAIL (1,503/3,911 = 38.4%) — BLOCKING** | 0 |
| CQ-11 No TODO/FIXME/placeholder/stub | PASS — grep hits are legitimate UI text, not incomplete code | 2 |

**CQ-09 and CQ-10 are BLOCKING: Code Quality category scores 0.**

**Code Quality Score: 0 / 22 (0%) — BLOCKED**

---

## Test Quality (12 checks, max 24)

| Check | Result | Score |
|---|---|---|
| TST-01 Unit test files | 580 unit test files | 2 |
| TST-02 Integration test files | 5 integration test files | 2 |
| TST-03 Mock framework used | YES — mocktail ^1.0.4 | 2 |
| TST-04 Source-to-test ratio | 580 test / 622 source = 0.93:1 | 2 |
| TST-05 Test coverage = 100% | **FAIL (49,933/87,947 = 56.8%) — BLOCKING** | 0 |
| TST-06 All tests passing | YES — 6,658 tests, 0 failures | 2 |
| TST-07 Provider tests exist | YES — providers tested via widget tests with ProviderScope | 2 |
| TST-08 Service tests exist | YES — service layer tested with mocktail mocks | 2 |
| TST-09 Widget tests exist | YES — page and widget tests with MaterialApp + GoRouter wrappers | 2 |
| TST-10 Model serialization tests | YES — JSON round-trip tests for all @JsonSerializable models | 2 |
| TST-11 Enum alignment tests | YES — enums_alignment_test.dart verifies server enum parity | 2 |
| TST-12 Total test count | 6,658 test cases | 2 |

**TST-05 is BLOCKING: Test Quality category scores 0.**

**Test Quality Score: 0 / 24 (0%) — BLOCKED**

---

## Infrastructure (6 checks, max 12)

*Adapted for Flutter desktop client.*

| Check | Result | Score |
|---|---|---|
| INF-01 Window management configured | YES — window_manager with size constraints | 2 |
| INF-02 Local database file in standard location | YES — path_provider getApplicationSupportDirectory() | 2 |
| INF-03 Connectivity detection | YES — connectivity_plus for network status | 2 |
| INF-04 Structured logging | YES — LogService with configurable levels | 2 |
| INF-05 CI/CD config | **NO — no pipeline detected** | 0 |
| INF-06 Code generation automated | YES — build_runner for Drift, JSON, Riverpod | 2 |

**Infrastructure Score: 10 / 12 (83%)**

---

## Security Vulnerabilities — Snyk (5 checks, max 10)

| Check | Result | Score |
|---|---|---|
| SNYK-01 Zero critical dependency vulnerabilities | PASS — 0 critical | 2 |
| SNYK-02 Zero high dependency vulnerabilities | PASS — 0 high | 2 |
| SNYK-03 Medium/low dependency vulnerabilities | PASS — 0 total | 2 |
| SNYK-04 Zero code (SAST) errors | PASS — 0 errors | 2 |
| SNYK-05 Zero code (SAST) warnings | PASS — 0 warnings | 2 |

**Snyk Vulnerabilities Score: 10 / 10 (100%)**

---

## Scorecard Summary

| Category | Score | Max | % |
|---|---|---|---|
| Security | 19 | 20 | 95% |
| Data Integrity | 15 | 16 | 94% |
| API Quality | 16 | 16 | 100% |
| Code Quality | **0** | 22 | **0%** |
| Test Quality | **0** | 24 | **0%** |
| Infrastructure | 10 | 12 | 83% |
| Snyk Vulnerabilities | 10 | 10 | 100% |
| **OVERALL** | **70** | **120** | **58%** |

**Grade: C (55-69%)**

---

## BLOCKING ISSUES

These must be resolved before the project can achieve a passing grade:

| Issue | Current | Required | Gap |
|---|---|---|---|
| CQ-09: Class doc coverage | 69.1% (1,615/2,337) | 100% | 722 undocumented classes |
| CQ-10: Method doc coverage | 38.4% (1,503/3,911) | 100% | 2,408 undocumented methods |
| TST-05: Test coverage | 56.8% (49,933/87,947 lines) | 100% | 38,014 uncovered lines |
| INF-05: CI/CD pipeline | None | Present | Create GitHub Actions workflow |

**Without blocking issues, projected score: 86/120 = 72% (Grade B)**

---

## Failing Checks Detail

### Code Quality (0% — BLOCKED)
- **CQ-09**: 722 classes/enums/mixins/extensions missing DartDoc `///` comments. Primarily in widgets/ (430 files) and some service files.
- **CQ-10**: 2,408 public methods/functions missing DartDoc `///` comments. Spread across all source directories.

### Test Quality (0% — BLOCKED)
- **TST-05**: 56.8% line coverage. Major gaps likely in widget files (430 widget files with complex UI logic) and some service edge paths.

### Infrastructure (83%)
- **INF-05**: No CI/CD pipeline. Recommend adding GitHub Actions for: `flutter analyze`, `flutter test --coverage`, `dart run build_runner build`, coverage enforcement.
