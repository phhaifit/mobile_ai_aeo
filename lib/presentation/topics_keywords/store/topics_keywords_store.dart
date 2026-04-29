import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TopicKeywordItem {
  final String id;
  final String topic;
  final String alias;
  final String description;
  final int activePrompts;
  final DateTime createdAt;
  final bool isMonitoring;
  final bool isSelected;

  const TopicKeywordItem({
    required this.id,
    required this.topic,
    required this.alias,
    required this.description,
    required this.activePrompts,
    required this.createdAt,
    required this.isMonitoring,
    this.isSelected = false,
  });

  TopicKeywordItem copyWith({
    String? id,
    String? topic,
    String? alias,
    String? description,
    int? activePrompts,
    DateTime? createdAt,
    bool? isMonitoring,
    bool? isSelected,
  }) {
    return TopicKeywordItem(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      alias: alias ?? this.alias,
      description: description ?? this.description,
      activePrompts: activePrompts ?? this.activePrompts,
      createdAt: createdAt ?? this.createdAt,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class TopicsKeywordsStore extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  DateTimeRange? _dateRange;
  String? _selectedTopicFilter;
  bool _isLoading = false;
  bool _isDeletingTopics = false;
  String? _errorMessage;
  final Set<String> _deletingTopicIds = <String>{};

  List<TopicKeywordItem> _items = const [];

  TopicsKeywordsStore() {
    fetchTopics();
  }

  DateTimeRange? get dateRange => _dateRange;

  String? get selectedTopicFilter => _selectedTopicFilter;

  bool get isLoading => _isLoading;

  bool get isDeletingTopics => _isDeletingTopics;

  String? get errorMessage => _errorMessage;

  Set<String> get deletingTopicIds => Set.unmodifiable(_deletingTopicIds);

  List<String> get topicFilters {
    final filters = _items.map((item) => item.topic).toSet().toList(growable: false)
      ..sort();
    return ['All topics', ...filters];
  }
  Future<void> fetchTopics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final projectId = await _resolveProjectId();

      final response = await getIt<DioClient>().dio.get(
        '/api/projects/$projectId/topics',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final payload = response.data;
      if (payload is! List) {
        throw Exception('Invalid topics response payload');
      }

      _items = payload.whereType<Map>().map((raw) {
        final json = Map<String, dynamic>.from(raw);
        return TopicKeywordItem(
          id: (json['id'] ?? '').toString(),
          topic: (json['name'] ?? '').toString(),
          alias: (json['alias'] ?? '').toString(),
          description: (json['description'] ?? '').toString(),
          activePrompts: (json['active_prompt_count'] as num?)?.toInt() ??
              (json['promptCount'] as num?)?.toInt() ??
              0,
          createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
              DateTime.now(),
          isMonitoring: json['isMonitored'] == true,
        );
      }).toList(growable: false);

      if (_selectedTopicFilter != null &&
          _selectedTopicFilter != 'All topics' &&
          !_items.any((item) => item.topic == _selectedTopicFilter)) {
        _selectedTopicFilter = null;
      }
    } catch (_) {
      _errorMessage = 'Unable to load topics. Please try again.';
      _items = const [];
    } finally {
      _isLoading = false;
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


  List<TopicKeywordItem> get items => List.unmodifiable(_items);

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  int get selectedCount => _items.where((item) => item.isSelected).length;

  void setSearchQuery(String _) {
    notifyListeners();
  }

  void setTopicFilter(String? value) {
    _selectedTopicFilter = value;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void toggleSelectAll(bool selected) {
    _items = _items
        .map((item) => item.copyWith(isSelected: selected))
        .toList(growable: false);
    notifyListeners();
  }

  void toggleRowSelection(String id, bool selected) {
    _items = _items
        .map(
          (item) => item.id == id ? item.copyWith(isSelected: selected) : item,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void toggleMonitoring(String id, bool value) {
    _items = _items
        .map(
          (item) => item.id == id ? item.copyWith(isMonitoring: value) : item,
        )
        .toList(growable: false);
    notifyListeners();
  }

  Future<bool> deleteSelectedTopics() async {
    final ids = _items
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) {
      return true;
    }

    return deleteTopicsByIds(ids);
  }

  Future<bool> deleteTopicById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return false;
    }

    return deleteTopicsByIds([normalizedId]);
  }

  Future<bool> deleteTopicsByIds(List<String> ids) async {
    if (_isDeletingTopics) {
      return false;
    }

    final normalizedIds = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedIds.isEmpty) {
      return true;
    }

    _isDeletingTopics = true;
    _deletingTopicIds.addAll(normalizedIds);
    notifyListeners();

    try {
      await getIt<DioClient>().dio.delete(
        '/api/topics/delete-many',
        data: {'ids': normalizedIds},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      _items = _items
          .where((item) => !normalizedIds.contains(item.id.trim()))
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _deletingTopicIds.removeAll(normalizedIds);
      _isDeletingTopics = false;
      notifyListeners();
    }
  }

  Future<bool> addTopics(
    List<({String topic, String alias, String description})> topics,
  ) async {
    if (topics.isEmpty) {
      return true;
    }

    final payloadTopicData = topics
        .map(
          (topic) => {
            'name': topic.topic.trim(),
            'alias': topic.alias.trim(),
            'description': topic.description.trim(),
          },
        )
        .where((topic) => (topic['name'] ?? '').toString().isNotEmpty)
        .toList(growable: false);

    if (payloadTopicData.isEmpty) {
      return false;
    }

    try {
      final projectId = await _resolveProjectId();
      final response = await getIt<DioClient>().dio.post(
        '/api/topics',
        data: {
          'projectId': projectId,
          'topicData': payloadTopicData,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = response.data;
      if (payload is! List) {
        throw Exception('Invalid add topics response payload');
      }

      final newItems = payload.whereType<Map>().map((raw) {
        final json = Map<String, dynamic>.from(raw);
        return TopicKeywordItem(
          id: (json['id'] ?? '').toString(),
          topic: (json['name'] ?? '').toString(),
          alias: (json['alias'] ?? '').toString(),
          description: (json['description'] ?? '').toString(),
          activePrompts: (json['active_prompt_count'] as num?)?.toInt() ??
              (json['promptCount'] as num?)?.toInt() ??
              0,
          createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
              DateTime.now(),
          isMonitoring: json['isMonitored'] == true,
        );
      }).toList(growable: false);

      if (newItems.isEmpty) {
        return false;
      }

      _items = [...newItems, ..._items];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  List<TopicKeywordItem> get filteredItems {
    final query = searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final matchesSearch = query.isEmpty ||
          item.topic.toLowerCase().contains(query) ||
          item.alias.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);

      final matchesFilter = _selectedTopicFilter == null ||
          _selectedTopicFilter == 'All topics' ||
          item.topic == _selectedTopicFilter;

      final matchesDate = _dateRange == null ||
          (item.createdAt.isAfter(
                _dateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              item.createdAt.isBefore(
                _dateRange!.end.add(const Duration(days: 1)),
              ));

      return matchesSearch && matchesFilter && matchesDate;
    }).toList(growable: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
