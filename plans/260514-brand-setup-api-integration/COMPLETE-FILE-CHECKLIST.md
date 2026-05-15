# Complete File Checklist - Phase 2: Brand Setup & Configuration API Integration

## Summary

**Total Files to Create:** 120+  
**Total Files to Modify:** 5+  
**Total Effort:** 40 hours  
**Target Coverage:** 80%+

---

## PHASE 1: Research & Analysis (Already Complete ✓)

- [x] API endpoint research and documentation
- [x] Request/response schema definition
- [x] Current implementation pattern analysis
- [x] Error handling strategy

**Deliverable:** `phase-01-research-and-analysis.md`

---

## PHASE 2: Network Layer (API Integration Setup)

### 2.1 Endpoint Constants

**File:** `lib/data/network/constants/endpoints.dart` (UPDATE)

- Add 30+ endpoint constants for:
  - Brand management (5 endpoints)
  - Knowledge base (6 endpoints)
  - Links (5 endpoints)
  - Rewrite rules (3 endpoints)
  - LLM config (5 endpoints)
  - Brand positioning (3 endpoints)
  - Project management (6 endpoints)

### 2.2 Data Transfer Objects (DTOs) - 8 files

| File Path                                               | Type | Purpose                   |
| ------------------------------------------------------- | ---- | ------------------------- |
| `lib/data/network/models/brand_dto.dart`                | NEW  | Brand API response model  |
| `lib/data/network/models/knowledge_base_entry_dto.dart` | NEW  | KB entry API response     |
| `lib/data/network/models/link_dto.dart`                 | NEW  | Link API response         |
| `lib/data/network/models/rewrite_rule_dto.dart`         | NEW  | Rewrite rule API response |
| `lib/data/network/models/llm_config_dto.dart`           | NEW  | LLM config main model     |
| `lib/data/network/models/llm_detail_dto.dart`           | NEW  | LLM detail nested model   |
| `lib/data/network/models/brand_positioning_dto.dart`    | NEW  | Brand positioning model   |
| `lib/data/network/models/project_dto.dart`              | NEW  | Project API response      |

**Requirements:**

- All must have `@JsonSerializable()` annotation
- All must implement `fromJson()` and `toJson()` methods
- Use proper `@JsonKey()` annotations for camelCase ↔ snake_case mapping
- Support nested objects for composed models

### 2.3 API Classes - 7 files

| File Path                                                            | Class Name          | Methods                                                                              |
| -------------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------ |
| `lib/data/network/apis/brand/brand_api.dart`                         | BrandApi            | getBrand, listBrands, createBrand, updateBrand, deleteBrand                          |
| `lib/data/network/apis/knowledge_base/knowledge_base_api.dart`       | KnowledgeBaseApi    | listEntries, getEntry, createEntry, updateEntry, deleteEntry, bulkDeleteEntries      |
| `lib/data/network/apis/link/link_api.dart`                           | LinkApi             | listLinks, createLink, updateLink, deleteLink, toggleMonitor                         |
| `lib/data/network/apis/rewrite_rule/rewrite_rule_api.dart`           | RewriteRuleApi      | listRules, createRule, updateRule, deleteRule                                        |
| `lib/data/network/apis/llm_config/llm_config_api.dart`               | LlmConfigApi        | getConfig, updateConfig, enableLlm, disableLlm, updateFrequency                      |
| `lib/data/network/apis/brand_positioning/brand_positioning_api.dart` | BrandPositioningApi | getPositioning, updatePositioning, getAnalytics                                      |
| `lib/data/network/apis/project/project_api.dart`                     | ProjectApi          | listProjects, getProject, createProject, updateProject, deleteProject, switchProject |

**Requirements:**

- Inject DioClient in constructor
- All methods async, return DTOs
- Use Endpoints constants for paths
- Consistent error handling (let DioClient handle)

### 2.4 DI Updates

**File:** `lib/data/di/module/network_module.dart` (UPDATE)

Add registrations:

```dart
getIt.registerSingleton(BrandApi(getIt<DioClient>()));
getIt.registerSingleton(KnowledgeBaseApi(getIt<DioClient>()));
getIt.registerSingleton(LinkApi(getIt<DioClient>()));
getIt.registerSingleton(RewriteRuleApi(getIt<DioClient>()));
getIt.registerSingleton(LlmConfigApi(getIt<DioClient>()));
getIt.registerSingleton(BrandPositioningApi(getIt<DioClient>()));
getIt.registerSingleton(ProjectApi(getIt<DioClient>()));
```

