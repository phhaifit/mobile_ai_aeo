# Phase 2: API Integration Setup

## Objective

Set up network layer infrastructure: endpoint constants, DTOs, API classes, and DI registration for all brand setup features.

## Overview

| Component          | Count | Status  |
| ------------------ | ----- | ------- |
| New API Classes    | 7     | pending |
| DTO Classes        | 12+   | pending |
| Endpoint Constants | 30+   | pending |
| DI Registrations   | 7     | pending |

---

## Step 1: Update Endpoints Constants

**File:** `lib/data/network/constants/endpoints.dart`

**Add these endpoints:**

```dart
// ─── Brand Management endpoints ───────────────────────────────────────
static const String brandBase = "/api/v1/brands";
static String getBrand(String brandId) => "$brandBase/$brandId";
static String updateBrand(String brandId) => "$brandBase/$brandId";
static String deleteBrand(String brandId) => "$brandBase/$brandId";

// ─── Knowledge Base endpoints ─────────────────────────────────────────
static String knowledgeBaseByBrand(String brandId) =>
    "$brandBase/$brandId/knowledge-base";
static String knowledgeBaseEntry(String brandId, String entryId) =>
    "$brandBase/$brandId/knowledge-base/$entryId";
static String knowledgeBaseBulkDelete(String brandId) =>
    "$brandBase/$brandId/knowledge-base";

// ─── Links & Rewrite Rules endpoints ──────────────────────────────────
static String linksByBrand(String brandId) => "$brandBase/$brandId/links";
static String linkById(String brandId, String linkId) =>
    "$brandBase/$brandId/links/$linkId";
static String toggleLinkMonitor(String brandId, String linkId) =>
    "$brandBase/$brandId/links/$linkId/monitor";

static String rewriteRulesByBrand(String brandId) =>
    "$brandBase/$brandId/rewrite-rules";
static String rewriteRuleById(String brandId, String ruleId) =>
    "$brandBase/$brandId/rewrite-rules/$ruleId";

// ─── LLM Configuration endpoints ───────────────────────────────────────
static String llmConfigByBrand(String brandId) =>
    "$brandBase/$brandId/llm-config";
static String llmConfigEnable(String brandId, String llmId) =>
    "$brandBase/$brandId/llm-config/$llmId/enable";
static String llmConfigDisable(String brandId, String llmId) =>
    "$brandBase/$brandId/llm-config/$llmId/disable";
static String llmConfigFrequency(String brandId, String llmId) =>
    "$brandBase/$brandId/llm-config/$llmId/frequency";

// ─── Brand Positioning endpoints ──────────────────────────────────────
static String brandPositioningByBrand(String brandId) =>
    "$brandBase/$brandId/positioning";
static String brandPositioningAnalytics(String brandId) =>
    "$brandBase/$brandId/positioning/analytics";

// ─── Project Management endpoints ─────────────────────────────────────
static const String projectBase = "/api/v1/projects";
static String getProject(String projectId) => "$projectBase/$projectId";
static String updateProject(String projectId) => "$projectBase/$projectId";
static String deleteProject(String projectId) => "$projectBase/$projectId";
static String switchProject(String projectId) =>
    "$projectBase/$projectId/switch";
```

**TODO:** Insert after existing endpoint definitions, maintain alphabetical/logical grouping.

---

## Step 2: Create DTOs (Data Transfer Objects)

DTOs handle JSON serialization from API responses.

### 2.1 Brand DTOs

**File:** `lib/data/network/models/brand_dto.dart` (NEW)

```dart
import 'package:json_annotation/json_annotation.dart';

part 'brand_dto.g.dart';

@JsonSerializable()
class BrandDto {
  final String id;
  final String name;
  final String tagline;
  final String industry;
  final String website;

  @JsonKey(name: 'logoUrl')
  final String? logoUrl;

  final bool verified;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  BrandDto({
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

  factory BrandDto.fromJson(Map<String, dynamic> json) =>
      _$BrandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrandDtoToJson(this);
}
```

### 2.2 Knowledge Base Entry DTOs

**File:** `lib/data/network/models/knowledge_base_entry_dto.dart` (NEW)

```dart
@JsonSerializable()
class KnowledgeBaseEntryDto {
  final String id;
  final String title;
  final String type;
  final String content;
  final String? url;
  final String? category;
  final List<String>? tags;

  @JsonKey(name: 'isPublic')
  final bool isPublic;

  final String status;
  final String freshness;

  @JsonKey(name: 'sourceCount')
  final int sourceCount;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  KnowledgeBaseEntryDto({
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

  factory KnowledgeBaseEntryDto.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseEntryDtoToJson(this);
}
```

