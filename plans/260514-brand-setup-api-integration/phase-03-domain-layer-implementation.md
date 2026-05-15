# Phase 3: Domain Layer Implementation

## Objective

Create domain entities, repository interfaces, repository implementations, and use cases for all brand setup features.

## Overview

| Component                  | Count     | Status  |
| -------------------------- | --------- | ------- |
| Domain Entities            | 7         | pending |
| Repository Interfaces      | 7         | pending |
| Repository Implementations | 7         | pending |
| Use Cases                  | 25+       | pending |
| DI Registrations           | 2 modules | pending |

---

## Step 1: Create Domain Entities

Domain entities are business models independent of presentation and data layers.

### 1.1 Brand Entity

**File:** `lib/domain/entity/brand/brand.dart` (NEW)

```dart
class Brand {
  final String id;
  final String name;
  final String tagline;
  final String industry;
  final String website;
  final String? logoUrl;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.website,
    this.logoUrl,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from DTO (data transfer object)
  static Brand fromDto(BrandDto dto) {
    return Brand(
      id: dto.id,
      name: dto.name,
      tagline: dto.tagline,
      industry: dto.industry,
      website: dto.website,
      logoUrl: dto.logoUrl,
      verified: dto.verified,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  /// Create a new brand (for POST requests)
  Brand.create({
    required this.name,
    required this.tagline,
    required this.industry,
    required this.website,
    this.logoUrl,
  })  : id = '',
        verified = false,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// Copy with changes
  Brand copyWith({
    String? id,
    String? name,
    String? tagline,
    String? industry,
    String? website,
    String? logoUrl,
    bool? verified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Brand(id: $id, name: $name)';
}
```

### 1.2 Knowledge Base Entry Entity

**File:** `lib/domain/entity/knowledge_base/knowledge_base_entry.dart` (NEW)

```dart
class KnowledgeBaseEntry {
  final String id;
  final String title;
  final String type; // article, faq, resource, policy
  final String content;
  final String? url;
  final String? category;
  final List<String>? tags;
  final bool isPublic;
  final String status; // draft, published, archived
  final String freshness; // fresh, stale, outdated
  final int sourceCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeBaseEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.url,
    this.category,
    this.tags,
    required this.isPublic,
    required this.status,
    required this.freshness,
    required this.sourceCount,
    required this.createdAt,
    required this.updatedAt,
  });

  static KnowledgeBaseEntry fromDto(KnowledgeBaseEntryDto dto) {
    return KnowledgeBaseEntry(
      id: dto.id,
      title: dto.title,
      type: dto.type,
      content: dto.content,
      url: dto.url,
      category: dto.category,
      tags: dto.tags,
      isPublic: dto.isPublic,
      status: dto.status,
      freshness: dto.freshness,
      sourceCount: dto.sourceCount,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  KnowledgeBaseEntry.create({
    required this.title,
    required this.type,
    required this.content,
    this.url,
    this.category,
    this.tags,
    this.isPublic = true,
  })  : id = '',
        status = 'draft',
        freshness = 'fresh',
        sourceCount = 0,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  KnowledgeBaseEntry copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
    String? url,
    String? category,
    List<String>? tags,
    bool? isPublic,
    String? status,
    String? freshness,
    int? sourceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KnowledgeBaseEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      url: url ?? this.url,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      freshness: freshness ?? this.freshness,
      sourceCount: sourceCount ?? this.sourceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'KnowledgeBaseEntry(id: $id, title: $title)';
}
```

### 1.3 Link Entity

**File:** `lib/domain/entity/link/link.dart` (NEW)

