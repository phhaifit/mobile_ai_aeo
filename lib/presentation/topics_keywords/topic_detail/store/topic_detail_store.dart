import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_keyword.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_suggestion.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MonitoringCapacity {
  final int monitoredCount;
  final int exhaustedCount;
  final int totalCount;
  final int limit;

  const MonitoringCapacity({
    required this.monitoredCount,
    required this.exhaustedCount,
    required this.totalCount,
    required this.limit,
  });
}

enum TopicDetailTab {
  keyword('Keyword'),
  prompt('Prompt');

  final String label;
  const TopicDetailTab(this.label);
}

enum PromptKeywordType {
  informational,
  commercial,
  topicKeyword,
  neutral,
}

enum PromptTypeFilter {
  informational('Informational'),
  commercial('Commercial'),
  transactional('Transactional'),
  navigational('Navigational');

  final String label;
  const PromptTypeFilter(this.label);
}

enum MonitoringStatusFilter {
  all('All'),
  monitored('Monitored'),
  notMonitored('Not Monitored');

  final String label;
  const MonitoringStatusFilter(this.label);
}

class PromptKeyword {
  final String value;
  final PromptKeywordType type;

  const PromptKeyword({
    required this.value,
    required this.type,
  });
}

class PromptItem {
  final String id;
  final String question;
  final TopicDetailTab tab;
  final DateTime? deletedAt;
  final PromptTypeFilter promptType;
  final bool isMonitored;
  final List<PromptKeyword> keywords;
  final String llm;
  final String brandMentioned;
  final String linkAppeared;
  final String sentiment;
  final DateTime createdAt;

  const PromptItem({
    required this.id,
    required this.question,
    required this.tab,
    this.deletedAt,
    required this.promptType,
    required this.isMonitored,
    required this.keywords,
    required this.llm,
    required this.brandMentioned,
    required this.linkAppeared,
    required this.sentiment,
    required this.createdAt,
  });

