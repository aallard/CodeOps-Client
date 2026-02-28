# CodeOps-Client — Quality Scorecard

**Audit Date:** 2026-02-28T19:50:18Z
**Branch:** main
**Commit:** 5ce2214b61e8937db039094fde3a0fe4e013c369

---

## Security (Adapted for Desktop Client)

| Check | Result | Score |
|---|---|---|
| SEC-01 Token-based auth (JWT Bearer) | YES — ApiClient auth interceptor | 2 |
| SEC-02 Token refresh on 401 | YES — refresh interceptor with single retry | 2 |
| SEC-03 No hardcoded secrets in source | PASS — tokens in SharedPreferences, not code | 2 |
| SEC-04 CSRF N/A (desktop app) | N/A | 2 |
| SEC-05 Rate limit handling | YES — RateLimitException with retryAfterSeconds | 2 |
| SEC-06 No sensitive data in logs | PASS — logging interceptor never logs bodies or tokens | 2 |
| SEC-07 Input validation on forms | PARTIAL — login form validates, some forms lack validation | 1 |
| SEC-08 Auth state management | YES — AuthNotifier + GoRouter redirect | 2 |
| SEC-09 Secrets not in source code | PASS — API keys in SharedPreferences | 2 |
| SEC-10 SharedPreferences not Keychain | WARN — OK for dev, not prod | 1 |
| **Subtotal** | | **18/20** |

---

## Data Integrity (Adapted for Client)

| Check | Result | Score |
|---|---|---|
| DI-01 Models have audit fields | YES — createdAt, updatedAt on most models | 2 |
| DI-02 Immutable models | PARTIAL — @JsonSerializable with final fields, not Freezed | 1 |
| DI-03 Local DB managed by Drift | YES — auto-migration | 2 |
| DI-04 Unique constraints in local DB | YES — Drift schema definitions | 2 |
| DI-05 Relationships modeled correctly | YES — teamId, projectId FK references | 2 |
| DI-06 Nullable fields documented | YES — all nullable fields typed as `Type?` | 2 |
| DI-07 Logout clears local data | YES — `clearAllTables()` on logout | 2 |
| DI-08 Transaction boundaries | N/A — local cache only | 2 |
| **Subtotal** | | **15/16** |

---

## API Quality (Client-Side)

| Check | Result | Score |
|---|---|---|
| API-01 Typed error handling | YES — sealed ApiException hierarchy | 2 |
| API-02 Pagination support | YES — API services accept page/size params | 2 |
| API-03 Request validation | PARTIAL — some services validate before API call | 1 |
| API-04 Proper error mapping | YES — status code → typed exception | 2 |
| API-05 API versioning | YES — `/api/v1/` prefix | 2 |
| API-06 Request logging | YES — correlation ID, timing, no body logging | 2 |
| API-07 Retry/refresh logic | YES — automatic token refresh on 401 | 2 |
| API-08 Separate API clients per service | YES — 28 API service classes | 2 |
| **Subtotal** | | **15/16** |

---

## Code Quality

| Check | Result | Score |
|---|---|---|
| CQ-01 Dependency injection (Riverpod) | YES — all services via Provider | 2 |
| CQ-02 Consistent model pattern | YES — @JsonSerializable on all models | 2 |
| CQ-03 No print() statements | PASS — 0 actual print() calls (false positives only) | 2 |
| CQ-04 Centralized logging | YES — LogService with 238 log call sites | 2 |
| CQ-05 Constants extracted | YES — AppConstants with 130+ constants | 2 |
| CQ-06 Models separate from UI | YES — models/, services/, pages/, widgets/ | 2 |
| CQ-07 Service layer exists | YES — 60 service files | 2 |
| CQ-08 Provider layer exists | YES — 30 provider files | 2 |
| CQ-09 Doc comments on classes = 100% | **FAIL (887/1673 = 53%)** | 0 |
| CQ-10 Doc comments on methods = 100% | **FAIL (1740/3514 = 49.5%)** | 0 |
| CQ-11 No TODO/FIXME/placeholder/stub | PASS (0 found) | 2 |
| **Subtotal** | **BLOCKED by CQ-09/CQ-10** | **0/22** |

**Note:** CQ-09 and CQ-10 are BLOCKING. Many undocumented classes are in models/ (which the template exempts as DTOs/entities) and in widgets/ (which are primarily UI components). The 53% figure includes all classes — if models and database files were excluded (as DTOs/entities), coverage would be higher.

---

## Test Quality