### 2.3 Link & Rewrite Rule DTOs

**File:** `lib/data/network/models/link_dto.dart` (NEW)

```dart
@JsonSerializable()
class LinkDto {
  final String id;
  final String url;
  final String label;
  final String type;
  final bool monitored;
  final int? priority;

  @JsonKey(name: 'lastChecked')
  final String? lastChecked;

  final String status;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  LinkDto({
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

  factory LinkDto.fromJson(Map<String, dynamic> json) =>
      _$LinkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LinkDtoToJson(this);
}
```

**File:** `lib/data/network/models/rewrite_rule_dto.dart` (NEW)

```dart
@JsonSerializable()
class RewriteRuleDto {
  final String id;
  final String pattern;
  final String target;
  final bool enabled;
  final int? priority;
  final String? testUrl;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  RewriteRuleDto({
    required this.id,
    required this.pattern,
    required this.target,
    required this.enabled,
    this.priority,
    this.testUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewriteRuleDto.fromJson(Map<String, dynamic> json) =>
      _$RewriteRuleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RewriteRuleDtoToJson(this);
}
```

### 2.4 LLM Configuration DTOs

**File:** `lib/data/network/models/llm_config_dto.dart` (NEW)

```dart
@JsonSerializable()
class LlmConfigDto {
  final String brandId;

  @JsonKey(name: 'llmConfigs')
  final List<LlmDetailDto> llmConfigs;

  @JsonKey(name: 'globalPollingEnabled')
  final bool globalPollingEnabled;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  LlmConfigDto({
    required this.brandId,
    required this.llmConfigs,
    required this.globalPollingEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LlmConfigDto.fromJson(Map<String, dynamic> json) =>
      _$LlmConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LlmConfigDtoToJson(this);
}

@JsonSerializable()
class LlmDetailDto {
  final String id;
  final String llmId;
  final String name;
  final bool enabled;
  final String tier;

  @JsonKey(name: 'pollingIntervalMinutes')
  final int pollingIntervalMinutes;

  @JsonKey(name: 'lastPolled')
  final String? lastPolled;

  @JsonKey(name: 'nextPollingSchedule')
  final String? nextPollingSchedule;

  final List<String>? keywords;
  final String status;

  LlmDetailDto({
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

  factory LlmDetailDto.fromJson(Map<String, dynamic> json) =>
      _$LlmDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LlmDetailDtoToJson(this);
}
```

### 2.5 Brand Positioning DTOs

**File:** `lib/data/network/models/brand_positioning_dto.dart` (NEW)

```dart
@JsonSerializable()
class BrandPositioningDto {
  final String id;
  final String brandId;

  @JsonKey(name: 'keyMessages')
  final List<String> keyMessages;

  @JsonKey(name: 'targetAudience')
  final String targetAudience;

  @JsonKey(name: 'uniqueValueProp')
  final String uniqueValueProp;

  final List<String> competitors;
  final List<String> differentiators;
  final double score;
  final List<String> recommendations;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  BrandPositioningDto({
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

  factory BrandPositioningDto.fromJson(Map<String, dynamic> json) =>
      _$BrandPositioningDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BrandPositioningDtoToJson(this);
}
```

### 2.6 Project DTOs

**File:** `lib/data/network/models/project_dto.dart` (NEW)

```dart
@JsonSerializable()
class ProjectDto {
  final String id;
  final String name;
  final String brandId;
  final String owner;
  final String stage;
  final String? focus;
  final String? description;

  @JsonKey(name: 'completionPercentage')
  final double completionPercentage;

  @JsonKey(name: 'isActive')
  final bool isActive;

  final List<String>? members;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  ProjectDto({
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

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}
```

**NOTE:** All DTOs require `@JsonSerializable()` annotation and need code generation:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Create API Classes

### 3.1 Brand API

**File:** `lib/data/network/apis/brand/brand_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/brand_dto.dart';

class BrandApi {
  final DioClient _dioClient;

  BrandApi(this._dioClient);

  Future<BrandDto> getBrand(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.getBrand(brandId),
    );
    return BrandDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BrandDto>> listBrands() async {
    final response = await _dioClient.dio.get(Endpoints.brandBase);
    final list = response.data is List ? response.data : [];
    return (list as List).map((e) => BrandDto.fromJson(e)).toList();
  }

  Future<BrandDto> createBrand({
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  }) async {
    final body = {
      'name': name,
      'tagline': tagline,
      'industry': industry,
      'website': website,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
    };
    final response = await _dioClient.dio.post(
      Endpoints.brandBase,
      data: body,
    );
    return BrandDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BrandDto> updateBrand({
    required String brandId,
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
    String? description,
  }) async {
    final body = {
      'name': name,
      'tagline': tagline,
      'industry': industry,
      'website': website,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.updateBrand(brandId),
      data: body,
    );
    return BrandDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBrand(String brandId) async {
    await _dioClient.dio.delete(Endpoints.deleteBrand(brandId));
  }
}
```