```dart
class Link {
  final String id;
  final String url;
  final String label;
  final String type; // website, social, directory
  final bool monitored;
  final int? priority;
  final DateTime? lastChecked;
  final String status; // active, inactive, broken
  final DateTime createdAt;
  final DateTime updatedAt;

  Link({
    required this.id,
    required this.url,
    required this.label,
    required this.type,
    required this.monitored,
    this.priority,
    this.lastChecked,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static Link fromDto(LinkDto dto) {
    return Link(
      id: dto.id,
      url: dto.url,
      label: dto.label,
      type: dto.type,
      monitored: dto.monitored,
      priority: dto.priority,
      lastChecked: dto.lastChecked != null ? DateTime.parse(dto.lastChecked!) : null,
      status: dto.status,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  Link.create({
    required this.url,
    required this.label,
    required this.type,
    this.monitored = true,
    this.priority,
  })  : id = '',
        lastChecked = null,
        status = 'active',
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  Link copyWith({
    String? id,
    String? url,
    String? label,
    String? type,
    bool? monitored,
    int? priority,
    DateTime? lastChecked,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Link(
      id: id ?? this.id,
      url: url ?? this.url,
      label: label ?? this.label,
      type: type ?? this.type,
      monitored: monitored ?? this.monitored,
      priority: priority ?? this.priority,
      lastChecked: lastChecked ?? this.lastChecked,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Link(id: $id, url: $url)';
}
```

### 1.4 Rewrite Rule Entity

**File:** `lib/domain/entity/rewrite_rule/rewrite_rule.dart` (NEW)

```dart
class RewriteRule {
  final String id;
  final String pattern;
  final String target;
  final bool enabled;
  final int? priority;
  final String? testUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewriteRule({
    required this.id,
    required this.pattern,
    required this.target,
    required this.enabled,
    this.priority,
    this.testUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  static RewriteRule fromDto(RewriteRuleDto dto) {
    return RewriteRule(
      id: dto.id,
      pattern: dto.pattern,
      target: dto.target,
      enabled: dto.enabled,
      priority: dto.priority,
      testUrl: dto.testUrl,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  RewriteRule.create({
    required this.pattern,
    required this.target,
    this.enabled = true,
    this.priority,
  })  : id = '',
        testUrl = null,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  RewriteRule copyWith({
    String? id,
    String? pattern,
    String? target,
    bool? enabled,
    int? priority,
    String? testUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewriteRule(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      target: target ?? this.target,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      testUrl: testUrl ?? this.testUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'RewriteRule(id: $id, pattern: $pattern)';
}
```

### 1.5 LLM Config Entity

**File:** `lib/domain/entity/llm_config/llm_config.dart` (NEW)

```dart
class LlmConfig {
  final String brandId;
  final List<LlmDetail> llmConfigs;
  final bool globalPollingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  LlmConfig({
    required this.brandId,
    required this.llmConfigs,
    required this.globalPollingEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  static LlmConfig fromDto(LlmConfigDto dto) {
    return LlmConfig(
      brandId: dto.brandId,
      llmConfigs: dto.llmConfigs
          .map((e) => LlmDetail.fromDto(e))
          .toList(),
      globalPollingEnabled: dto.globalPollingEnabled,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  @override
  String toString() => 'LlmConfig(brandId: $brandId, count: ${llmConfigs.length})';
}

class LlmDetail {
  final String id;
  final String llmId;
  final String name;
  final bool enabled;
  final String tier;
  final int pollingIntervalMinutes;
  final DateTime? lastPolled;
  final DateTime? nextPollingSchedule;
  final List<String>? keywords;
  final String status; // active, paused, error

  LlmDetail({
    required this.id,
    required this.llmId,
    required this.name,
    required this.enabled,
    required this.tier,
    required this.pollingIntervalMinutes,
    this.lastPolled,
    this.nextPollingSchedule,
    this.keywords,
    required this.status,
  });

  static LlmDetail fromDto(LlmDetailDto dto) {
    return LlmDetail(
      id: dto.id,
      llmId: dto.llmId,
      name: dto.name,
      enabled: dto.enabled,
      tier: dto.tier,
      pollingIntervalMinutes: dto.pollingIntervalMinutes,
      lastPolled: dto.lastPolled != null ? DateTime.parse(dto.lastPolled!) : null,
      nextPollingSchedule: dto.nextPollingSchedule != null
          ? DateTime.parse(dto.nextPollingSchedule!)
          : null,
      keywords: dto.keywords,
      status: dto.status,
    );
  }

  LlmDetail copyWith({
    String? id,
    String? llmId,
    String? name,
    bool? enabled,
    String? tier,
    int? pollingIntervalMinutes,
    DateTime? lastPolled,
    DateTime? nextPollingSchedule,
    List<String>? keywords,
    String? status,
  }) {
    return LlmDetail(
      id: id ?? this.id,
      llmId: llmId ?? this.llmId,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      tier: tier ?? this.tier,
      pollingIntervalMinutes: pollingIntervalMinutes ?? this.pollingIntervalMinutes,
      lastPolled: lastPolled ?? this.lastPolled,
      nextPollingSchedule: nextPollingSchedule ?? this.nextPollingSchedule,
      keywords: keywords ?? this.keywords,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'LlmDetail(name: $name, enabled: $enabled)';
}
```

