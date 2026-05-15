# Phase 1: Research & Analysis

## API Endpoints Research

### 1. Brand Profile Management

**Base Path:** `/api/v1/brands`

| Operation    | Method | Endpoint                  | Purpose                     |
| ------------ | ------ | ------------------------- | --------------------------- |
| Get Brand    | GET    | `/api/v1/brands/:brandId` | Fetch brand profile details |
| Create Brand | POST   | `/api/v1/brands`          | Create new brand profile    |
| Update Brand | PATCH  | `/api/v1/brands/:brandId` | Update brand information    |
| Delete Brand | DELETE | `/api/v1/brands/:brandId` | Delete brand profile        |
| List Brands  | GET    | `/api/v1/brands`          | List all brands for user    |

**Request/Response Schemas:**

```dart
// Create/Update Request
{
  "name": "string (required)",
  "tagline": "string (required)",
  "industry": "string (required)",
  "website": "string (required, URL)",
  "logoUrl": "string (optional, URL)",
  "description": "string (optional)"
}

// Response
{
  "id": "string (UUID)",
  "name": "string",
  "tagline": "string",
  "industry": "string",
  "website": "string",
  "logoUrl": "string",
  "verified": "boolean",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

---

### 2. Knowledge Base Management

**Base Path:** `/api/v1/brands/:brandId/knowledge-base`

| Operation    | Method | Endpoint                                          | Purpose                 |
| ------------ | ------ | ------------------------------------------------- | ----------------------- |
| List Entries | GET    | `/api/v1/brands/:brandId/knowledge-base`          | Get all KB entries      |
| Get Entry    | GET    | `/api/v1/brands/:brandId/knowledge-base/:entryId` | Fetch single KB entry   |
| Create Entry | POST   | `/api/v1/brands/:brandId/knowledge-base`          | Add new KB entry        |
| Update Entry | PATCH  | `/api/v1/brands/:brandId/knowledge-base/:entryId` | Modify KB entry         |
| Delete Entry | DELETE | `/api/v1/brands/:brandId/knowledge-base/:entryId` | Remove KB entry         |
| Bulk Delete  | DELETE | `/api/v1/brands/:brandId/knowledge-base`          | Delete multiple entries |

**Request/Response Schemas:**

```dart
// Create/Update Request
{
  "title": "string (required)",
  "type": "enum: [article, faq, resource, policy] (required)",
  "content": "string (required, min 50 chars)",
  "url": "string (optional, URL)",
  "category": "string (optional)",
  "tags": ["string"] (optional),
  "isPublic": "boolean (default: true)"
}