### 3.2 Knowledge Base API

**File:** `lib/data/network/apis/knowledge_base/knowledge_base_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/knowledge_base_entry_dto.dart';

class KnowledgeBaseApi {
  final DioClient _dioClient;

  KnowledgeBaseApi(this._dioClient);

  Future<List<KnowledgeBaseEntryDto>> listEntries(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.knowledgeBaseByBrand(brandId),
    );
    final list = response.data is List ? response.data : [];
    return (list as List)
        .map((e) => KnowledgeBaseEntryDto.fromJson(e))
        .toList();
  }

  Future<KnowledgeBaseEntryDto> getEntry(
      String brandId, String entryId) async {
    final response = await _dioClient.dio.get(
      Endpoints.knowledgeBaseEntry(brandId, entryId),
    );
    return KnowledgeBaseEntryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<KnowledgeBaseEntryDto> createEntry({
    required String brandId,
    required String title,
    required String type,
    required String content,
    String? url,
    String? category,
    List<String>? tags,
    bool isPublic = true,
  }) async {
    final body = {
      'title': title,
      'type': type,
      'content': content,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      'isPublic': isPublic,
    };
    final response = await _dioClient.dio.post(
      Endpoints.knowledgeBaseByBrand(brandId),
      data: body,
    );
    return KnowledgeBaseEntryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<KnowledgeBaseEntryDto> updateEntry({
    required String brandId,
    required String entryId,
    required String title,
    required String type,
    required String content,
    String? url,
    String? category,
    List<String>? tags,
    bool isPublic = true,
  }) async {
    final body = {
      'title': title,
      'type': type,
      'content': content,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      'isPublic': isPublic,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.knowledgeBaseEntry(brandId, entryId),
      data: body,
    );
    return KnowledgeBaseEntryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEntry(String brandId, String entryId) async {
    await _dioClient.dio.delete(
      Endpoints.knowledgeBaseEntry(brandId, entryId),
    );
  }

  Future<void> bulkDeleteEntries(String brandId, List<String> entryIds) async {
    await _dioClient.dio.delete(
      Endpoints.knowledgeBaseBulkDelete(brandId),
      data: {'ids': entryIds},
    );
  }
}
```

### 3.3 Link API

**File:** `lib/data/network/apis/link/link_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/link_dto.dart';

class LinkApi {
  final DioClient _dioClient;

  LinkApi(this._dioClient);

  Future<List<LinkDto>> listLinks(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.linksByBrand(brandId),
    );
    final list = response.data is List ? response.data : [];
    return (list as List).map((e) => LinkDto.fromJson(e)).toList();
  }

  Future<LinkDto> createLink({
    required String brandId,
    required String url,
    required String label,
    required String type,
    bool monitored = true,
    int? priority,
  }) async {
    final body = {
      'url': url,
      'label': label,
      'type': type,
      'monitored': monitored,
      if (priority != null) 'priority': priority,
    };
    final response = await _dioClient.dio.post(
      Endpoints.linksByBrand(brandId),
      data: body,
    );
    return LinkDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LinkDto> updateLink({
    required String brandId,
    required String linkId,
    required String url,
    required String label,
    required String type,
    bool monitored = true,
    int? priority,
  }) async {
    final body = {
      'url': url,
      'label': label,
      'type': type,
      'monitored': monitored,
      if (priority != null) 'priority': priority,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.linkById(brandId, linkId),
      data: body,
    );
    return LinkDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteLink(String brandId, String linkId) async {
    await _dioClient.dio.delete(Endpoints.linkById(brandId, linkId));
  }

  Future<void> toggleMonitor(
    String brandId,
    String linkId,
    bool monitored,
  ) async {
    await _dioClient.dio.patch(
      Endpoints.toggleLinkMonitor(brandId, linkId),
      data: {'monitored': monitored},
    );
  }
}
```

### 3.4 Rewrite Rule API