### 1.6 Brand Positioning Entity

**File:** `lib/domain/entity/brand_positioning/brand_positioning.dart` (NEW)

```dart
class BrandPositioning {
  final String id;
  final String brandId;
  final List<String> keyMessages;
  final String targetAudience;
  final String uniqueValueProp;
  final List<String> competitors;
  final List<String> differentiators;
  final double score;
  final List<String> recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  BrandPositioning({
    required this.id,
    required this.brandId,
    required this.keyMessages,
    required this.targetAudience,
    required this.uniqueValueProp,
    required this.competitors,
    required this.differentiators,
    required this.score,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  static BrandPositioning fromDto(BrandPositioningDto dto) {
    return BrandPositioning(
      id: dto.id,
      brandId: dto.brandId,
      keyMessages: dto.keyMessages,
      targetAudience: dto.targetAudience,
      uniqueValueProp: dto.uniqueValueProp,
      competitors: dto.competitors,
      differentiators: dto.differentiators,
      score: dto.score,
      recommendations: dto.recommendations,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  BrandPositioning.create({
    required this.brandId,
    required this.keyMessages,
    required this.targetAudience,
    required this.uniqueValueProp,
    required this.competitors,
    required this.differentiators,
  })  : id = '',
        score = 0.0,
        recommendations = [],
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  BrandPositioning copyWith({
    String? id,
    String? brandId,
    List<String>? keyMessages,
    String? targetAudience,
    String? uniqueValueProp,
    List<String>? competitors,
    List<String>? differentiators,
    double? score,
    List<String>? recommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandPositioning(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      keyMessages: keyMessages ?? this.keyMessages,
      targetAudience: targetAudience ?? this.targetAudience,
      uniqueValueProp: uniqueValueProp ?? this.uniqueValueProp,
      competitors: competitors ?? this.competitors,
      differentiators: differentiators ?? this.differentiators,
      score: score ?? this.score,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'BrandPositioning(id: $id, score: $score)';
}
```

### 1.7 Project Entity

**File:** `lib/domain/entity/project/project.dart` (NEW)

```dart
class Project {
  final String id;
  final String name;
  final String brandId;
  final String owner;
  final String stage; // discovery, setup, launch, optimization
  final String? focus;
  final String? description;
  final double completionPercentage;
  final bool isActive;
  final List<String>? members;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.brandId,
    required this.owner,
    required this.stage,
    this.focus,
    this.description,
    required this.completionPercentage,
    required this.isActive,
    this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  static Project fromDto(ProjectDto dto) {
    return Project(
      id: dto.id,
      name: dto.name,
      brandId: dto.brandId,
      owner: dto.owner,
      stage: dto.stage,
      focus: dto.focus,
      description: dto.description,
      completionPercentage: dto.completionPercentage,
      isActive: dto.isActive,
      members: dto.members,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  Project.create({
    required this.name,
    required this.brandId,
    required this.owner,
    required this.stage,
    this.focus,
    this.description,
  })  : id = '',
        completionPercentage = 0.0,
        isActive = false,
        members = null,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? brandId,
    String? owner,
    String? stage,
    String? focus,
    String? description,
    double? completionPercentage,
    bool? isActive,
    List<String>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      owner: owner ?? this.owner,
      stage: stage ?? this.stage,
      focus: focus ?? this.focus,
      description: description ?? this.description,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isActive: isActive ?? this.isActive,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
```