  PromptItem copyWith({
    String? id,
    String? question,
    TopicDetailTab? tab,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    PromptTypeFilter? promptType,
    bool? isMonitored,
    List<PromptKeyword>? keywords,
    String? llm,
    String? brandMentioned,
    String? linkAppeared,
    String? sentiment,
    DateTime? createdAt,
  }) {
    return PromptItem(
      id: id ?? this.id,
      question: question ?? this.question,
      tab: tab ?? this.tab,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      promptType: promptType ?? this.promptType,
      isMonitored: isMonitored ?? this.isMonitored,
      keywords: keywords ?? this.keywords,
      llm: llm ?? this.llm,
      brandMentioned: brandMentioned ?? this.brandMentioned,
      linkAppeared: linkAppeared ?? this.linkAppeared,
      sentiment: sentiment ?? this.sentiment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TopicDetailStore extends ChangeNotifier {
  TopicDetailStore({
    required this.topicName,
    this.topicId,
  });

  final String topicName;
  final String? topicId;
  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // ── Suggestion state ──────────────────────────────────────────────────────
  bool _isSuggestionsLoading = false;
  String? _suggestionsError;
  List<TopicSuggestion> _suggestions = [];
  int _suggestionsPage = 1;
  int _suggestionsTotalPages = 1;
  bool _isSuggestingMore = false;
  SuggestionType? _selectedSuggestionIntent; // null = All

  bool get isSuggestionsLoading => _isSuggestionsLoading;
  String? get suggestionsError => _suggestionsError;
  bool get isSuggestingMore => _isSuggestingMore;
  bool get hasMoreSuggestions => _suggestionsPage < _suggestionsTotalPages;
  SuggestionType? get selectedSuggestionIntent => _selectedSuggestionIntent;

  /// All intent types that actually appear in the loaded suggestions.
  List<SuggestionType> get availableSuggestionIntents {
    final seen = <SuggestionType>{};
    final result = <SuggestionType>[];
    for (final s in _suggestions) {
      if (seen.add(s.type)) result.add(s.type);
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  /// Suggestions after intent filter applied.
  List<TopicSuggestion> get filteredSuggestions {
    if (_selectedSuggestionIntent == null) return List.unmodifiable(_suggestions);
    return _suggestions
        .where((s) => s.type == _selectedSuggestionIntent)
        .toList(growable: false);
  }

  void setSuggestionIntentFilter(SuggestionType? intent) {
    _selectedSuggestionIntent = intent;
    notifyListeners();
  }

  TopicDetailTab _selectedTab = TopicDetailTab.keyword;
  Set<PromptTypeFilter> _selectedPromptTypes = {};
  MonitoringStatusFilter _monitoringStatusFilter = MonitoringStatusFilter.all;

  final List<PromptItem> _prompts = [];
  final Set<String> _deletingPromptIds = <String>{};

  bool _isMonitoringCapacityLoading = false;
  String? _monitoringCapacityError;
  MonitoringCapacity? _monitoringCapacity;

  TopicDetailTab get selectedTab => _selectedTab;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Set<PromptTypeFilter> get selectedPromptTypes =>
      Set.unmodifiable(_selectedPromptTypes);

  MonitoringStatusFilter get monitoringStatusFilter => _monitoringStatusFilter;

  List<TopicDetailTab> get tabs => TopicDetailTab.values;

  List<PromptTypeFilter> get promptTypeFilters => PromptTypeFilter.values;

  List<MonitoringStatusFilter> get monitoringStatusFilters =>
      MonitoringStatusFilter.values;

  bool get isDeletingPrompt => _deletingPromptIds.isNotEmpty;

  bool get isMonitoringCapacityLoading => _isMonitoringCapacityLoading;

  String? get monitoringCapacityError => _monitoringCapacityError;

  MonitoringCapacity? get monitoringCapacity => _monitoringCapacity;

  // ── Keyword state ─────────────────────────────────────────────────────────
  bool _isKeywordsLoading = false;
  String? _keywordsError;
  List<TopicKeyword> _keywords = [];

  bool get isKeywordsLoading => _isKeywordsLoading;
  String? get keywordsError => _keywordsError;
  /// Raw keyword objects fetched from the API.
  List<TopicKeyword> get keywords => List.unmodifiable(_keywords);

  Future<void> fetchKeywords() async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) {
      _keywordsError = 'Missing topic id.';
      notifyListeners();
      return;
    }

    _isKeywordsLoading = true;
    _keywordsError = null;
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.get(
        '/api/topics/$id/keywords',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final data = response.data;
      if (data is! List) throw Exception('Invalid keywords response');

      _keywords = data
          .whereType<Map>()
          .map((item) => TopicKeyword.fromJson(Map<String, dynamic>.from(item)))
          .where((kw) => kw.text.isNotEmpty && kw.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      _keywordsError = 'Unable to load keywords. Please try again.';
    } finally {
      _isKeywordsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteKeywordById(String keywordId) async {
    final normalizedId = keywordId.trim();
    if (normalizedId.isEmpty) {
      return false;
    }

    try {
      final response = await getIt<DioClient>().dio.delete(
        '/api/keywords/$normalizedId',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is Map && payload['success'] == false) {
        return false;
      }

      _keywords = _keywords
          .where((keyword) => keyword.id != normalizedId)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addKeywords(List<String> keywords) async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) {
      return false;
    }

    final normalizedKeywords = keywords
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedKeywords.isEmpty) {
      return false;
    }

    try {
      final response = await getIt<DioClient>().dio.post(
        '/api/topics/$id/keywords',
        data: {'keywords': normalizedKeywords},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is! List) {
        throw Exception('Invalid add keywords response');
      }

      final addedKeywords = payload
          .whereType<Map>()
          .map((item) => TopicKeyword.fromJson(Map<String, dynamic>.from(item)))
          .where((kw) => kw.text.isNotEmpty && kw.id.isNotEmpty)
          .toList(growable: false);

      if (addedKeywords.isEmpty) {
        return false;
      }

      final existingIds = _keywords.map((keyword) => keyword.id).toSet();
      final uniqueAddedKeywords = addedKeywords
          .where((keyword) => !existingIds.contains(keyword.id))
          .toList(growable: false);

      if (uniqueAddedKeywords.isNotEmpty) {
        _keywords = [...uniqueAddedKeywords, ..._keywords];
        notifyListeners();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> suggestKeywords(List<String> keywords) async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) {
      return const [];
    }

    final normalizedKeywords = keywords
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final projectId = await _resolveProjectId();

    final response = await getIt<DioClient>().dio.post(
      '/api/keywords/suggest',
      data: {
        'projectId': projectId,
        'topicId': id,
        'keywords': normalizedKeywords,
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final payload = response.data;
    final rawSuggestions = payload is List
        ? payload
        : (payload is Map ? payload['data'] : null);

    if (rawSuggestions is! List) {
      throw Exception('Invalid suggest keywords response');
    }

    return rawSuggestions
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          return (json['keyword'] ?? '').toString().trim();
        })
        .where((keyword) => keyword.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  void setTab(TopicDetailTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // ── Suggestion API methods ─────────────────────────────────────────────────

  Future<void> fetchSuggestions({bool reset = true}) async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) {
      _suggestionsError = 'Missing topic id. Unable to load suggestions.';
      notifyListeners();
      return;
    }

    if (reset) {
      _suggestionsPage = 1;
      _suggestionsTotalPages = 1;
      _suggestions = [];
      _selectedSuggestionIntent = null;
    }

    _isSuggestionsLoading = true;
    _suggestionsError = null;
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.get(
        '/api/prompts/by-topic',
        queryParameters: {
          'topicId': id,
          'status': 'suggested',
          'page': _suggestionsPage,
          'pageSize': 10,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is! Map) throw Exception('Invalid suggestions response');

      final data = payload['data'];
      if (data is! List) throw Exception('Invalid suggestions list');

      _suggestionsTotalPages = (payload['totalPages'] as int?) ?? 1;

      final fetched = data
          .whereType<Map>()
          .map((raw) =>
              TopicSuggestion.fromJson(Map<String, dynamic>.from(raw)))
          .toList(growable: false);

      if (reset) {
        _suggestions = fetched;
      } else {
        _suggestions = [..._suggestions, ...fetched];
      }
    } catch (_) {
      _suggestionsError = 'Unable to load suggestions. Please try again.';
    } finally {
      _isSuggestionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSuggestions() async {
    if (!hasMoreSuggestions || _isSuggestionsLoading) return;
    _suggestionsPage++;
    await fetchSuggestions(reset: false);
  }

  Future<void> suggestMoreFromApi() async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) return;

    _isSuggestingMore = true;
    notifyListeners();

    try {
      // Trigger server-side suggestion generation, then refresh
      await getIt<DioClient>().dio.post(
        '/api/prompts/suggest',
        data: {'topicId': id},
        options: Options(headers: {'Accept': 'application/json'}),
      );
    } catch (_) {
      // Ignore error – server may return 200/202 without body
    } finally {
      _isSuggestingMore = false;
    }

    await fetchSuggestions();
  }

  void rejectSuggestion(String id) {
    _suggestions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void trackSuggestion(TopicSuggestion suggestion) {
    final promptType = _promptTypeFromApi(suggestion.type.name);
    final mappedKeywordIds = _keywords
        .where((k) => suggestion.keywords.contains(k.text))
        .map((k) => k.id)
        .toList();

    addPrompt(
      question: suggestion.title,
      promptType: promptType,
      selectedKeywordIds: mappedKeywordIds,
      topic: suggestion.topicName.isNotEmpty ? suggestion.topicName : topicName,
      switchToActiveTab: false,
    );
    _suggestions.removeWhere((s) => s.id == suggestion.id);
    notifyListeners();
  }

  void updateSuggestion(TopicSuggestion suggestion) {
    final index = _suggestions.indexWhere((s) => s.id == suggestion.id);
    if (index >= 0) {
      _suggestions[index] = suggestion;
      notifyListeners();
    }
  }

  // ── Prompt API methods ─────────────────────────────────────────────────────

  Future<void> fetchPromptsForTab(TopicDetailTab tab) async {
    if (tab != TopicDetailTab.prompt) {
      return;
    }

    final id = topicId?.trim();
    if (id == null || id.isEmpty) {
      _errorMessage = 'Missing topic id. Unable to load prompts.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.get(
        '/api/prompts/by-topic',
        queryParameters: {
          'topicId': id,
          'status': 'active',
          'page': 1,
          'pageSize': 10,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final payload = response.data;
      if (payload is! Map) {
        throw Exception('Invalid prompts response payload');
      }

      final data = payload['data'];
      if (data is! List) {
        throw Exception('Invalid prompts list');
      }

      final mappedPrompts = data.whereType<Map>().map((raw) {
        final json = Map<String, dynamic>.from(raw);
        return _mapPromptFromApi(json: json, tab: tab);
      }).toList(growable: false);

      _prompts.removeWhere((prompt) => prompt.tab == tab);
      _prompts.insertAll(0, mappedPrompts);
    } catch (_) {
      _errorMessage = 'Unable to load prompts. Please try again.';
      _prompts.removeWhere((prompt) => prompt.tab == tab);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonitoringCapacity() async {
    final projectId = await _resolveProjectId();

    _isMonitoringCapacityLoading = true;
    _monitoringCapacityError = null;
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.get(
        '/api/prompts/monitoring-capacity',
        queryParameters: {'projectId': projectId},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is! Map) {
        throw Exception('Invalid monitoring capacity response payload');
      }

      final data = Map<String, dynamic>.from(payload);
      _monitoringCapacity = MonitoringCapacity(
        monitoredCount: (data['monitoredCount'] as num?)?.toInt() ?? 0,
        exhaustedCount: (data['exhaustedCount'] as num?)?.toInt() ?? 0,
        totalCount: (data['totalCount'] as num?)?.toInt() ?? 0,
        limit: (data['limit'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      _monitoringCapacityError =
          'Unable to load monitoring capacity. Please retry.';
      _monitoringCapacity = null;
    } finally {
      _isMonitoringCapacityLoading = false;
      notifyListeners();
    }
  }

  Future<String> _resolveProjectId() async {
    final preferenceHelper = getIt<SharedPreferenceHelper>();
    final savedProjectId = (await preferenceHelper.currentProjectId)?.trim();
    if (savedProjectId != null && savedProjectId.isNotEmpty) {
      return savedProjectId;
    }

    final projectId = await _fetchProjectIdFromBackend();
    if (projectId == null || projectId.isEmpty) {
      throw Exception('No accessible project found for current user.');
    }

    await preferenceHelper.saveCurrentProjectId(projectId);
    return projectId;
  }

  Future<String?> _fetchProjectIdFromBackend() async {
    final dio = getIt<DioClient>().dio;

    final activeProjectsResponse = await dio.get(
      '/api/projects',
      queryParameters: {'status': 'ACTIVE'},
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final activeProjectId = _extractFirstProjectId(activeProjectsResponse.data);
    if (activeProjectId != null) {
      return activeProjectId;
    }

    final meProjectsResponse = await dio.get(
      '/api/projects/me',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final meProjectId = _extractFirstProjectId(meProjectsResponse.data);
    if (meProjectId != null) {
      return meProjectId;
    }

    final allProjectsResponse = await dio.get(
      '/api/projects',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return _extractFirstProjectId(allProjectsResponse.data);
  }

  String? _extractFirstProjectId(dynamic payload) {
    if (payload is! List) {
      return null;
    }

    for (final raw in payload.whereType<Map>()) {
      final json = Map<String, dynamic>.from(raw);
      final id = (json['id'] ?? '').toString().trim();
      if (id.isNotEmpty) {
        return id;
      }
    }

    return null;
  }

  void onSearchChanged(String _) {
    notifyListeners();
  }

  void applyFilters({
    required Set<PromptTypeFilter> promptTypes,
    required MonitoringStatusFilter monitoringStatus,
  }) {
    _selectedPromptTypes = {...promptTypes};
    _monitoringStatusFilter = monitoringStatus;
    notifyListeners();
  }

  void clearFilters() {
    _selectedPromptTypes = {};
    _monitoringStatusFilter = MonitoringStatusFilter.all;
    notifyListeners();
  }

  Future<void> addPrompt({
    required String question,
    required PromptTypeFilter promptType,
    required List<String> selectedKeywordIds,
    required String topic,
    bool switchToActiveTab = true,
  }) async {
    final id = topicId?.trim();
    if (id == null || id.isEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.post(
        '/api/prompts/single',
        data: {
          'topicId': id,
          'content': question,
          'type': promptType.label,
          'keywordIds': selectedKeywordIds,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      final payload = response.data;
      if (payload is! Map) {
        throw Exception('Invalid add prompt response');
      }

      final json = Map<String, dynamic>.from(payload);
      final newPrompt = _mapPromptFromApi(
        json: json,
        tab: TopicDetailTab.prompt,
      );
      _prompts.insert(0, newPrompt);
      if (switchToActiveTab) {
        _selectedTab = TopicDetailTab.prompt;
      }
    } catch (_) {
      _errorMessage = 'Unable to add prompt. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void movePromptToInactive(String id) {
    deletePrompt(id);
  }

  void restorePrompt(String id) {
    return;
  }

  void deletePrompt(String id) {
    _prompts.removeWhere((prompt) => prompt.id == id);
    notifyListeners();
  }

  Future<bool> deletePromptById(String promptId) async {
    final normalizedId = promptId.trim();
    if (normalizedId.isEmpty) {
      return false;
    }

    _deletingPromptIds.add(normalizedId);
    notifyListeners();

    try {
      final response = await getIt<DioClient>().dio.delete(
        '/api/prompts/$normalizedId',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is Map && payload['success'] == false) {
        _deletingPromptIds.remove(normalizedId);
        notifyListeners();
        return false;
      }

      _prompts.removeWhere((prompt) => prompt.id == normalizedId);
      _deletingPromptIds.remove(normalizedId);
      notifyListeners();
      return true;
    } catch (_) {
      _deletingPromptIds.remove(normalizedId);
      notifyListeners();
      return false;
    }
  }

  void refreshPrompt(String id) {
    final promptIndex = _prompts.indexWhere((prompt) => prompt.id == id);
    if (promptIndex < 0) {
      return;
    }

    final prompt = _prompts[promptIndex];
    _prompts[promptIndex] = prompt.copyWith(createdAt: DateTime.now());
    notifyListeners();
  }

  PromptItem _mapPromptFromApi({
    required Map<String, dynamic> json,
    required TopicDetailTab tab,
  }) {
    final latestResults = (json['latestResults'] as List?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    final llm = latestResults.isNotEmpty
        ? (latestResults.first['model'] ?? '-').toString()
        : '-';

    final hasMentioned = latestResults.any((item) => item['isMentioned'] == true);
    final hasCited = latestResults.any((item) => item['isCited'] == true);

    final sentimentValue = latestResults
        .map((item) => (item['sentiment'] ?? '').toString().trim())
        .firstWhere((item) => item.isNotEmpty, orElse: () => '-');

    final tagKeywords = (json['keywords'] as List?)
            ?.whereType<String>()
            .map(
              (keyword) => PromptKeyword(
                value: keyword,
                type: PromptKeywordType.neutral,
              ),
            )
            .toList(growable: false) ??
        const <PromptKeyword>[];

    final promptType = _promptTypeFromApi((json['type'] ?? '').toString());

    return PromptItem(
      id: (json['id'] ?? '').toString(),
      question: (json['content'] ?? '').toString(),
      tab: TopicDetailTab.prompt,
      deletedAt: null,
      promptType: promptType,
      isMonitored: json['isMonitored'] == true,
      keywords: [
        PromptKeyword(
          value: promptType.label,
          type: _keywordTypeFromPromptType(promptType),
        ),
        PromptKeyword(
          value: topicName,
          type: PromptKeywordType.topicKeyword,
        ),
        ...tagKeywords,
      ],
      llm: llm,
      brandMentioned: hasMentioned ? 'Yes' : 'No',
      linkAppeared: hasCited ? 'Yes' : 'No',
      sentiment: sentimentValue,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  PromptTypeFilter _promptTypeFromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'informational':
        return PromptTypeFilter.informational;
      case 'commercial':
        return PromptTypeFilter.commercial;
      case 'transactional':
        return PromptTypeFilter.transactional;
      case 'navigational':
        return PromptTypeFilter.navigational;
      default:
        return PromptTypeFilter.informational;
    }
  }

  PromptKeywordType _keywordTypeFromPromptType(PromptTypeFilter type) {
    switch (type) {
      case PromptTypeFilter.informational:
        return PromptKeywordType.informational;
      case PromptTypeFilter.commercial:
        return PromptKeywordType.commercial;
      case PromptTypeFilter.transactional:
        return PromptKeywordType.commercial;
      case PromptTypeFilter.navigational:
        return PromptKeywordType.neutral;
    }
  }

  List<PromptItem> get filteredPrompts {
    final query = searchController.text.trim().toLowerCase();

    return _prompts.where((prompt) {
      final matchesTab = prompt.tab == _selectedTab;
      final isDeleting = _deletingPromptIds.contains(prompt.id);
      final matchesSearch = query.isEmpty ||
          prompt.question.toLowerCase().contains(query) ||
          prompt.keywords
              .any((keyword) => keyword.value.toLowerCase().contains(query));
      final matchesPromptType = _selectedPromptTypes.isEmpty ||
          _selectedPromptTypes.contains(prompt.promptType);
      final matchesMonitoring =
          _monitoringStatusFilter == MonitoringStatusFilter.all ||
              (_monitoringStatusFilter == MonitoringStatusFilter.monitored &&
                  prompt.isMonitored) ||
              (_monitoringStatusFilter == MonitoringStatusFilter.notMonitored &&
                  !prompt.isMonitored);

        return !isDeleting &&
          matchesTab &&
          matchesSearch &&
          matchesPromptType &&
          matchesMonitoring;
    }).toList(growable: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