**File:** `lib/data/network/apis/rewrite_rule/rewrite_rule_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/rewrite_rule_dto.dart';

class RewriteRuleApi {
  final DioClient _dioClient;

  RewriteRuleApi(this._dioClient);

  Future<List<RewriteRuleDto>> listRules(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.rewriteRulesByBrand(brandId),
    );
    final list = response.data is List ? response.data : [];
    return (list as List).map((e) => RewriteRuleDto.fromJson(e)).toList();
  }

  Future<RewriteRuleDto> createRule({
    required String brandId,
    required String pattern,
    required String target,
    bool enabled = true,
    int? priority,
  }) async {
    final body = {
      'pattern': pattern,
      'target': target,
      'enabled': enabled,
      if (priority != null) 'priority': priority,
    };
    final response = await _dioClient.dio.post(
      Endpoints.rewriteRulesByBrand(brandId),
      data: body,
    );
    return RewriteRuleDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RewriteRuleDto> updateRule({
    required String brandId,
    required String ruleId,
    required String pattern,
    required String target,
    bool enabled = true,
    int? priority,
  }) async {
    final body = {
      'pattern': pattern,
      'target': target,
      'enabled': enabled,
      if (priority != null) 'priority': priority,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.rewriteRuleById(brandId, ruleId),
      data: body,
    );
    return RewriteRuleDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRule(String brandId, String ruleId) async {
    await _dioClient.dio.delete(Endpoints.rewriteRuleById(brandId, ruleId));
  }
}
```

### 3.5 LLM Config API

**File:** `lib/data/network/apis/llm_config/llm_config_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/llm_config_dto.dart';

class LlmConfigApi {
  final DioClient _dioClient;

  LlmConfigApi(this._dioClient);

  Future<LlmConfigDto> getConfig(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.llmConfigByBrand(brandId),
    );
    return LlmConfigDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LlmConfigDto> updateConfig({
    required String brandId,
    required List<LlmDetailRequest> llmConfigs,
    bool globalPollingEnabled = true,
  }) async {
    final body = {
      'llmConfigs': llmConfigs.map((e) => e.toMap()).toList(),
      'globalPollingEnabled': globalPollingEnabled,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.llmConfigByBrand(brandId),
      data: body,
    );
    return LlmConfigDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> enableLlm(String brandId, String llmId) async {
    await _dioClient.dio.patch(
      Endpoints.llmConfigEnable(brandId, llmId),
    );
  }

  Future<void> disableLlm(String brandId, String llmId) async {
    await _dioClient.dio.patch(
      Endpoints.llmConfigDisable(brandId, llmId),
    );
  }

  Future<void> updateFrequency({
    required String brandId,
    required String llmId,
    required int pollingIntervalMinutes,
  }) async {
    final body = {
      'pollingIntervalMinutes': pollingIntervalMinutes,
    };
    await _dioClient.dio.patch(
      Endpoints.llmConfigFrequency(brandId, llmId),
      data: body,
    );
  }
}

class LlmDetailRequest {
  final String llmId;
  final String name;
  final bool enabled;
  final String tier;
  final int pollingIntervalMinutes;
  final List<String>? keywords;

  LlmDetailRequest({
    required this.llmId,
    required this.name,
    required this.enabled,
    required this.tier,
    required this.pollingIntervalMinutes,
    this.keywords,
  });

  Map<String, dynamic> toMap() => {
    'llmId': llmId,
    'name': name,
    'enabled': enabled,
    'tier': tier,
    'pollingIntervalMinutes': pollingIntervalMinutes,
    if (keywords != null) 'keywords': keywords,
  };
}
```

### 3.6 Brand Positioning API

**File:** `lib/data/network/apis/brand_positioning/brand_positioning_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/brand_positioning_dto.dart';

class BrandPositioningApi {
  final DioClient _dioClient;

  BrandPositioningApi(this._dioClient);

  Future<BrandPositioningDto> getPositioning(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.brandPositioningByBrand(brandId),
    );
    return BrandPositioningDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BrandPositioningDto> updatePositioning({
    required String brandId,
    required List<String> keyMessages,
    required String targetAudience,
    required String uniqueValueProp,
    required List<String> competitors,
    required List<String> differentiators,
  }) async {
    final body = {
      'keyMessages': keyMessages,
      'targetAudience': targetAudience,
      'uniqueValueProp': uniqueValueProp,
      'competitors': competitors,
      'differentiators': differentiators,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.brandPositioningByBrand(brandId),
      data: body,
    );
    return BrandPositioningDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getAnalytics(String brandId) async {
    final response = await _dioClient.dio.get(
      Endpoints.brandPositioningAnalytics(brandId),
    );
    return response.data as Map<String, dynamic>;
  }
}
```

