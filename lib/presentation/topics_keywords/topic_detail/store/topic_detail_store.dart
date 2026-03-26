import 'package:flutter/material.dart';

enum TopicDetailTab {
  active('Active'),
  suggestion('Suggestion'),
  keyword('Keyword'),
  inactive('Inactive');

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
  TopicDetailStore({required this.topicName});

  final String topicName;
  final TextEditingController searchController = TextEditingController();

  TopicDetailTab _selectedTab = TopicDetailTab.active;
  Set<PromptTypeFilter> _selectedPromptTypes = {};
  MonitoringStatusFilter _monitoringStatusFilter = MonitoringStatusFilter.all;

  final List<PromptItem> _prompts = [
    PromptItem(
      id: 'p1',
      question:
          'What are the best undergraduate computer science programs in Vietnam right now?',
      tab: TopicDetailTab.active,
      promptType: PromptTypeFilter.informational,
      isMonitored: true,
      keywords: [
        PromptKeyword(
          value: 'Informational',
          type: PromptKeywordType.informational,
        ),
        PromptKeyword(
          value: 'Higher Education in IT',
          type: PromptKeywordType.topicKeyword,
        ),
        PromptKeyword(
          value: 'best undergraduate computer science programs in Vietnam',
          type: PromptKeywordType.neutral,
        ),
      ],
      llm: 'AI Overviews',
      brandMentioned: '-',
      linkAppeared: '-',
      sentiment: '-',
      createdAt: DateTime(2026, 3, 17, 14, 26),
    ),
    PromptItem(
      id: 'p2',
      question:
          'How do I choose the best IT university in Vietnam to align with my career goals?',
      tab: TopicDetailTab.active,
      promptType: PromptTypeFilter.commercial,
      isMonitored: true,
      keywords: [
        PromptKeyword(value: 'Commercial', type: PromptKeywordType.commercial),
        PromptKeyword(
          value: 'Higher Education in IT',
          type: PromptKeywordType.topicKeyword,
        ),
        PromptKeyword(
          value: 'how to choose an IT university in Vietnam',
          type: PromptKeywordType.neutral,
        ),
      ],
      llm: 'AI Overviews',
      brandMentioned: '-',
      linkAppeared: '-',
      sentiment: '-',
      createdAt: DateTime(2026, 3, 17, 14, 26),
    ),
    PromptItem(
      id: 'p3',
      question:
          'What should I expect from a high-quality IT education program in terms of coursework and facilities?',
      tab: TopicDetailTab.active,
      promptType: PromptTypeFilter.transactional,
      isMonitored: false,
      keywords: [
        PromptKeyword(
          value: 'Transactional',
          type: PromptKeywordType.commercial,
        ),
        PromptKeyword(
          value: 'Higher Education in IT',
          type: PromptKeywordType.topicKeyword,
        ),
        PromptKeyword(
          value: 'what to expect from a high-quality IT education program',
          type: PromptKeywordType.neutral,
        ),
      ],
      llm: 'AI Overviews',
      brandMentioned: '-',
      linkAppeared: '-',
      sentiment: '-',
      createdAt: DateTime(2026, 3, 17, 14, 25),
    ),
    PromptItem(
      id: 'p4',
      question:
          'Could you outline the standard curriculum requirements for a Master of Science in Computer Science?',
      tab: TopicDetailTab.active,
      promptType: PromptTypeFilter.navigational,
      isMonitored: false,
      keywords: [
        PromptKeyword(
          value: 'Navigational',
          type: PromptKeywordType.neutral,
        ),
        PromptKeyword(
          value: 'Higher Education in IT',
          type: PromptKeywordType.topicKeyword,
        ),
        PromptKeyword(
          value: 'computer science curriculum requirements',
          type: PromptKeywordType.neutral,
        ),
      ],
      llm: 'AI Overviews',
      brandMentioned: '-',
      linkAppeared: '-',
      sentiment: '-',
      createdAt: DateTime(2026, 3, 17, 14, 25),
    ),
  ];

  TopicDetailTab get selectedTab => _selectedTab;

  Set<PromptTypeFilter> get selectedPromptTypes =>
      Set.unmodifiable(_selectedPromptTypes);

  MonitoringStatusFilter get monitoringStatusFilter => _monitoringStatusFilter;

  List<TopicDetailTab> get tabs => TopicDetailTab.values;

  List<PromptTypeFilter> get promptTypeFilters => PromptTypeFilter.values;

  List<MonitoringStatusFilter> get monitoringStatusFilters =>
      MonitoringStatusFilter.values;

  void setTab(TopicDetailTab tab) {
    _selectedTab = tab;
    notifyListeners();
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

  void addPrompt({
    required String question,
    required PromptTypeFilter promptType,
    required List<String> selectedKeywords,
    required String topic,
    bool switchToActiveTab = true,
  }) {
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    final keywords = <PromptKeyword>[
      PromptKeyword(
        value: promptType.label,
        type: _keywordTypeFromPromptType(promptType),
      ),
      PromptKeyword(
        value: topic,
        type: PromptKeywordType.topicKeyword,
      ),
      ...selectedKeywords.map(
        (keyword) => PromptKeyword(
          value: keyword,
          type: PromptKeywordType.neutral,
        ),
      ),
    ];

    _prompts.insert(
      0,
      PromptItem(
        id: id,
        question: question,
        tab: TopicDetailTab.active,
        deletedAt: null,
        promptType: promptType,
        isMonitored: true,
        keywords: keywords,
        llm: 'AI Overviews',
        brandMentioned: '-',
        linkAppeared: '-',
        sentiment: '-',
        createdAt: DateTime.now(),
      ),
    );

    if (switchToActiveTab) {
      _selectedTab = TopicDetailTab.active;
    }
    notifyListeners();
  }

  void movePromptToInactive(String id) {
    final promptIndex = _prompts.indexWhere((prompt) => prompt.id == id);
    if (promptIndex < 0) {
      return;
    }

    final prompt = _prompts[promptIndex];
    if (prompt.tab == TopicDetailTab.inactive) {
      return;
    }

    _prompts[promptIndex] = prompt.copyWith(
      tab: TopicDetailTab.inactive,
      deletedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void restorePrompt(String id) {
    final promptIndex = _prompts.indexWhere((prompt) => prompt.id == id);
    if (promptIndex < 0) {
      return;
    }

    final prompt = _prompts[promptIndex];
    if (prompt.tab != TopicDetailTab.inactive) {
      return;
    }

    _prompts[promptIndex] = prompt.copyWith(
      tab: TopicDetailTab.active,
      clearDeletedAt: true,
    );
    notifyListeners();
  }

  void deletePrompt(String id) {
    _prompts.removeWhere((prompt) => prompt.id == id);
    notifyListeners();
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

      return matchesTab &&
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
