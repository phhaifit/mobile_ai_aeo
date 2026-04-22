---
title: "Topic Detail Prompt API Integration"
description: "Replace hardcoded topic detail prompts with GET /api/prompts/by-topic while preserving current UI behavior."
status: pending
priority: P2
effort: 3h
branch: LoiNguyennn/phase-2/feature-3
tags: [flutter, topic-detail, prompts, api]
created: 2026-04-12
---

## Overview
- Goal: remove hardcoded `_prompts` in topic detail flow, load prompts from backend endpoint by topic id.
- Scope: active + inactive prompt lists only; keep search/filter UI behavior unchanged.
- Constraints: minimal-risk edits, preserve current screen structure and actions.

## Files To Edit
- `lib/presentation/topics_keywords/store/topics_keywords_store.dart`
- `lib/presentation/topics_keywords/topics_keywords.dart`
- `lib/presentation/topics_keywords/topic_detail/topic_detail.dart`
- `lib/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart`
- Optional if compile impact appears: `lib/presentation/prompt_library/prompt_library.dart`

## Exact API Mapping (response.data[] -> PromptItem)
- Endpoint: `GET /api/prompts/by-topic?topicId=<id>&status=<active|inactive>&page=1&pageSize=10`
- Wrapper: `response.data` contains pagination object; prompt rows are in `response.data.data`.

Field mapping:
- `id` -> `PromptItem.id`
- `content` -> `PromptItem.question`
- `status` (`active`/`inactive`) -> `PromptItem.tab`
  - `active` => `TopicDetailTab.active`
  - `inactive` => `TopicDetailTab.inactive`
- `updatedAt` -> `PromptItem.deletedAt` only when status is `inactive`, else `null`
- `type` -> `PromptItem.promptType`
  - `Informational` => `PromptTypeFilter.informational`
  - `Commercial` => `PromptTypeFilter.commercial`
  - `Transactional` => `PromptTypeFilter.transactional`
  - `Navigational` => `PromptTypeFilter.navigational`
  - fallback => `PromptTypeFilter.informational`
- `isMonitored` -> `PromptItem.isMonitored`
- `keywords` (`List<String>`) -> `PromptItem.keywords`
  - each keyword string => `PromptKeyword(value: keyword, type: PromptKeywordType.neutral)`
- `latestResults` (active responses; may be absent) -> display fields:
  - `PromptItem.llm`: first `latestResults[i].model`, fallback `'-'`
  - `PromptItem.brandMentioned`: any `latestResults[i].isMentioned == true` => `'Yes'`, else `'No'`
  - `PromptItem.linkAppeared`: any `latestResults[i].isCited == true` => `'Yes'`, else `'No'`
  - `PromptItem.sentiment`: first non-empty `latestResults[i].sentiment`, fallback `'-'`
- `createdAt` -> `PromptItem.createdAt` (`DateTime.tryParse`, fallback `DateTime.now()`)

Notes:
- For inactive/suggested rows where `latestResults` is absent, set `llm/brandMentioned/linkAppeared/sentiment` to `'-'`.
- Keep topic keyword chip optional; if needed for UX parity prepend `topicName` as `PromptKeywordType.topicKeyword`.

## Loading/Error Handling Approach
- Add store state:
  - `bool _isLoading = false`
  - `String? _errorMessage`
  - public getters `isLoading`, `errorMessage`.
- Add async loader in `TopicDetailStore`:
  - `Future<void> fetchPrompts({required TopicDetailTab tab})`
  - Skip network for non-prompt tabs (`suggestion`, `keyword`).
  - Build query with fixed pagination `page=1&pageSize=10` and status mapped from tab.
  - Parse rows, replace only prompts of selected status in `_prompts`, preserve other tab entries.
- Error policy:
  - on failure: set `_errorMessage = 'Unable to load prompts. Please try again.'`
  - keep previous `_prompts` data (no destructive clear) for safer UX.
- UI handling in topic detail screen:
  - trigger initial fetch in `initState`.
  - trigger fetch when switching between `Active` and `Inactive` tabs.
  - show loading indicator in tab body while `_isLoading` true.
  - show retry block when `errorMessage != null` and list empty.
- Search/filter behavior:
  - keep existing local filter logic in `filteredPrompts` unchanged.
  - no server-side search/filter in phase 1 to minimize behavior risk.

## Backward-Compatible Constructor Changes
- `TopicDetailScreen`:
  - add optional `String? topicId` (keep existing required `topicName` and optional `titleOverride`).
- `TopicDetailStore`:
  - add optional `String? topicId` and keep `topicName`.
  - if `topicId == null || topicId!.isEmpty`: do not call API; expose friendly error or empty-state message.
- Navigation update (primary path):
  - in topics card click, pass `topicId: item.id` to `TopicDetailScreen`.
- Existing callers compatibility:
  - existing calls without `topicId` continue compiling.
  - only if needed, add `topicId` to `PromptLibraryScreen` call once an ID source exists.

## Minimal Implementation Steps
1. Add `topicId` to topic entity used by list navigation (already available as `TopicKeywordItem.id`).
2. Pass topic id from topic card tap into topic detail constructor.
3. Extend topic detail store with loading/error state + `fetchPrompts` network method using `DioClient` and `getIt`.
4. Replace hardcoded seed list with empty list + API hydration.
5. Wire initial and tab-change fetch calls in topic detail screen.
6. Keep filter/search UI unchanged; verify active/inactive tabs still filter locally.
7. Run compile check: `flutter analyze`.

## Risks And Mitigation
- Missing `topicId` from non-list entry points: keep optional constructor and graceful empty/error state.
- Backend shape drift (`latestResults` absent): defensive parsing + defaults.
- Regressions in non-prompt tabs: gate network calls strictly to active/inactive tabs.

## Success Criteria
- Topic tap passes topic id into detail screen.
- Active tab loads from API status=active, inactive tab loads status=inactive.
- Existing search and filter interactions still work on loaded data.
- No hardcoded `_prompts` seed remains in `TopicDetailStore`.
- App compiles without analyzer errors.

## Unresolved Questions
- Should `PromptLibraryScreen` provide a real `topicId` or stay empty-state only for now?
- Should monitoring/type/search be sent to API now, or remain local-only in this phase?
