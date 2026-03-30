---
title: "Phase 4: Testing & Integration"
status: pending
priority: P1
effort: 4h
depends_on: [phase-01, phase-02, phase-03]
---

# Phase 4: Testing & Integration

## Context Links

- [Phase 1 - Platform](./phase-01-platform-analytics.md)
- [Phase 2 - Content Enhancement](./phase-02-content-enhancement.md)
- [Phase 3 - Technical SEO](./phase-03-technical-seo.md)
- [Existing test](../../test/widget_test.dart)
- [UseCase base](../../lib/core/domain/usecase/use_case.dart)

## Overview

Comprehensive testing for all three features plus integration verification. Covers unit tests for entities/use cases/repositories, widget tests for new screens, and integration tests for navigation and DI graph.

## Key Insights

- Existing test directory has only `widget_test.dart` (boilerplate default)
- No test infrastructure (mocking, fixtures, helpers) exists yet
- MobX stores need `mobx` test utilities for observable verification
- Dio HTTP calls need mock server or mock Dio adapter
- Sembast local storage can be tested with in-memory database

## Requirements

### Functional
- FR1: Unit tests for all entities (serialization round-trip)
- FR2: Unit tests for all use cases
- FR3: Unit tests for repository implementations (with mocked API/datasource)
- FR4: Widget tests for new screens and key widgets
- FR5: Integration test for DI graph (all registrations resolve without error)
- FR6: Integration test for navigation (all routes accessible)

### Non-Functional
- NFR1: Minimum 70% code coverage for new code
- NFR2: All tests run under 60 seconds
- NFR3: No flaky tests (no real network calls)

## Test Structure

```
test/
  ├── helpers/
  │   ├── test_helpers.dart               # Common test utilities
  │   └── mock_dio_adapter.dart           # Dio mock for API tests
  ├── domain/
  │   ├── entity/
  │   │   ├── content_entity_test.dart
  │   │   └── seo_entity_test.dart
  │   └── usecase/
  │       ├── content_usecase_test.dart
  │       └── seo_usecase_test.dart
  ├── data/
  │   ├── repository/
  │   │   ├── content_repository_test.dart
  │   │   └── seo_repository_test.dart
  │   └── network/
  │       ├── content_api_test.dart
  │       └── seo_api_test.dart
  ├── presentation/
  │   ├── content_enhancement/
  │   │   └── content_enhancement_screen_test.dart
  │   └── technical_seo/
  │       └── technical_seo_screen_test.dart
  └── integration/
      ├── di_graph_test.dart
      └── navigation_test.dart
```

## Related Code Files

### Files to CREATE

| File | Purpose |
|------|---------|
| `test/helpers/test_helpers.dart` | Shared setup, mock factories, fixture data |
| `test/helpers/mock_dio_adapter.dart` | Dio HttpClientAdapter mock for API testing |
| `test/domain/entity/content_entity_test.dart` | ContentRequest, ContentResult serialization |
| `test/domain/entity/seo_entity_test.dart` | All SEO entity serialization tests |
| `test/domain/usecase/content_usecase_test.dart` | 4 content use cases |
| `test/domain/usecase/seo_usecase_test.dart` | 4 SEO use cases |
| `test/data/repository/content_repository_test.dart` | ContentRepositoryImpl with mocked API |
| `test/data/repository/seo_repository_test.dart` | SeoRepositoryImpl with mocked API + datasource |
| `test/data/network/content_api_test.dart` | ContentApi HTTP call verification |
| `test/data/network/seo_api_test.dart` | SeoApi HTTP call verification |
| `test/presentation/content_enhancement/content_enhancement_screen_test.dart` | Widget test |
| `test/presentation/technical_seo/technical_seo_screen_test.dart` | Widget test |
| `test/integration/di_graph_test.dart` | Full DI registration resolves |
| `test/integration/navigation_test.dart` | All routes navigable |

### Files to MODIFY

| File | Changes |
|------|---------|
| `pubspec.yaml` | Add `mockito`, `build_runner` (already present), `http_mock_adapter` to dev_dependencies |
| `test/widget_test.dart` | Update or remove boilerplate default test |

## Implementation Steps

### Step 1: Test Infrastructure (1h)

