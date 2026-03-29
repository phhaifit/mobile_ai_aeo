---
title: "Phase 3: Technical SEO"
status: pending
priority: P3
effort: 8h
issue: "#14"
depends_on: phase-01
---

# Phase 3: Technical & Foundational SEO (Feature 12)

## Context Links

- [Issue #14](../../issues/14)
- [Phase 1 - Platform Foundation](./phase-01-platform-analytics.md) (dependency)
- [Clean Architecture pattern](../../CLAUDE.md)
- [Repository pattern](../../lib/data/repository/post/post_repository_impl.dart)

## Overview

Technical SEO auditing and optimization tools: website health audit, schema markup analysis, mobile/speed performance checks, and real-time crawler monitoring. The app calls a backend SEO analysis API and presents structured results with actionable recommendations.

## Key Insights

- SEO audit is a long-running async operation -- backend likely returns a job ID, then poll for results
- Results are structured and hierarchical: overall score -> categories -> individual checks -> recommendations
- Schema markup analysis returns structured JSON-LD/microdata findings
- Crawler monitoring is event-driven -- could use polling or WebSocket (start with polling for KISS)
- Mobile/speed checks likely wrap Lighthouse-like analysis on the backend

## Requirements

### Functional
- FR1: User inputs a website URL to audit
- FR2: System runs full technical SEO audit (async, shows progress)
- FR3: Audit results show overall score + category breakdown (mobile, speed, schema, crawlability)
- FR4: Each category shows individual checks with pass/fail/warning status
- FR5: Failed checks include actionable recommendations
- FR6: Schema markup section shows detected schemas and optimization suggestions
- FR7: Mobile/speed section shows key metrics (FCP, LCP, CLS, etc.)
- FR8: Crawler monitoring shows recent bot visits and crawl status
- FR9: User can re-run audit or audit a different URL
- FR10: Audit history stored locally for comparison

### Non-Functional
- NFR1: Audit polling interval: 5 seconds
- NFR2: Audit timeout: 5 minutes max
- NFR3: Store last 10 audit results locally (Sembast)
- NFR4: URL validation before submission

## Architecture

```
presentation/technical_seo/
  ├── technical_seo_screen.dart           # Main screen with URL input + tabs
  ├── widgets/
  │   ├── seo_score_card_widget.dart      # Overall score circle/card
  │   ├── audit_category_widget.dart      # Category section (expandable)
  │   ├── audit_check_item_widget.dart    # Individual check row
  │   ├── schema_markup_widget.dart       # Schema analysis display
  │   ├── speed_metrics_widget.dart       # Speed/mobile metrics
  │   └── crawler_activity_widget.dart    # Crawler monitoring list
  └── store/
      └── technical_seo_store.dart        # MobX store

domain/
  ├── entity/seo/
  │   ├── seo_audit_request.dart
  │   ├── seo_audit_result.dart           # Full audit result with categories
  │   ├── seo_category.dart              # Category (mobile, speed, schema, crawl)
  │   ├── seo_check_item.dart            # Individual check with status
  │   └── crawler_event.dart             # Crawler visit record
  ├── repository/seo/
  │   └── seo_repository.dart
  └── usecase/seo/
      ├── run_seo_audit_usecase.dart
      ├── get_audit_status_usecase.dart
      ├── get_audit_history_usecase.dart
      └── get_crawler_events_usecase.dart

data/
  ├── network/apis/seo/
  │   └── seo_api.dart
  ├── local/datasources/seo/
  │   └── seo_audit_datasource.dart      # Sembast for audit history
  └── repository/seo/
      └── seo_repository_impl.dart
```

**API Contract (expected)**:
```
POST   /api/v1/seo/audit          -> { "audit_id": "abc123" }
GET    /api/v1/seo/audit/{id}     -> { "status": "running|completed|failed", "result": {...} }
GET    /api/v1/seo/crawler/{url}  -> { "events": [...] }
```

## Related Code Files

### Files to CREATE

| File | Purpose |
|------|---------|
| `lib/domain/entity/seo/seo_audit_request.dart` | Request: URL + options |
| `lib/domain/entity/seo/seo_audit_result.dart` | Full audit result container |
| `lib/domain/entity/seo/seo_category.dart` | Category with score + checks |
| `lib/domain/entity/seo/seo_check_item.dart` | Individual check: status + recommendation |
| `lib/domain/entity/seo/crawler_event.dart` | Crawler visit: bot, time, path, status |
| `lib/domain/repository/seo/seo_repository.dart` | Abstract interface |
| `lib/domain/usecase/seo/run_seo_audit_usecase.dart` | Start audit, return audit ID |
| `lib/domain/usecase/seo/get_audit_status_usecase.dart` | Poll audit status/result |
| `lib/domain/usecase/seo/get_audit_history_usecase.dart` | Get local audit history |
| `lib/domain/usecase/seo/get_crawler_events_usecase.dart` | Fetch crawler activity |
| `lib/data/network/apis/seo/seo_api.dart` | HTTP calls to SEO API |
| `lib/data/local/datasources/seo/seo_audit_datasource.dart` | Sembast local storage for history |
| `lib/data/local/constants/db_constants.dart` | Add SEO store name (modify) |
| `lib/data/repository/seo/seo_repository_impl.dart` | Repository implementation |
| `lib/presentation/technical_seo/technical_seo_screen.dart` | Main screen |
| `lib/presentation/technical_seo/widgets/seo_score_card_widget.dart` | Score display |
| `lib/presentation/technical_seo/widgets/audit_category_widget.dart` | Category section |
| `lib/presentation/technical_seo/widgets/audit_check_item_widget.dart` | Check row |
| `lib/presentation/technical_seo/widgets/schema_markup_widget.dart` | Schema display |
| `lib/presentation/technical_seo/widgets/speed_metrics_widget.dart` | Speed metrics |
| `lib/presentation/technical_seo/widgets/crawler_activity_widget.dart` | Crawler list |
| `lib/presentation/technical_seo/store/technical_seo_store.dart` | MobX store |

### Files to MODIFY

| File | Changes |
|------|---------|
| `lib/data/network/constants/endpoints.dart` | Add SEO API endpoints |
| `lib/data/di/module/local_module.dart` | Register SeoAuditDataSource |
| `lib/data/di/module/network_module.dart` | Register SeoApi |
| `lib/data/di/module/repository_module.dart` | Register SeoRepository |
| `lib/domain/di/module/usecase_module.dart` | Register 4 SEO use cases |
| `lib/presentation/di/module/store_module.dart` | Register TechnicalSeoStore |
| `lib/utils/routes/routes.dart` | Add `/technical-seo` route |
| `lib/presentation/home/home.dart` | Add navigation to SEO screen |

## Implementation Steps

### Step 1: Domain Layer -- Entities (1.5h)

1. Create `lib/domain/entity/seo/seo_audit_request.dart`:
   - Fields: `String url`, `bool includeSchema`, `bool includeMobile`, `bool includeSpeed`, `bool includeCrawler`
   - `toMap()` serialization

2. Create `lib/domain/entity/seo/seo_check_item.dart`:
   - Fields: `String name`, `String description`, `CheckStatus status` (pass/fail/warning), `String? recommendation`, `double? score`
   - `factory fromMap()`
   - `enum CheckStatus { pass, fail, warning }`

3. Create `lib/domain/entity/seo/seo_category.dart`:
   - Fields: `String name`, `double score`, `List<SeoCheckItem> checks`
   - `factory fromMap()`
   - Computed: `int get passCount`, `int get failCount`

4. Create `lib/domain/entity/seo/seo_audit_result.dart`:
   - Fields: `String auditId`, `String url`, `double overallScore`, `AuditStatus status` (running/completed/failed), `List<SeoCategory> categories`, `DateTime createdAt`
   - `factory fromMap()`, `toMap()`
   - `enum AuditStatus { running, completed, failed }`

5. Create `lib/domain/entity/seo/crawler_event.dart`:
   - Fields: `String botName`, `String path`, `int statusCode`, `DateTime timestamp`
   - `factory fromMap()`

### Step 2: Domain Layer -- Repository & Use Cases (1h)

1. Create `lib/domain/repository/seo/seo_repository.dart`:
   ```dart
   abstract class SeoRepository {
     Future<String> startAudit(SeoAuditRequest request);        // returns auditId
     Future<SeoAuditResult> getAuditResult(String auditId);     // poll result
     Future<List<SeoAuditResult>> getAuditHistory();            // local history
     Future<List<CrawlerEvent>> getCrawlerEvents(String url);   // crawler data
   }
   ```

2. Create 4 use cases each extending `UseCase`:
   - `RunSeoAuditUseCase` -- calls `startAudit`, returns audit ID
   - `GetAuditStatusUseCase` -- calls `getAuditResult`, returns result (may be partial)
   - `GetAuditHistoryUseCase` -- calls `getAuditHistory`, returns local list
   - `GetCrawlerEventsUseCase` -- calls `getCrawlerEvents`

### Step 3: Data Layer -- API, Local Storage, Repository (2h)

1. Update `lib/data/network/constants/endpoints.dart`:
   - `static const String seoAudit = "/api/v1/seo/audit"`
   - `static String seoAuditResult(String id) => "/api/v1/seo/audit/$id"`
   - `static String seoCrawler(String url) => "/api/v1/seo/crawler?url=$url"`

2. Create `lib/data/network/apis/seo/seo_api.dart`:
   - Constructor takes `DioClient`
   - `Future<String> startAudit(SeoAuditRequest request)` -- POST, return audit_id
   - `Future<SeoAuditResult> getAuditResult(String auditId)` -- GET
   - `Future<List<CrawlerEvent>> getCrawlerEvents(String url)` -- GET

3. Create `lib/data/local/datasources/seo/seo_audit_datasource.dart`:
   - Extends Sembast pattern from `PostDataSource`
   - Store name: `seo_audits`
   - `insert(SeoAuditResult)`, `getAll()`, `deleteOldest()` (keep max 10)

4. Create `lib/data/repository/seo/seo_repository_impl.dart`:
   - `startAudit`: calls SeoApi, returns ID
   - `getAuditResult`: calls SeoApi; if completed, saves to local datasource
   - `getAuditHistory`: reads from local datasource
   - `getCrawlerEvents`: calls SeoApi

5. Register in DI modules (network, local, repository)

### Step 4: Domain DI (0.5h)

1. Update `lib/domain/di/module/usecase_module.dart` with 4 SEO use cases

### Step 5: Presentation Layer -- Store (1.5h)

1. Create `lib/presentation/technical_seo/store/technical_seo_store.dart`:
   - Observable fields:
     - `String inputUrl`
     - `SeoAuditResult? currentAudit`
     - `ObservableList<SeoAuditResult> auditHistory`
     - `ObservableList<CrawlerEvent> crawlerEvents`
     - `AuditStatus? auditStatus`
     - `bool isPolling`
   - Computed: `bool get loading`, `bool get auditComplete`
   - Actions:
     - `setUrl(String url)` with validation
     - `startAudit()` -- calls RunSeoAuditUseCase, then starts polling
     - `pollAuditResult(String auditId)` -- timer-based polling every 5s, stops on complete/fail/timeout
     - `loadHistory()`
     - `loadCrawlerEvents()`
   - Dispose polling timer on cleanup

2. Register in `lib/presentation/di/module/store_module.dart`
3. Run `build_runner build`

### Step 6: Presentation Layer -- UI (1.5h)

1. Create widget files (each under 200 lines):
   - `seo_score_card_widget.dart` -- circular score indicator (0-100) with color coding
   - `audit_category_widget.dart` -- expandable card with category name, score, check list
   - `audit_check_item_widget.dart` -- row: icon (pass/fail/warn) + name + recommendation
   - `schema_markup_widget.dart` -- detected schemas list with optimization tips
   - `speed_metrics_widget.dart` -- metric cards (FCP, LCP, CLS, TBT) with ratings
   - `crawler_activity_widget.dart` -- list of recent crawler visits with bot name, path, time

2. Create `technical_seo_screen.dart`:
   - URL input field with validation + "Audit" button
   - TabBarView: Overview | Schema | Speed | Crawlers
   - Overview tab: SeoScoreCard + list of AuditCategoryWidgets
   - Schema tab: SchemaMarkupWidget
   - Speed tab: SpeedMetricsWidget
   - Crawlers tab: CrawlerActivityWidget
   - Audit history drawer/bottom sheet
   - Loading state: progress indicator with status text during polling

3. Update routes and home screen navigation

## Todo List

- [ ] Create SeoAuditRequest entity
- [ ] Create SeoCheckItem entity with CheckStatus enum
- [ ] Create SeoCategory entity
- [ ] Create SeoAuditResult entity with AuditStatus enum
- [ ] Create CrawlerEvent entity
- [ ] Create SeoRepository abstract interface
- [ ] Create RunSeoAuditUseCase
- [ ] Create GetAuditStatusUseCase
- [ ] Create GetAuditHistoryUseCase
- [ ] Create GetCrawlerEventsUseCase
- [ ] Add SEO endpoints to endpoints.dart
- [ ] Create SeoApi
- [ ] Create SeoAuditDataSource (Sembast)
- [ ] Create SeoRepositoryImpl
- [ ] Register all SEO components in DI modules
- [ ] Create TechnicalSeoStore (MobX) with polling logic
- [ ] Run `build_runner build` for .g.dart generation
- [ ] Create SeoScoreCardWidget
- [ ] Create AuditCategoryWidget
- [ ] Create AuditCheckItemWidget
- [ ] Create SchemaMarkupWidget
- [ ] Create SpeedMetricsWidget
- [ ] Create CrawlerActivityWidget
- [ ] Create TechnicalSeoScreen with tabs
- [ ] Add route and home navigation
- [ ] Run `flutter analyze` -- verify no errors

## Success Criteria

- User can input URL and trigger audit
- Polling correctly tracks audit progress
- Results display with scores, categories, and individual checks
- Schema, speed, and crawler tabs show relevant data
- Audit history persists locally across sessions (max 10)
- URL validation prevents invalid submissions
- `flutter analyze` passes

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Backend audit takes >5 min | UX frustration | 5-min timeout with cancel option, partial results display |
| Polling overhead on battery | Battery drain | 5s interval, stop polling when app backgrounded |
| Complex audit result parsing | Runtime errors | Defensive fromMap with null safety, fallback defaults |
| WebSocket needed for crawler | Extra complexity | Start with polling; WebSocket is a future enhancement |

## Security Considerations

- URL input must be validated and sanitized (no XSS via URL display)
- Audit results may contain sensitive site information -- no sharing without user consent
- Crawler events may reveal site structure -- auth required for API access
- Local audit history encrypted via existing Sembast XXTEA encryption

## Next Steps

- WebSocket for real-time crawler monitoring (replace polling)
- PDF export of audit reports
- Scheduled recurring audits with diff comparison
- Integration with Google Search Console API