---

## Step 2: Create Repository Interfaces

Repository interfaces define contracts for data access layer.

### Interface Pattern

**File:** `lib/domain/repository/brand/brand_repository.dart` (NEW)

```dart
import 'package:boilerplate/domain/entity/brand/brand.dart';

abstract class BrandRepository {
  Future<Brand> getBrand(String brandId);
  Future<List<Brand>> listBrands();
  Future<Brand> createBrand({
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  });
  Future<Brand> updateBrand({
    required String brandId,
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  });
  Future<void> deleteBrand(String brandId);
}
```

Apply same pattern for:

- `lib/domain/repository/knowledge_base/knowledge_base_repository.dart`
- `lib/domain/repository/link/link_repository.dart`
- `lib/domain/repository/rewrite_rule/rewrite_rule_repository.dart`
- `lib/domain/repository/llm_config/llm_config_repository.dart`
- `lib/domain/repository/brand_positioning/brand_positioning_repository.dart`
- `lib/domain/repository/project/project_repository.dart`

(Methods similar to API classes but returning domain entities)

---

## Step 3: Create Repository Implementations

**File:** `lib/data/repository/brand/brand_repository_impl.dart` (NEW)

```dart
import 'package:boilerplate/data/network/apis/brand/brand_api.dart';
import 'package:boilerplate/domain/entity/brand/brand.dart';
import 'package:boilerplate/domain/repository/brand/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandApi _api;

  BrandRepositoryImpl(this._api);

  @override
  Future<Brand> getBrand(String brandId) async {
    final dto = await _api.getBrand(brandId);
    return Brand.fromDto(dto);
  }

  @override
  Future<List<Brand>> listBrands() async {
    final dtos = await _api.listBrands();
    return dtos.map((e) => Brand.fromDto(e)).toList();
  }

  @override
  Future<Brand> createBrand({
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  }) async {
    final dto = await _api.createBrand(
      name: name,
      tagline: tagline,
      industry: industry,
      website: website,
      logoUrl: logoUrl,
      description: description,
    );
    return Brand.fromDto(dto);
  }

  @override
  Future<Brand> updateBrand({
    required String brandId,
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  }) async {
    final dto = await _api.updateBrand(
      brandId: brandId,
      name: name,
      tagline: tagline,
      industry: industry,
      website: website,
      logoUrl: logoUrl,
      description: description,
    );
    return Brand.fromDto(dto);
  }

  @override
  Future<void> deleteBrand(String brandId) {
    return _api.deleteBrand(brandId);
  }
}
```

Apply same pattern for all repositories (7 total):

- `lib/data/repository/knowledge_base/knowledge_base_repository_impl.dart`
- `lib/data/repository/link/link_repository_impl.dart`
- `lib/data/repository/rewrite_rule/rewrite_rule_repository_impl.dart`
- `lib/data/repository/llm_config/llm_config_repository_impl.dart`
- `lib/data/repository/brand_positioning/brand_positioning_repository_impl.dart`
- `lib/data/repository/project/project_repository_impl.dart`

---

## Step 4: Create Use Cases

Use cases encapsulate business logic.

**File:** `lib/domain/usecase/brand/get_brand_usecase.dart` (NEW)

```dart
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/brand/brand.dart';
import 'package:boilerplate/domain/repository/brand/brand_repository.dart';

class GetBrandUseCase extends UseCase<Brand, GetBrandParams> {
  final BrandRepository _repository;

  GetBrandUseCase(this._repository);

  @override
  Future<Brand> call(GetBrandParams params) {
    return _repository.getBrand(params.brandId);
  }
}

class GetBrandParams {
  final String brandId;

  GetBrandParams({required this.brandId});
}
```

Create use cases for (25+):