---

## PHASE 3: Domain Layer (Entities, Repositories, Use Cases)

### 3.1 Domain Entities - 7 files

| File Path                                                    | Entity Class         | Key Fields                                               |
| ------------------------------------------------------------ | -------------------- | -------------------------------------------------------- |
| `lib/domain/entity/brand/brand.dart`                         | Brand                | id, name, tagline, industry, website, logoUrl, verified  |
| `lib/domain/entity/knowledge_base/knowledge_base_entry.dart` | KnowledgeBaseEntry   | id, title, type, content, status, freshness, sourceCount |
| `lib/domain/entity/link/link.dart`                           | Link                 | id, url, label, type, monitored, status, priority        |
| `lib/domain/entity/rewrite_rule/rewrite_rule.dart`           | RewriteRule          | id, pattern, target, enabled, priority, testUrl          |
| `lib/domain/entity/llm_config/llm_config.dart`               | LlmConfig, LlmDetail | brandId, llmConfigs[], globalPollingEnabled              |
| `lib/domain/entity/brand_positioning/brand_positioning.dart` | BrandPositioning     | id, brandId, keyMessages, targetAudience, score          |
| `lib/domain/entity/project/project.dart`                     | Project              | id, name, brandId, owner, stage, completionPercentage    |

**Requirements:**

- Immutable with final fields
- All have `copyWith()` method
- All have `fromDto()` static factory
- All have `@override toString()`

### 3.2 Repository Interfaces - 7 files

| File Path                                                                   | Abstract Class             | Methods                                                     |
| --------------------------------------------------------------------------- | -------------------------- | ----------------------------------------------------------- |
| `lib/domain/repository/brand/brand_repository.dart`                         | BrandRepository            | getBrand, listBrands, createBrand, updateBrand, deleteBrand |
| `lib/domain/repository/knowledge_base/knowledge_base_repository.dart`       | KnowledgeBaseRepository    | (7 methods)                                                 |
| `lib/domain/repository/link/link_repository.dart`                           | LinkRepository             | (5 methods)                                                 |
| `lib/domain/repository/rewrite_rule/rewrite_rule_repository.dart`           | RewriteRuleRepository      | (4 methods)                                                 |
| `lib/domain/repository/llm_config/llm_config_repository.dart`               | LlmConfigRepository        | (5 methods)                                                 |
| `lib/domain/repository/brand_positioning/brand_positioning_repository.dart` | BrandPositioningRepository | (3 methods)                                                 |
| `lib/domain/repository/project/project_repository.dart`                     | ProjectRepository          | (6 methods)                                                 |

**Requirements:**

- Abstract classes with Future return types
- Return domain entities (not DTOs)
- Mirror API signatures

### 3.3 Repository Implementations - 7 files

| File Path                                                                      | Implementation Class           |
| ------------------------------------------------------------------------------ | ------------------------------ |
| `lib/data/repository/brand/brand_repository_impl.dart`                         | BrandRepositoryImpl            |
| `lib/data/repository/knowledge_base/knowledge_base_repository_impl.dart`       | KnowledgeBaseRepositoryImpl    |
| `lib/data/repository/link/link_repository_impl.dart`                           | LinkRepositoryImpl             |
| `lib/data/repository/rewrite_rule/rewrite_rule_repository_impl.dart`           | RewriteRuleRepositoryImpl      |
| `lib/data/repository/llm_config/llm_config_repository_impl.dart`               | LlmConfigRepositoryImpl        |
| `lib/data/repository/brand_positioning/brand_positioning_repository_impl.dart` | BrandPositioningRepositoryImpl |
| `lib/data/repository/project/project_repository_impl.dart`                     | ProjectRepositoryImpl          |

**Requirements:**

- Inject API class in constructor
- Call API method, convert DTO → Entity
- Delegate error handling to API layer

### 3.4 Use Cases - 25+ files