### 3.7 Project API

**File:** `lib/data/network/apis/project/project_api.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/models/project_dto.dart';

class ProjectApi {
  final DioClient _dioClient;

  ProjectApi(this._dioClient);

  Future<List<ProjectDto>> listProjects() async {
    final response = await _dioClient.dio.get(Endpoints.projectBase);
    final list = response.data is List ? response.data : [];
    return (list as List).map((e) => ProjectDto.fromJson(e)).toList();
  }

  Future<ProjectDto> getProject(String projectId) async {
    final response = await _dioClient.dio.get(
      Endpoints.getProject(projectId),
    );
    return ProjectDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectDto> createProject({
    required String name,
    required String brandId,
    required String owner,
    required String stage,
    String? focus,
    String? description,
  }) async {
    final body = {
      'name': name,
      'brandId': brandId,
      'owner': owner,
      'stage': stage,
      if (focus != null) 'focus': focus,
      if (description != null) 'description': description,
    };
    final response = await _dioClient.dio.post(
      Endpoints.projectBase,
      data: body,
    );
    return ProjectDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectDto> updateProject({
    required String projectId,
    required String name,
    required String brandId,
    required String owner,
    required String stage,
    String? focus,
    String? description,
  }) async {
    final body = {
      'name': name,
      'brandId': brandId,
      'owner': owner,
      'stage': stage,
      if (focus != null) 'focus': focus,
      if (description != null) 'description': description,
    };
    final response = await _dioClient.dio.patch(
      Endpoints.updateProject(projectId),
      data: body,
    );
    return ProjectDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProject(String projectId) async {
    await _dioClient.dio.delete(Endpoints.deleteProject(projectId));
  }

  Future<void> switchProject(String projectId) async {
    await _dioClient.dio.patch(Endpoints.switchProject(projectId));
  }
}
```

---

## Step 4: Update DI Registration

**File:** `lib/data/di/module/network_module.dart` (UPDATE)

Add these registrations after existing API registrations:

```dart
// ─── Brand Setup APIs (NEW) ──────────────────────────────────────────
getIt.registerSingleton(BrandApi(getIt<DioClient>()));
getIt.registerSingleton(KnowledgeBaseApi(getIt<DioClient>()));
getIt.registerSingleton(LinkApi(getIt<DioClient>()));
getIt.registerSingleton(RewriteRuleApi(getIt<DioClient>()));
getIt.registerSingleton(LlmConfigApi(getIt<DioClient>()));
getIt.registerSingleton(BrandPositioningApi(getIt<DioClient>()));
getIt.registerSingleton(ProjectApi(getIt<DioClient>()));
```

---

## Complete File Checklist

### DTOs to Create (12 files)

- [ ] `lib/data/network/models/brand_dto.dart`
- [ ] `lib/data/network/models/knowledge_base_entry_dto.dart`
- [ ] `lib/data/network/models/link_dto.dart`
- [ ] `lib/data/network/models/rewrite_rule_dto.dart`
- [ ] `lib/data/network/models/llm_config_dto.dart`
- [ ] `lib/data/network/models/llm_detail_dto.dart`
- [ ] `lib/data/network/models/brand_positioning_dto.dart`
- [ ] `lib/data/network/models/project_dto.dart`

### API Classes to Create (7 files)

- [ ] `lib/data/network/apis/brand/brand_api.dart`
- [ ] `lib/data/network/apis/knowledge_base/knowledge_base_api.dart`
- [ ] `lib/data/network/apis/link/link_api.dart`
- [ ] `lib/data/network/apis/rewrite_rule/rewrite_rule_api.dart`
- [ ] `lib/data/network/apis/llm_config/llm_config_api.dart`
- [ ] `lib/data/network/apis/brand_positioning/brand_positioning_api.dart`
- [ ] `lib/data/network/apis/project/project_api.dart`

### Files to Update

- [ ] `lib/data/network/constants/endpoints.dart` - Add 30+ endpoint constants
- [ ] `lib/data/di/module/network_module.dart` - Add 7 API registrations
- [ ] `pubspec.yaml` - Ensure json_annotation, build_runner are added

### After File Creation

```bash
# Generate JSON serialization code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verify compilation
flutter analyze
```

---

## Notes

- All DTOs must have `@JsonSerializable()` annotation
- All DTOs require `fromJson()` and `toJson()` methods (auto-generated)
- API classes follow existing patterns: inject DioClient, one method per API action
- Error handling delegated to DioClient interceptors
- All date/time strings in ISO 8601 format