- Brand: GetBrand, ListBrands, CreateBrand, UpdateBrand, DeleteBrand
- KnowledgeBase: GetEntry, ListEntries, CreateEntry, UpdateEntry, DeleteEntry, BulkDeleteEntries
- Link: GetLinks, CreateLink, UpdateLink, DeleteLink, ToggleMonitor
- RewriteRule: GetRules, CreateRule, UpdateRule, DeleteRule
- LlmConfig: GetConfig, UpdateConfig, EnableLlm, DisableLlm, UpdateFrequency
- BrandPositioning: GetPositioning, UpdatePositioning, GetAnalytics
- Project: GetProject, ListProjects, CreateProject, UpdateProject, DeleteProject, SwitchProject

---

## Step 5: Update DI Modules

**File:** `lib/data/di/module/repository_module.dart` (UPDATE)

```dart
class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // ─── Existing repositories ───────────────────────────────────────
    // ... existing code ...

    // ─── Brand Setup Repositories (NEW) ───────────────────────────────
    getIt.registerSingleton<BrandRepository>(
      BrandRepositoryImpl(getIt<BrandApi>()),
    );
    getIt.registerSingleton<KnowledgeBaseRepository>(
      KnowledgeBaseRepositoryImpl(getIt<KnowledgeBaseApi>()),
    );
    getIt.registerSingleton<LinkRepository>(
      LinkRepositoryImpl(getIt<LinkApi>()),
    );
    getIt.registerSingleton<RewriteRuleRepository>(
      RewriteRuleRepositoryImpl(getIt<RewriteRuleApi>()),
    );
    getIt.registerSingleton<LlmConfigRepository>(
      LlmConfigRepositoryImpl(getIt<LlmConfigApi>()),
    );
    getIt.registerSingleton<BrandPositioningRepository>(
      BrandPositioningRepositoryImpl(getIt<BrandPositioningApi>()),
    );
    getIt.registerSingleton<ProjectRepository>(
      ProjectRepositoryImpl(getIt<ProjectApi>()),
    );
  }
}
```

**File:** `lib/domain/di/module/use_case_module.dart` (UPDATE)

```dart
class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // ─── Existing use cases ──────────────────────────────────────────
    // ... existing code ...

    // ─── Brand Setup Use Cases (NEW) ──────────────────────────────────
    // Brand use cases
    getIt.registerSingleton(GetBrandUseCase(getIt<BrandRepository>()));
    getIt.registerSingleton(ListBrandsUseCase(getIt<BrandRepository>()));
    getIt.registerSingleton(CreateBrandUseCase(getIt<BrandRepository>()));
    getIt.registerSingleton(UpdateBrandUseCase(getIt<BrandRepository>()));
    getIt.registerSingleton(DeleteBrandUseCase(getIt<BrandRepository>()));

    // Knowledge Base use cases
    getIt.registerSingleton(GetKbEntryUseCase(getIt<KnowledgeBaseRepository>()));
    getIt.registerSingleton(ListKbEntriesUseCase(getIt<KnowledgeBaseRepository>()));
    getIt.registerSingleton(CreateKbEntryUseCase(getIt<KnowledgeBaseRepository>()));
    getIt.registerSingleton(UpdateKbEntryUseCase(getIt<KnowledgeBaseRepository>()));
    getIt.registerSingleton(DeleteKbEntryUseCase(getIt<KnowledgeBaseRepository>()));
    getIt.registerSingleton(BulkDeleteKbEntriesUseCase(getIt<KnowledgeBaseRepository>()));

    // Link use cases
    getIt.registerSingleton(ListLinksUseCase(getIt<LinkRepository>()));
    getIt.registerSingleton(CreateLinkUseCase(getIt<LinkRepository>()));
    getIt.registerSingleton(UpdateLinkUseCase(getIt<LinkRepository>()));
    getIt.registerSingleton(DeleteLinkUseCase(getIt<LinkRepository>()));
    getIt.registerSingleton(ToggleLinkMonitorUseCase(getIt<LinkRepository>()));

    // Rewrite Rule use cases
    getIt.registerSingleton(ListRulesUseCase(getIt<RewriteRuleRepository>()));
    getIt.registerSingleton(CreateRuleUseCase(getIt<RewriteRuleRepository>()));
    getIt.registerSingleton(UpdateRuleUseCase(getIt<RewriteRuleRepository>()));
    getIt.registerSingleton(DeleteRuleUseCase(getIt<RewriteRuleRepository>()));

    // LLM Config use cases
    getIt.registerSingleton(GetLlmConfigUseCase(getIt<LlmConfigRepository>()));
    getIt.registerSingleton(UpdateLlmConfigUseCase(getIt<LlmConfigRepository>()));
    getIt.registerSingleton(EnableLlmUseCase(getIt<LlmConfigRepository>()));
    getIt.registerSingleton(DisableLlmUseCase(getIt<LlmConfigRepository>()));
    getIt.registerSingleton(UpdateFrequencyUseCase(getIt<LlmConfigRepository>()));

    // Brand Positioning use cases
    getIt.registerSingleton(GetPositioningUseCase(getIt<BrandPositioningRepository>()));
    getIt.registerSingleton(UpdatePositioningUseCase(getIt<BrandPositioningRepository>()));
    getIt.registerSingleton(GetPositioningAnalyticsUseCase(getIt<BrandPositioningRepository>()));

    // Project use cases
    getIt.registerSingleton(GetProjectUseCase(getIt<ProjectRepository>()));
    getIt.registerSingleton(ListProjectsUseCase(getIt<ProjectRepository>()));
    getIt.registerSingleton(CreateProjectUseCase(getIt<ProjectRepository>()));
    getIt.registerSingleton(UpdateProjectUseCase(getIt<ProjectRepository>()));
    getIt.registerSingleton(DeleteProjectUseCase(getIt<ProjectRepository>()));
    getIt.registerSingleton(SwitchProjectUseCase(getIt<ProjectRepository>()));
  }
}
```