| Feature           | Use Case Count | Files to Create                                                                            |
| ----------------- | -------------- | ------------------------------------------------------------------------------------------ |
| Brand             | 5              | get_brand, list_brands, create_brand, update_brand, delete_brand                           |
| Knowledge Base    | 6              | get_entry, list_entries, create_entry, update_entry, delete_entry, bulk_delete_entries     |
| Links             | 5              | list_links, create_link, update_link, delete_link, toggle_link_monitor                     |
| Rewrite Rules     | 4              | list_rules, create_rule, update_rule, delete_rule                                          |
| LLM Config        | 5              | get_config, update_config, enable_llm, disable_llm, update_frequency                       |
| Brand Positioning | 3              | get_positioning, update_positioning, get_analytics                                         |
| Projects          | 6              | get_project, list_projects, create_project, update_project, delete_project, switch_project |

**File Pattern:** `lib/domain/usecase/{feature}/{use_case}_usecase.dart`

**Requirements:**

- Extend `UseCase<T, P>` base class
- Inject repository in constructor
- Define `{UseCaseName}Params` class
- Implement `call(Params)` method

### 3.5 DI Updates - 2 Files

**File:** `lib/data/di/module/repository_module.dart` (UPDATE)

Add 7 repository registrations

**File:** `lib/domain/di/module/use_case_module.dart` (UPDATE)

Add 25+ use case registrations

---

## PHASE 4: Presentation Layer (State Management & UI)

### 4.1 MobX Stores - 7 files

| File Path                                                         | Store Class           | Observable Properties                            |
| ----------------------------------------------------------------- | --------------------- | ------------------------------------------------ |
| `lib/presentation/brand_setup/store/brand_store.dart`             | BrandStore            | currentBrand, brands[], isLoading, isSuccess     |
| `lib/presentation/brand_setup/store/knowledge_base_store.dart`    | KnowledgeBaseStore    | entries[], selectedEntry, isLoading, isSuccess   |
| `lib/presentation/brand_setup/store/link_store.dart`              | LinkStore             | links[], isLoading, isSuccess                    |
| `lib/presentation/brand_setup/store/rewrite_rule_store.dart`      | RewriteRuleStore      | rules[], isLoading, isSuccess                    |
| `lib/presentation/brand_setup/store/llm_config_store.dart`        | LlmConfigStore        | config, isLoading, isSuccess                     |
| `lib/presentation/brand_setup/store/brand_positioning_store.dart` | BrandPositioningStore | positioning, isLoading, isSuccess                |
| `lib/presentation/brand_setup/store/project_store.dart`           | ProjectStore          | projects[], currentProject, isLoading, isSuccess |

**Requirements:**

- Extend `@observable` for state
- `@action` methods for mutations
- `@computed` for derived values
- Inject use cases in constructor
- Proper error handling via errorStore
- Manage loading state

### 4.2 Updated Main Store

**File:** `lib/presentation/brand_setup/store/brand_setup_store.dart` (UPDATE)

Compose all 7 sub-stores:

- Aggregate `isLoading` from all stores
- Add tab selection state
- Route events between stores

### 4.3 UI Screens - 10+ files

| File Path                                                               | Screen Class              | Purpose                  |
| ----------------------------------------------------------------------- | ------------------------- | ------------------------ |
| `lib/presentation/brand_setup/screen/brand_setup_screen.dart`           | BrandSetupScreen          | Main tab-based container |
| `lib/presentation/brand_setup/screen/brand_detail_screen.dart`          | BrandDetailScreen         | Create/edit brand        |
| `lib/presentation/brand_setup/screen/knowledge_base_list_screen.dart`   | KnowledgeBaseListScreen   | KB entry list            |
| `lib/presentation/brand_setup/screen/knowledge_base_detail_screen.dart` | KnowledgeBaseDetailScreen | Create/edit KB entry     |
| `lib/presentation/brand_setup/screen/link_list_screen.dart`             | LinkListScreen            | Link list                |
| `lib/presentation/brand_setup/screen/link_detail_screen.dart`           | LinkDetailScreen          | Create/edit link         |
| `lib/presentation/brand_setup/screen/rewrite_rule_list_screen.dart`     | RewriteRuleListScreen     | Rewrite rule list        |
| `lib/presentation/brand_setup/screen/rewrite_rule_detail_screen.dart`   | RewriteRuleDetailScreen   | Create/edit rule         |
| `lib/presentation/brand_setup/screen/llm_config_screen.dart`            | LlmConfigScreen           | LLM configuration        |
| `lib/presentation/brand_setup/screen/brand_positioning_screen.dart`     | BrandPositioningScreen    | Brand positioning setup  |
| `lib/presentation/brand_setup/screen/project_list_screen.dart`          | ProjectListScreen         | Project list             |
| `lib/presentation/brand_setup/screen/project_detail_screen.dart`        | ProjectDetailScreen       | Create/edit project      |