// Response
{
  "id": "string (UUID)",
  "title": "string",
  "type": "string",
  "content": "string",
  "url": "string",
  "category": "string",
  "tags": ["string"],
  "isPublic": "boolean",
  "status": "enum: [draft, published, archived]",
  "freshness": "enum: [fresh, stale, outdated]",
  "sourceCount": "integer",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

---

### 3. URL & Link Management

**Base Path:** `/api/v1/brands/:brandId/links`

| Operation      | Method | Endpoint                                        | Purpose                   |
| -------------- | ------ | ----------------------------------------------- | ------------------------- |
| List Links     | GET    | `/api/v1/brands/:brandId/links`                 | Get all monitored links   |
| Create Link    | POST   | `/api/v1/brands/:brandId/links`                 | Add new link              |
| Update Link    | PATCH  | `/api/v1/brands/:brandId/links/:linkId`         | Modify link               |
| Delete Link    | DELETE | `/api/v1/brands/:brandId/links/:linkId`         | Remove link               |
| Toggle Monitor | PATCH  | `/api/v1/brands/:brandId/links/:linkId/monitor` | Enable/disable monitoring |

**Rewrite Rules:** `/api/v1/brands/:brandId/rewrite-rules`

| Operation   | Method | Endpoint                                        | Purpose               |
| ----------- | ------ | ----------------------------------------------- | --------------------- |
| List Rules  | GET    | `/api/v1/brands/:brandId/rewrite-rules`         | Get all rewrite rules |
| Create Rule | POST   | `/api/v1/brands/:brandId/rewrite-rules`         | Add new rewrite rule  |
| Update Rule | PATCH  | `/api/v1/brands/:brandId/rewrite-rules/:ruleId` | Modify rule           |
| Delete Rule | DELETE | `/api/v1/brands/:brandId/rewrite-rules/:ruleId` | Remove rule           |

**Request/Response Schemas:**

```dart
// Link Create/Update Request
{
  "url": "string (required, URL)",
  "label": "string (required)",
  "type": "enum: [website, social, directory] (required)",
  "monitored": "boolean (default: true)",
  "priority": "integer (1-5, optional)"
}

// Link Response
{
  "id": "string (UUID)",
  "url": "string",
  "label": "string",
  "type": "string",
  "monitored": "boolean",
  "priority": "integer",
  "lastChecked": "ISO 8601",
  "status": "enum: [active, inactive, broken]",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}

// Rewrite Rule Request
{
  "pattern": "string (required, regex)",
  "target": "string (required, URL or path)",
  "enabled": "boolean (default: true)",
  "priority": "integer (optional)"
}

// Rewrite Rule Response
{
  "id": "string (UUID)",
  "pattern": "string",
  "target": "string",
  "enabled": "boolean",
  "priority": "integer",
  "testUrl": "string (optional, for testing)",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

---

### 4. LLM Configuration & Monitoring

**Base Path:** `/api/v1/brands/:brandId/llm-config`

| Operation        | Method | Endpoint                                              | Purpose                    |
| ---------------- | ------ | ----------------------------------------------------- | -------------------------- |
| Get Config       | GET    | `/api/v1/brands/:brandId/llm-config`                  | Fetch LLM configuration    |
| Update Config    | PATCH  | `/api/v1/brands/:brandId/llm-config`                  | Update LLM settings        |
| Enable LLM       | PATCH  | `/api/v1/brands/:brandId/llm-config/:llmId/enable`    | Enable monitoring for LLM  |
| Disable LLM      | PATCH  | `/api/v1/brands/:brandId/llm-config/:llmId/disable`   | Disable monitoring for LLM |
| Update Frequency | PATCH  | `/api/v1/brands/:brandId/llm-config/:llmId/frequency` | Update polling frequency   |

**Request/Response Schemas:**

```dart
// LLM Configuration Request
{
  "llmConfigs": [
    {
      "llmId": "string (required)",
      "name": "enum: [chatgpt, gemini, perplexity, claude] (required)",
      "enabled": "boolean",
      "tier": "enum: [free, pro, enterprise] (optional)",
      "pollingIntervalMinutes": "integer (required, min: 5, max: 1440)",
      "keywords": ["string"] (optional)
    }
  ],
  "globalPollingEnabled": "boolean (optional)"
}

// LLM Configuration Response
{
  "brandId": "string (UUID)",
  "llmConfigs": [
    {
      "id": "string (UUID)",
      "llmId": "string",
      "name": "string",
      "enabled": "boolean",
      "tier": "string",
      "pollingIntervalMinutes": "integer",
      "lastPolled": "ISO 8601",
      "nextPollingSchedule": "ISO 8601",
      "keywords": ["string"],
      "status": "enum: [active, paused, error]"
    }
  ],
  "globalPollingEnabled": "boolean",
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}

// Frequency Update Request
{
  "pollingIntervalMinutes": "integer (required, 5-1440)"
}
```

---

### 5. Brand Positioning Data

**Base Path:** `/api/v1/brands/:brandId/positioning`

| Operation          | Method | Endpoint                                        | Purpose                |
| ------------------ | ------ | ----------------------------------------------- | ---------------------- |
| Get Positioning    | GET    | `/api/v1/brands/:brandId/positioning`           | Fetch positioning data |
| Update Positioning | PATCH  | `/api/v1/brands/:brandId/positioning`           | Update positioning     |
| Get Analytics      | GET    | `/api/v1/brands/:brandId/positioning/analytics` | Get trend analytics    |

**Request/Response Schemas:**

```dart
// Positioning Request
{
  "keyMessages": ["string"],
  "targetAudience": "string",
  "uniqueValueProp": "string",
  "competitors": ["string"],
  "differentiators": ["string"]
}

// Positioning Response
{
  "id": "string (UUID)",
  "brandId": "string (UUID)",
  "keyMessages": ["string"],
  "targetAudience": "string",
  "uniqueValueProp": "string",
  "competitors": ["string"],
  "differentiators": ["string"],
  "score": "decimal (0-100)",
  "recommendations": ["string"],
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

---

### 6. Project Management

**Base Path:** `/api/v1/projects`

| Operation      | Method | Endpoint                             | Purpose               |
| -------------- | ------ | ------------------------------------ | --------------------- |
| List Projects  | GET    | `/api/v1/projects`                   | Get all user projects |
| Get Project    | GET    | `/api/v1/projects/:projectId`        | Fetch single project  |
| Create Project | POST   | `/api/v1/projects`                   | Create new project    |
| Update Project | PATCH  | `/api/v1/projects/:projectId`        | Modify project        |
| Delete Project | DELETE | `/api/v1/projects/:projectId`        | Remove project        |
| Switch Project | PATCH  | `/api/v1/projects/:projectId/switch` | Set active project    |

**Request/Response Schemas:**

```dart
// Create/Update Request
{
  "name": "string (required)",
  "brandId": "string (required, UUID)",
  "owner": "string (required)",
  "stage": "enum: [discovery, setup, launch, optimization] (required)",
  "focus": "string (optional)",
  "description": "string (optional)"
}

// Response
{
  "id": "string (UUID)",
  "name": "string",
  "brandId": "string (UUID)",
  "owner": "string",
  "stage": "string",
  "focus": "string",
  "description": "string",
  "completionPercentage": "decimal (0-100)",
  "isActive": "boolean",
  "members": ["string"],
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

---

## Current Implementation Patterns

### Network Layer Pattern

```dart
// API Class Example (existing pattern)
class SomeApi {
  final DioClient _dioClient;
  SomeApi(this._dioClient);

  Future<SomeEntity> getSomething(String id) async {
    final response = await _dioClient.dio.get(
      Endpoints.getSomething(id),
    );
    return SomeEntity.fromJson(response.data);
  }
}
```

### Repository Pattern (existing)

```dart
// Abstract interface
abstract class SomeRepository {
  Future<SomeEntity> getSomething(String id);
}

// Implementation
class SomeRepositoryImpl implements SomeRepository {
  final SomeApi _api;
  SomeRepositoryImpl(this._api);

  @override
  Future<SomeEntity> getSomething(String id) {
    return _api.getSomething(id);
  }
}
```

### Use Case Pattern (existing)

```dart
class GetSomethingUseCase extends UseCase<SomeEntity, GetSomethingParams> {
  final SomeRepository _repository;

  GetSomethingUseCase(this._repository);

  @override
  Future<SomeEntity> call(GetSomethingParams params) {
    return _repository.getSomething(params.id);
  }
}
```

### MobX Store Pattern (existing)

```dart
class SomeStore = _SomeStore with _$SomeStore;

abstract class _SomeStore with Store {
  final GetSomethingUseCase _useCase;
  final ErrorStore errorStore;

  @observable
  SomeEntity? entity;

  @action
  Future<void> getSomething(String id) async {
    try {
      entity = await _useCase(GetSomethingParams(id: id));
    } catch (e) {
      errorStore.setError(e);
    }
  }
}
```

---

## DTOs & Entity Mapping

All API responses must have corresponding DTOs:

- **Network DTOs** (data layer): `BrandDto`, `KnowledgeBaseEntryDto`, etc.
- **Domain Entities** (domain layer): `Brand`, `KnowledgeBaseEntry`, etc.
- **UI Models** (presentation layer): Mapping from domain entities

Example mapping flow:

```
JSON ← DioClient → BrandDto.fromJson() → Brand.fromDto() → BrandSetupStore
```

---

## Error Handling Strategy

1. **Network Errors**: DioClient interceptors catch and log
2. **Serialization Errors**: DTOs validate on fromJson()
3. **Business Logic Errors**: Repositories throw domain exceptions
4. **UI Feedback**: ErrorStore publishes errors to MobX stores
5. **Retry Logic**: DioRetryInterceptor handles transient failures

---

## Testing Assumptions

- All API calls mockable via Dio interceptors
- JSON fixtures prepared for unit tests
- Mock repositories for UI layer tests
- Integration tests with test backend API

---

## File Organization

```
lib/
├── data/
│   ├── network/
│   │   ├── apis/
│   │   │   ├── brand/brand_api.dart (NEW)
│   │   │   ├── knowledge_base/knowledge_base_api.dart (NEW)
│   │   │   ├── link/link_api.dart (NEW)
│   │   │   ├── rewrite_rule/rewrite_rule_api.dart (NEW)
│   │   │   ├── llm_config/llm_config_api.dart (NEW)
│   │   │   ├── brand_positioning/brand_positioning_api.dart (NEW)
│   │   │   └── project/project_api.dart (NEW)
│   │   └── constants/endpoints.dart (UPDATE)
│   ├── repository/
│   │   ├── brand/ (NEW)
│   │   ├── knowledge_base/ (NEW)
│   │   ├── link/ (NEW)
│   │   ├── rewrite_rule/ (NEW)
│   │   ├── llm_config/ (NEW)
│   │   ├── brand_positioning/ (NEW)
│   │   └── project/ (NEW)
│   └── di/module/network_module.dart (UPDATE)
├── domain/
│   ├── entity/
│   │   ├── brand/ (NEW)
│   │   ├── knowledge_base/ (NEW)
│   │   ├── link/ (NEW)
│   │   ├── rewrite_rule/ (NEW)
│   │   ├── llm_config/ (NEW)
│   │   ├── brand_positioning/ (NEW)
│   │   └── project/ (NEW)
│   ├── repository/
│   │   └── (abstract interfaces, NEW)
│   ├── usecase/
│   │   └── (all use cases, NEW)
│   └── di/module/domain_layer_injection.dart (UPDATE)
└── presentation/
    └── brand_setup/
        ├── store/brand_setup_store.dart (UPDATE)
        └── screen/brand_setup_screen.dart (UPDATE)
```

---

## Key Considerations

1. **Backward Compatibility**: Ensure existing code paths still work
2. **Error States**: Handle missing/invalid data gracefully
3. **Performance**: Lazy load data, pagination for large lists
4. **Validation**: Server-side validation primary, client-side for UX
5. **Caching**: Consider local storage for frequently accessed data
6. **Security**: Never log sensitive data, use encrypted local storage