1. Add dev dependencies to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     mockito: ^5.4.0
     build_runner: ^2.3.3       # already present
     http_mock_adapter: ^0.6.1  # Dio mock adapter
   ```

2. Create `test/helpers/test_helpers.dart`:
   - `createMockContentRequest()` -- factory for test ContentRequest
   - `createMockContentResult()` -- factory for test ContentResult
   - `createMockSeoAuditResult()` -- factory with categories and checks
   - `createMockCrawlerEvents()` -- list of test events
   - Common JSON fixtures as `Map<String, dynamic>` constants

3. Create `test/helpers/mock_dio_adapter.dart`:
   - Setup using `http_mock_adapter`'s `DioAdapter`
   - Helper methods to mock specific endpoint responses
   - Support for simulating errors (timeout, 500, 404)

### Step 2: Entity Tests (0.5h)

1. `test/domain/entity/content_entity_test.dart`:
   - `ContentRequest.toMap()` produces expected JSON
   - `ContentResult.fromMap()` parses valid JSON
   - `ContentResult.fromMap()` handles missing optional fields
   - `ContentOperation` enum values match API path segments

2. `test/domain/entity/seo_entity_test.dart`:
   - `SeoAuditRequest.toMap()` round-trip
   - `SeoAuditResult.fromMap()` with full data
   - `SeoAuditResult.fromMap()` with partial/running status
   - `SeoCategory.fromMap()` with checks list
   - `SeoCheckItem.fromMap()` with all status values
   - `CrawlerEvent.fromMap()` parsing
   - `CheckStatus` and `AuditStatus` enum mapping

### Step 3: Use Case Tests (0.5h)

1. `test/domain/usecase/content_usecase_test.dart`:
   - Mock `ContentRepository` using Mockito
   - Test each of the 4 use cases delegates to repository correctly
   - Test that each use case enforces its specific ContentOperation

2. `test/domain/usecase/seo_usecase_test.dart`:
   - Mock `SeoRepository`
   - Test `RunSeoAuditUseCase` calls `startAudit`
   - Test `GetAuditStatusUseCase` calls `getAuditResult`
   - Test `GetAuditHistoryUseCase` calls `getAuditHistory`
   - Test `GetCrawlerEventsUseCase` calls `getCrawlerEvents`

### Step 4: Repository & API Tests (1h)

1. `test/data/network/content_api_test.dart`:
   - Mock Dio adapter for POST /api/v1/content/{operation}
   - Verify request body format
   - Verify response parsing
   - Test timeout handling
   - Test error response handling

2. `test/data/network/seo_api_test.dart`:
   - Mock POST /api/v1/seo/audit -> returns audit ID
   - Mock GET /api/v1/seo/audit/{id} -> returns result
   - Mock GET /api/v1/seo/crawler -> returns events
   - Test error scenarios

3. `test/data/repository/content_repository_test.dart`:
   - Mock ContentApi
   - Verify `processContent` delegates correctly

4. `test/data/repository/seo_repository_test.dart`:
   - Mock SeoApi + SeoAuditDataSource
   - Verify `startAudit` calls API
   - Verify `getAuditResult` saves completed results to local storage
   - Verify `getAuditHistory` reads from local datasource
   - Verify max 10 history limit

### Step 5: Widget Tests (0.5h)

1. `test/presentation/content_enhancement/content_enhancement_screen_test.dart`:
   - Screen renders with operation selector and input field
   - Operation selection changes UI state
   - Process button disabled when input empty
   - Loading indicator shown during processing (mock store)
   - Result widget appears after processing

2. `test/presentation/technical_seo/technical_seo_screen_test.dart`:
   - Screen renders with URL input field
   - Audit button disabled when URL empty
   - URL validation shows error for invalid URLs
   - Score card renders with correct color coding
   - Tab navigation works (Overview, Schema, Speed, Crawlers)

### Step 6: Integration Tests (0.5h)

1. `test/integration/di_graph_test.dart`:
   - Call `ServiceLocator.configureDependencies()` in test
   - Verify all new registrations resolve: `getIt<ContentRepository>()`, `getIt<SeoRepository>()`, etc.
   - Verify named registrations (AI DioClient) resolve
   - No circular dependency errors

2. `test/integration/navigation_test.dart`:
   - All routes in `Routes.routes` map can be built
   - Navigation from home to content enhancement works
   - Navigation from home to technical SEO works
   - Back navigation returns to home

## Todo List

- [ ] Add mockito + http_mock_adapter to dev_dependencies
- [ ] Create test_helpers.dart with mock factories
- [ ] Create mock_dio_adapter.dart
- [ ] Write content entity serialization tests
- [ ] Write SEO entity serialization tests
- [ ] Write content use case tests
- [ ] Write SEO use case tests
- [ ] Write ContentApi tests with mocked Dio
- [ ] Write SeoApi tests with mocked Dio
- [ ] Write ContentRepositoryImpl tests
- [ ] Write SeoRepositoryImpl tests
- [ ] Write ContentEnhancementScreen widget test
- [ ] Write TechnicalSeoScreen widget test
- [ ] Write DI graph integration test
- [ ] Write navigation integration test
- [ ] Run `flutter test` -- all pass
- [ ] Run `flutter analyze` -- no errors
- [ ] Verify test coverage >= 70% for new code

## Success Criteria

- `flutter test` passes with 0 failures
- `flutter analyze` shows no errors
- All entity serialization round-trips verified
- All use cases verified with mocked repositories
- API calls verified with mocked Dio
- Widget rendering verified for both new screens
- DI graph fully resolves without errors
- Navigation between all screens works

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| MobX store testing complexity | Incomplete coverage | Use `mobx`'s reaction/when for observable testing |
| Widget tests brittle with localization | Test failures | Use fixed locale in test setup |
| DI test needs real SharedPreferences | Test setup fails | Use shared_preferences mock from Flutter test |
| Sembast in-memory testing | Different behavior | Use Sembast memory factory for tests |

## Security Considerations

- Test fixtures must NOT contain real API keys or credentials
- Mock responses should use sanitized data
- No real network calls in any test (all mocked)

## Next Steps

- Set up code coverage reporting in CI
- Add screenshot/golden tests for visual regression
- Add performance/benchmark tests for large audit results
- Add E2E tests with Flutter integration_test driver