**Requirements:**

- Use `Observer` for reactive UI
- Form fields with controllers
- CRUD buttons (Create, Read, Update, Delete)
- Error/success feedback
- Loading indicators

### 4.4 Routes

**File:** `lib/utils/routes/routes.dart` (UPDATE)

Add routes for 10+ screens

### 4.5 DI Updates

**File:** `lib/presentation/di/module/store_module.dart` (UPDATE)

Register all 7 stores + main orchestrator store

---

## PHASE 5: Testing & Validation

### 5.1 Test Fixtures - 7 files

| File Path                                       | Purpose            |
| ----------------------------------------------- | ------------------ |
| `test/fixtures/brand_fixtures.dart`             | Mock brands data   |
| `test/fixtures/knowledge_base_fixtures.dart`    | Mock KB entries    |
| `test/fixtures/link_fixtures.dart`              | Mock links         |
| `test/fixtures/rewrite_rule_fixtures.dart`      | Mock rewrite rules |
| `test/fixtures/llm_config_fixtures.dart`        | Mock LLM configs   |
| `test/fixtures/brand_positioning_fixtures.dart` | Mock positioning   |
| `test/fixtures/project_fixtures.dart`           | Mock projects      |

### 5.2 API Tests - 7 files

```
test/data/network/apis/brand/brand_api_test.dart
test/data/network/apis/knowledge_base/knowledge_base_api_test.dart
test/data/network/apis/link/link_api_test.dart
test/data/network/apis/rewrite_rule/rewrite_rule_api_test.dart
test/data/network/apis/llm_config/llm_config_api_test.dart
test/data/network/apis/brand_positioning/brand_positioning_api_test.dart
test/data/network/apis/project/project_api_test.dart
```

**Test Count:** 35+ (5 tests per API class)

### 5.3 Repository Tests - 7 files

```
test/data/repository/brand/brand_repository_test.dart
test/data/repository/knowledge_base/knowledge_base_repository_test.dart
test/data/repository/link/link_repository_test.dart
test/data/repository/rewrite_rule/rewrite_rule_repository_test.dart
test/data/repository/llm_config/llm_config_repository_test.dart
test/data/repository/brand_positioning/brand_positioning_repository_test.dart
test/data/repository/project/project_repository_test.dart
```

**Test Count:** 35+ (5 tests per repository)

### 5.4 Use Case Tests - 25+ files

```
test/domain/usecase/brand/*.dart (5 files)
test/domain/usecase/knowledge_base/*.dart (6 files)
test/domain/usecase/link/*.dart (5 files)
test/domain/usecase/rewrite_rule/*.dart (4 files)
test/domain/usecase/llm_config/*.dart (5 files)
test/domain/usecase/brand_positioning/*.dart (3 files)
test/domain/usecase/project/*.dart (6 files)
```

**Test Count:** 50+ (2 tests per use case)

### 5.5 Store Tests - 7 files

```
test/presentation/brand_setup/store/brand_store_test.dart
test/presentation/brand_setup/store/knowledge_base_store_test.dart
test/presentation/brand_setup/store/link_store_test.dart
test/presentation/brand_setup/store/rewrite_rule_store_test.dart
test/presentation/brand_setup/store/llm_config_store_test.dart
test/presentation/brand_setup/store/brand_positioning_store_test.dart
test/presentation/brand_setup/store/project_store_test.dart
```

**Test Count:** 35+ (5 tests per store)

### 5.6 Widget Tests - 10+ files