| Check | Result | Score |
|---|---|---|
| TST-01 Unit test files | 405 files | 2 |
| TST-02 Integration test files | 5 files | 2 |
| TST-03 Mock framework | YES — mocktail | 2 |
| TST-04 Source-to-test ratio | 405 tests / 459 source = 0.88 | 1 |
| TST-05 Test coverage = 100% | **NOT MEASURED** — flutter test --coverage not run (would require full build) | 0 |
| TST-06 Test config exists | YES — test/ directory mirrors lib/ structure | 2 |
| TST-07 Auth flow tests | YES — auth_service_test, login_page_test | 2 |
| TST-08 Widget interaction tests | YES — 2,091 testWidgets() calls | 2 |
| TST-09 Provider tests | YES — 28 provider test files | 2 |
| TST-10 Total test methods | 4,911 (2,820 test + 2,091 testWidgets) | 2 |
| TST-11 Navigation tests | YES — router_test, vault_routes_test | 2 |
| TST-12 Service tests | YES — 39 service test files | 2 |
| **Subtotal** | **BLOCKED by TST-05** | **0/24** |

**Note:** TST-05 is BLOCKING. Test coverage percentage was not measured because `flutter test --coverage` requires a full Flutter SDK build environment. The test infrastructure is comprehensive with 405 test files and 4,911 test methods mirroring the source structure.

---

## Infrastructure

| Check | Result | Score |
|---|---|---|
| INF-01 N/A (no Dockerfile) | Desktop app | 2 |
| INF-02 N/A (no DB ports) | Desktop app | 2 |
| INF-03 Env vars for prod | FAIL — hardcoded localhost URLs | 0 |
| INF-04 Health check | PARTIAL — server health via login, no local health | 1 |
| INF-05 Structured logging | YES — LogService with levels, tags, file rotation | 2 |
| INF-06 CI/CD config | FAIL — no pipeline detected | 0 |
| **Subtotal** | | **7/12** |

---

## Security Vulnerabilities — Snyk

| Check | Result | Score |
|---|---|---|
| SNYK-01 Zero critical dep vulns | **SKIPPED** — Snyk doesn't support Dart | 0 |
| SNYK-02 Zero high dep vulns | **SKIPPED** | 0 |
| SNYK-03 Medium/low dep vulns | **SKIPPED** | 0 |
| SNYK-04 Zero SAST errors | **SKIPPED** — Snyk Code not enabled | 0 |
| SNYK-05 Zero SAST warnings | **SKIPPED** | 0 |
| **Subtotal** | **SKIPPED — not scorable** | **0/10** |

---

## Scorecard Summary

| Category | Score | Max | % |
|---|---|---|---|
| Security | 18 | 20 | 90% |
| Data Integrity | 15 | 16 | 94% |
| API Quality | 15 | 16 | 94% |
| Code Quality | 0 | 22 | 0% (BLOCKED) |
| Test Quality | 0 | 24 | 0% (BLOCKED) |
| Infrastructure | 7 | 12 | 58% |
| Snyk Vulnerabilities | 0 | 10 | 0% (SKIPPED) |
| **OVERALL** | **55** | **120** | **46%** |

**Grade: D (46%)**

### Blocking Issues

1. **CQ-09/CQ-10 — Documentation coverage below 100%** (53% class / 49.5% method)
   - 786 undocumented classes, 1,774 undocumented methods
   - Many are models/DTOs (template-exempt) and private widget classes
   - Blocks entire Code Quality category (22 points)

2. **TST-05 — Test coverage not measured**
   - `flutter test --coverage` requires full build environment
   - 405 test files with 4,911 test methods exist
   - Blocks entire Test Quality category (24 points)

3. **Snyk — Flutter/Dart not supported**
   - Snyk CLI cannot scan Flutter/Dart dependencies
   - Snyk Code not enabled for organization
   - Blocks entire Snyk category (10 points)

### Categories Below 60%

- **Code Quality (0%)** — BLOCKED by CQ-09/CQ-10. Without blocking, would score 18/22 (82%)
- **Test Quality (0%)** — BLOCKED by TST-05. Without blocking, would score 21/24 (88%)
- **Infrastructure (58%)** — INF-03 (hardcoded URLs) and INF-06 (no CI/CD)
- **Snyk (0%)** — Not supported for Flutter/Dart

### If Blocking Issues Were Resolved

Without blocking penalties, the adjusted scores would be:

| Category | Score | Max | % |
|---|---|---|---|
| Security | 18 | 20 | 90% |
| Data Integrity | 15 | 16 | 94% |
| API Quality | 15 | 16 | 94% |
| Code Quality | 18 | 22 | 82% |
| Test Quality | 21 | 24 | 88% |
| Infrastructure | 7 | 12 | 58% |
| Snyk | N/A | N/A | N/A |
| **Adjusted** | **94** | **110** | **85% (Grade A)** |