---

## Complete File Checklist - Domain Layer

### Domain Entities (7 files)

- [ ] `lib/domain/entity/brand/brand.dart`
- [ ] `lib/domain/entity/knowledge_base/knowledge_base_entry.dart`
- [ ] `lib/domain/entity/link/link.dart`
- [ ] `lib/domain/entity/rewrite_rule/rewrite_rule.dart`
- [ ] `lib/domain/entity/llm_config/llm_config.dart`
- [ ] `lib/domain/entity/brand_positioning/brand_positioning.dart`
- [ ] `lib/domain/entity/project/project.dart`

### Repository Interfaces (7 files)

- [ ] `lib/domain/repository/brand/brand_repository.dart`
- [ ] `lib/domain/repository/knowledge_base/knowledge_base_repository.dart`
- [ ] `lib/domain/repository/link/link_repository.dart`
- [ ] `lib/domain/repository/rewrite_rule/rewrite_rule_repository.dart`
- [ ] `lib/domain/repository/llm_config/llm_config_repository.dart`
- [ ] `lib/domain/repository/brand_positioning/brand_positioning_repository.dart`
- [ ] `lib/domain/repository/project/project_repository.dart`

### Repository Implementations (7 files)

- [ ] `lib/data/repository/brand/brand_repository_impl.dart`
- [ ] `lib/data/repository/knowledge_base/knowledge_base_repository_impl.dart`
- [ ] `lib/data/repository/link/link_repository_impl.dart`
- [ ] `lib/data/repository/rewrite_rule/rewrite_rule_repository_impl.dart`
- [ ] `lib/data/repository/llm_config/llm_config_repository_impl.dart`
- [ ] `lib/data/repository/brand_positioning/brand_positioning_repository_impl.dart`
- [ ] `lib/data/repository/project/project_repository_impl.dart`

### Use Cases (25+ files)

See Step 4 for complete list. Each in `lib/domain/usecase/{feature}/{use_case}_usecase.dart`

### Files to Update

- [ ] `lib/data/di/module/repository_module.dart` - Add 7 repository registrations
- [ ] `lib/domain/di/module/use_case_module.dart` - Add 25+ use case registrations

---

## Notes

- All entities immutable with copyWith() for modifications
- All entities have from DTO converters
- Use cases extend `UseCase<T, P>` base class
- Repository implementations map DTOs → entities
- DI registration order: Data (APIs) → Repository → Use Cases