```
test/presentation/brand_setup/screen/brand_setup_screen_test.dart
test/presentation/brand_setup/screen/brand_detail_screen_test.dart
test/presentation/brand_setup/screen/knowledge_base_list_screen_test.dart
test/presentation/brand_setup/screen/knowledge_base_detail_screen_test.dart
test/presentation/brand_setup/screen/link_list_screen_test.dart
test/presentation/brand_setup/screen/link_detail_screen_test.dart
test/presentation/brand_setup/screen/rewrite_rule_list_screen_test.dart
test/presentation/brand_setup/screen/rewrite_rule_detail_screen_test.dart
test/presentation/brand_setup/screen/llm_config_screen_test.dart
test/presentation/brand_setup/screen/brand_positioning_screen_test.dart
test/presentation/brand_setup/screen/project_list_screen_test.dart
```

**Test Count:** 30+ (3 tests per screen)

### 5.7 Integration Tests - 5+ files

```
test/integration/brand_setup_integration_test.dart
test/integration/knowledge_base_integration_test.dart
test/integration/link_integration_test.dart
test/integration/llm_config_integration_test.dart
test/integration/full_flow_integration_test.dart
```

**Test Count:** 10+

### 5.8 Test Configuration - 2 files

```
test/test_setup.dart
test/helpers/test_helpers.dart
```

---

## SUMMARY BY CATEGORY

### Files to CREATE

| Category                   | Count    | Notes                    |
| -------------------------- | -------- | ------------------------ |
| DTOs                       | 8        | All @JsonSerializable    |
| API Classes                | 7        | Network layer            |
| Domain Entities            | 7        | Business models          |
| Repository Interfaces      | 7        | Abstract contracts       |
| Repository Implementations | 7        | Concrete implementations |
| Use Cases                  | 25+      | Business logic           |
| MobX Stores                | 7        | State management         |
| UI Screens                 | 10+      | User interface           |
| Test Fixtures              | 7        | Mock data                |
| API Tests                  | 7        | Network layer tests      |
| Repository Tests           | 7        | Data layer tests         |
| Use Case Tests             | 25+      | Domain layer tests       |
| Store Tests                | 7        | State tests              |
| Widget Tests               | 10+      | UI tests                 |
| Integration Tests          | 5+       | End-to-end tests         |
| Test Utilities             | 2        | Test helpers             |
| **TOTAL NEW FILES**        | **~120** |                          |

### Files to UPDATE

| File Path                                                     | Changes                        |
| ------------------------------------------------------------- | ------------------------------ |
| `lib/data/network/constants/endpoints.dart`                   | Add 30+ endpoint constants     |
| `lib/data/di/module/network_module.dart`                      | Add 7 API registrations        |
| `lib/data/di/module/repository_module.dart`                   | Add 7 repository registrations |
| `lib/domain/di/module/use_case_module.dart`                   | Add 25+ use case registrations |
| `lib/presentation/di/module/store_module.dart`                | Add 8 store registrations      |
| `lib/presentation/brand_setup/store/brand_setup_store.dart`   | Integrate sub-stores           |
| `lib/presentation/brand_setup/screen/brand_setup_screen.dart` | Add tabs & data binding        |
| `lib/utils/routes/routes.dart`                                | Add 10+ routes                 |
| **TOTAL UPDATES**                                             | **8 files**                    |

---

## IMPLEMENTATION ORDER

1. ✓ Phase 1: Research & Analysis (COMPLETE)
2. → Phase 2: Network Layer (API classes, DTOs, endpoints)
3. → Phase 3: Domain Layer (entities, repositories, use cases)
4. → Phase 4: Presentation Layer (stores, screens, routes)
5. → Phase 5: Testing (fixtures, unit tests, integration tests)

---

## Code Generation Required

After creating files, run:

```bash
# Generate JSON serialization for DTOs
flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate MobX observables
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for errors
flutter analyze

# Run tests
flutter test

# Check coverage
flutter test --coverage
```

---

## Quality Checkpoints

| Checkpoint  | Criteria           | Owner     |
| ----------- | ------------------ | --------- |
| Compilation | 0 errors           | Developer |
| Analysis    | 0 warnings         | Linter    |
| Tests       | 80%+ coverage      | Tester    |
| Code Review | Approved           | Reviewer  |
| Integration | Working end-to-end | QA        |

---

## Success Criteria

✓ All 120+ files created/modified  
✓ Zero compilation errors  
✓ Zero analyzer warnings  
✓ 80%+ test coverage  
✓ All tests passing  
✓ API integration functional  
✓ Code review approved  
✓ Ready for implementation sprint
