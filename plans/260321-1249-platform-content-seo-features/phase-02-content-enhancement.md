---
title: "Phase 2: Content Enhancement"
status: pending
priority: P2
effort: 10h
issue: "#7"
depends_on: phase-01
---

# Phase 2: Content Enhancement (Feature 8)

## Context Links

- [Issue #7](../../issues/7)
- [Phase 1 - Platform Foundation](./phase-01-platform-analytics.md) (dependency)
- [UseCase base class](../../lib/core/domain/usecase/use_case.dart)
- [Post entity pattern](../../lib/domain/entity/post/post.dart)
- [PostApi pattern](../../lib/data/network/apis/posts/post_api.dart)
- [PostStore pattern](../../lib/presentation/post/store/post_store.dart)

## Overview

AI-powered content tools: refine/enhance text, rewrite/paraphrase, humanize AI-generated content, and summarize. These features call a backend AI service API. The UI provides a text input area, action selection, and output display with copy/edit capabilities.

## Key Insights

- No AI API integration exists yet -- need a dedicated API client for AI services
- Content operations are stateless transforms: input text -> AI service -> output text
- All four operations (enhance, rewrite, humanize, summarize) share the same request/response shape
- The existing `DioClient` pattern works well; create a second client for AI service base URL
- MobX store pattern from `PostStore` is the template for new stores

## Requirements

### Functional
- FR1: User can input/paste text content for processing
- FR2: User can select operation: Enhance, Rewrite, Humanize, Summarize
- FR3: App sends text to AI backend, displays result
- FR4: User can copy result to clipboard
- FR5: User can edit the result inline before copying
- FR6: User can view processing history (current session)
- FR7: Loading state shown during AI processing
- FR8: Error handling for network failures and API errors

### Non-Functional
- NFR1: AI requests timeout at 60s (longer than standard 15s)
- NFR2: Input text limited to 10,000 characters
- NFR3: Results cached in-memory for current session (no persistence needed)

## Architecture

```
presentation/content_enhancement/
  ├── content_enhancement_screen.dart    # Main screen with tab/selector
  ├── widgets/
  │   ├── content_input_widget.dart      # Text input area
  │   └── content_result_widget.dart     # Result display with copy/edit
  └── store/
      └── content_enhancement_store.dart # MobX store

domain/
  ├── entity/content/
  │   ├── content_request.dart           # Input text + operation type
  │   └── content_result.dart            # Processed text + metadata
  ├── repository/content/
  │   └── content_repository.dart        # Abstract interface
  └── usecase/content/
      ├── enhance_content_usecase.dart
      ├── rewrite_content_usecase.dart
      ├── humanize_content_usecase.dart
      └── summarize_content_usecase.dart

data/
  ├── network/apis/content/
  │   └── content_api.dart               # AI service HTTP calls
  └── repository/content/
      └── content_repository_impl.dart
```

**API Contract (expected)**:
```
POST /api/v1/content/{operation}
Body: { "text": "...", "options": {} }
Response: { "result": "...", "operation": "enhance", "tokens_used": 150 }
```

## Related Code Files

### Files to CREATE

| File | Purpose |
|------|---------|
| `lib/domain/entity/content/content_operation.dart` | Enum: enhance, rewrite, humanize, summarize |
| `lib/domain/entity/content/content_request.dart` | Request model: text + operation + options |
| `lib/domain/entity/content/content_result.dart` | Result model: processed text + metadata |
| `lib/domain/repository/content/content_repository.dart` | Abstract repository interface |
| `lib/domain/usecase/content/enhance_content_usecase.dart` | Enhance use case |
| `lib/domain/usecase/content/rewrite_content_usecase.dart` | Rewrite use case |
| `lib/domain/usecase/content/humanize_content_usecase.dart` | Humanize use case |
| `lib/domain/usecase/content/summarize_content_usecase.dart` | Summarize use case |
| `lib/data/network/apis/content/content_api.dart` | Dio HTTP calls to AI service |
| `lib/data/repository/content/content_repository_impl.dart` | Repository implementation |
| `lib/presentation/content_enhancement/content_enhancement_screen.dart` | Main screen |
| `lib/presentation/content_enhancement/widgets/content_input_widget.dart` | Text input widget |
| `lib/presentation/content_enhancement/widgets/content_result_widget.dart` | Result display widget |
| `lib/presentation/content_enhancement/store/content_enhancement_store.dart` | MobX store |

### Files to MODIFY

| File | Changes |
|------|---------|
| `lib/data/network/constants/endpoints.dart` | Add content API endpoints |
| `lib/data/di/module/network_module.dart` | Register ContentApi |
| `lib/data/di/module/repository_module.dart` | Register ContentRepository |
| `lib/domain/di/module/usecase_module.dart` | Register 4 content use cases |
| `lib/presentation/di/module/store_module.dart` | Register ContentEnhancementStore |
| `lib/utils/routes/routes.dart` | Add `/content-enhancement` route |
| `lib/presentation/home/home.dart` | Add navigation to content enhancement |

## Implementation Steps

### Step 1: Domain Layer -- Entities (1h)

1. Create `lib/domain/entity/content/content_operation.dart`:
   ```dart
   enum ContentOperation { enhance, rewrite, humanize, summarize }
   ```
   Include `toApiPath()` extension returning the API path segment.

2. Create `lib/domain/entity/content/content_request.dart`:
   - Fields: `String text`, `ContentOperation operation`, `Map<String, dynamic>? options`
   - `toMap()` for JSON serialization

3. Create `lib/domain/entity/content/content_result.dart`:
   - Fields: `String resultText`, `ContentOperation operation`, `int? tokensUsed`, `DateTime processedAt`
   - `factory fromMap(Map<String, dynamic> json)`

### Step 2: Domain Layer -- Repository & Use Cases (1.5h)

1. Create `lib/domain/repository/content/content_repository.dart`:
   ```dart
   abstract class ContentRepository {
     Future<ContentResult> processContent(ContentRequest request);
   }
   ```
   Single method -- operation type is in the request.

2. Create 4 use case files, each extending `UseCase<ContentResult, ContentRequest>`:
   - `enhance_content_usecase.dart`
   - `rewrite_content_usecase.dart`
   - `humanize_content_usecase.dart`
   - `summarize_content_usecase.dart`

   Each use case wraps `ContentRepository.processContent()` but enforces its specific `ContentOperation` on the request. This keeps the use cases explicit in the DI graph even though they share the same repository method.

### Step 3: Data Layer -- API & Repository (2h)

1. Update `lib/data/network/constants/endpoints.dart`:
   - Add `static const String contentBase = "/api/v1/content"` (relative, uses AI base URL)
   - Add `static String contentOperation(String op) => "$contentBase/$op"`
   - Add `static const String aiBaseUrl` reading from EnvironmentConfig
   - Add `static const int aiReceiveTimeout = 60000` (60s for AI calls)

2. Create `lib/data/network/apis/content/content_api.dart`:
   - Constructor takes `DioClient` (or a second AI-specific DioClient)
   - `Future<ContentResult> processContent(ContentRequest request)`:
     - POST to `/api/v1/content/{operation}`
     - Body: `request.toMap()`
     - Parse response into `ContentResult`
   - Handle timeout and error cases with try/catch

3. Create `lib/data/repository/content/content_repository_impl.dart`:
   - Implements `ContentRepository`
   - Delegates to `ContentApi`
   - No local caching needed (session-only memory cache is in the store)

4. Update `lib/data/di/module/network_module.dart`:
   - Register a second `DioClient` for AI services (named registration):
     ```dart
     getIt.registerSingleton<DioClient>(
       DioClient(dioConfigs: aiDioConfigs)..addInterceptors([...]),
       instanceName: 'aiDioClient',
     );
     ```
   - Register `ContentApi` with the AI DioClient

5. Update `lib/data/di/module/repository_module.dart`:
   - Register `ContentRepository` -> `ContentRepositoryImpl`

### Step 4: Domain DI -- Use Cases (0.5h)

1. Update `lib/domain/di/module/usecase_module.dart`:
   - Register all 4 content use cases with `ContentRepository` dependency

### Step 5: Presentation Layer -- Store (2h)

1. Create `lib/presentation/content_enhancement/store/content_enhancement_store.dart`:
   - Observable fields:
     - `ContentOperation selectedOperation` (default: enhance)
     - `String inputText`
     - `ContentResult? currentResult`
     - `ObservableList<ContentResult> sessionHistory`
     - `ObservableFuture<ContentResult?> processFuture` (for loading state)
     - `bool success`
   - Computed: `bool get loading`
   - Actions:
     - `setOperation(ContentOperation op)`
     - `setInputText(String text)`
     - `processContent()` -- calls appropriate use case based on selectedOperation
     - `clearResult()`
     - `clearHistory()`
   - Inject all 4 use cases + ErrorStore

2. Register in `lib/presentation/di/module/store_module.dart`

### Step 6: Presentation Layer -- UI (3h)

1. Create `lib/presentation/content_enhancement/widgets/content_input_widget.dart`:
   - `TextField` with maxLines, maxLength (10000 chars)
   - Character count display
   - Clear button
   - Paste from clipboard button

2. Create `lib/presentation/content_enhancement/widgets/content_result_widget.dart`:
   - Display processed text in a scrollable container
   - Copy to clipboard button with snackbar confirmation
   - Inline edit toggle (switches to editable TextField)
   - Tokens used / operation type metadata display
   - Empty state when no result

3. Create `lib/presentation/content_enhancement/content_enhancement_screen.dart`:
   - AppBar with title "Content Enhancement"
   - Operation selector (SegmentedButton or ChoiceChips for the 4 operations)
   - ContentInputWidget
   - "Process" action button (disabled when input empty or loading)
   - ContentResultWidget
   - Loading overlay (reuse `CustomProgressIndicatorWidget`)
   - Error display via Flushbar (existing pattern)
   - Session history list (expandable/collapsible)

4. Update `lib/utils/routes/routes.dart`:
   - Add `static const String contentEnhancement = '/content-enhancement'`
   - Add route mapping

5. Update `lib/presentation/home/home.dart`:
   - Add navigation item/button to reach content enhancement screen

## Todo List

- [ ] Create ContentOperation enum in domain/entity/content/
- [ ] Create ContentRequest entity
- [ ] Create ContentResult entity
- [ ] Create ContentRepository abstract interface
- [ ] Create EnhanceContentUseCase
- [ ] Create RewriteContentUseCase
- [ ] Create HumanizeContentUseCase
- [ ] Create SummarizeContentUseCase
- [ ] Create ContentApi with AI service HTTP calls
- [ ] Create ContentRepositoryImpl
- [ ] Register AI DioClient (named instance) in NetworkModule
- [ ] Register ContentApi in NetworkModule
- [ ] Register ContentRepository in RepositoryModule
- [ ] Register 4 use cases in UseCaseModule
- [ ] Create ContentEnhancementStore (MobX)
- [ ] Register store in StoreModule
- [ ] Run `build_runner build` for .g.dart generation
- [ ] Create ContentInputWidget
- [ ] Create ContentResultWidget
- [ ] Create ContentEnhancementScreen
- [ ] Add route in routes.dart
- [ ] Add navigation from home screen
- [ ] Run `flutter analyze` -- verify no errors
- [ ] Test each operation end-to-end

## Success Criteria

- All 4 content operations callable from UI
- Loading indicator shown during processing
- Result displayed with copy-to-clipboard working
- Error states handled gracefully (timeout, network error, API error)
- Session history tracks processed items
- `flutter analyze` passes
- Navigation from home screen works

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| AI backend API not ready | Cannot test real responses | Design ContentApi to be swappable; create a mock implementation behind a feature flag |
| Long AI processing times | Poor UX | 60s timeout, loading indicator, allow cancellation |
| Large text input OOM | App crash | 10,000 char limit, chunking for very long content |
| API response format changes | Parse errors | ContentResult.fromMap with null safety, defensive parsing |

## Security Considerations

- AI API key must be in environment config, not hardcoded
- User content sent to AI service -- consider data privacy implications
- No local persistence of processed content (session-only)
- Auth interceptor attaches user token to AI API requests

## Next Steps

- Integrate with real AI backend when API is available
- Add content templates/presets for common operations
- Add batch processing capability
- Add export/share functionality for results
