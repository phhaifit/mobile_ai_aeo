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

  final List<String> _topicFilters = const [
    'All topics',
    'Higher Education in IT',
    'IT Career Readiness',
    'Specialized Research Fields',
    'University Comparison',
    'Brand Awareness',
  ];

  List<TopicKeywordItem> _items = [
    TopicKeywordItem(
      id: '1',
      topic: 'Higher Education in IT',
      alias: 'Higher Education in IT',
      description:
          'Exploration of top-tier academic institutions for pursuing undergraduate and graduate degrees in information technology.',
      activePrompts: 5,
      createdAt: DateTime(2026, 3, 17, 14, 22, 6),
      isMonitoring: true,
    ),
    TopicKeywordItem(
      id: '2',
      topic: 'IT Career Readiness',
      alias: 'IT Career Readiness',
      description:
          'Seeking educational paths that provide both theoretical knowledge and practical technical skills for real-world careers.',
      activePrompts: 5,
      createdAt: DateTime(2026, 3, 17, 14, 22, 6),
      isMonitoring: true,
    ),
    TopicKeywordItem(
      id: '3',
      topic: 'Specialized Research Fields',
      alias: 'Specialized Research Fields',
      description:
          'Discovery of academic hubs leading research in Artificial Intelligence, Machine Learning, and Big Data technologies.',
      activePrompts: 5,
      createdAt: DateTime(2026, 3, 17, 14, 22, 6),
      isMonitoring: true,
    ),
    TopicKeywordItem(
      id: '4',
      topic: 'University Comparison',
      alias: 'University Comparison',
      description:
          'Evaluating top universities in Southeast Asia for information technology and advanced software engineering programs.',
      activePrompts: 5,
      createdAt: DateTime(2026, 3, 17, 14, 22, 6),
      isMonitoring: true,
    ),
    TopicKeywordItem(
      id: '5',
      topic: 'Brand Awareness',
      alias: 'Brand Awareness',
      description:
          'Direct inquiries regarding the academic programs and research reputation of the Faculty of IT at leading institutions.',
      activePrompts: 5,
      createdAt: DateTime(2026, 3, 17, 14, 22, 6),
      isMonitoring: true,
    ),
  ];

  DateTimeRange? get dateRange => _dateRange;

  String? get selectedTopicFilter => _selectedTopicFilter;

  List<String> get topicFilters => _topicFilters;

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

  void deleteSelectedTopics() {
    _items = _items.where((item) => !item.isSelected).toList(growable: false);
    notifyListeners();
  }

  void deleteTopicById(String id) {
    _items = _items.where((item) => item.id != id).toList(growable: false);
    notifyListeners();
  }

  void addTopics(
    List<({String topic, String alias, String description})> topics,
  ) {
    if (topics.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final newItems = topics
        .asMap()
        .entries
        .map(
          (entry) => TopicKeywordItem(
            id: '${now.microsecondsSinceEpoch}_${entry.key}_${_items.length}',
            topic: entry.value.topic,
            alias: entry.value.alias,
            description: entry.value.description,
            activePrompts: 0,
            createdAt: now,
            isMonitoring: false,
          ),
        )
        .toList(growable: false);

    _items = [...newItems, ..._items];
    notifyListeners();
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
