import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_keyword.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/tabs/keyword_tab_screen.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/tabs/prompt_tab_screen.dart';
import 'package:flutter/material.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.topicName,
    this.topicId,
    this.titleOverride,
  });

  final String topicName;
  final String? topicId;
  final String? titleOverride;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late final TopicDetailStore _store;

  @override
  void initState() {
    super.initState();
    _store = TopicDetailStore(
      topicName: widget.topicName,
      topicId: widget.topicId,
    );
    _store.searchController.addListener(() {
      _store.onSearchChanged(_store.searchController.text);
    });
    _store.fetchKeywords();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101828),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          widget.titleOverride ?? 'Topics & Keywords > ${widget.topicName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Help',
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildTabBar(),
                const SizedBox(height: 10),
                Expanded(child: _buildTabContent()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _store.tabs.map((tab) {
          final isActive = tab == _store.selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabSelected(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF344054),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_store.selectedTab) {
      case TopicDetailTab.prompt:
        return _buildPromptApiState(
          child: PromptTabScreen(
            searchController: _store.searchController,
            prompts: _store.filteredPrompts,
            isDeletingPrompt: _store.isDeletingPrompt,
            monitoringCapacity: _store.monitoringCapacity,
            isMonitoringCapacityLoading: _store.isMonitoringCapacityLoading,
            monitoringCapacityError: _store.monitoringCapacityError,
            onOpenFilters: () => _showFilterBottomSheet(context),
            onOpenAddPrompt: () => _showAddPromptBottomSheet(context),
            onRefreshPrompt: (prompt) => _store.refreshPrompt(prompt.id),
            onDeletePrompt: _confirmDeletePrompt,
            onRetryMonitoring: _store.fetchMonitoringCapacity,
            formatCreatedDate: _formatCreatedDate,
          ),
        );
      case TopicDetailTab.keyword:
        return KeywordTabScreen(
          searchController: _store.searchController,
          apiKeywords: _store.keywords,
          isLoading: _store.isKeywordsLoading,
          errorMessage: _store.keywordsError,
          onRetry: _store.fetchKeywords,
          onAddKeywords: _store.addKeywords,
          onSuggestKeywords: _store.suggestKeywords,
          onDeleteKeyword: _store.deleteKeywordById,
        );
    }
  }

  Future<void> _onTabSelected(TopicDetailTab tab) async {
    _store.setTab(tab);
    if (tab == TopicDetailTab.keyword) {
      await _store.fetchKeywords();
    } else {
      await Future.wait([
        _store.fetchPromptsForTab(tab),
        _store.fetchMonitoringCapacity(),
      ]);
    }
  }

  Widget _buildPromptApiState({required Widget child}) {
    if (_store.isLoading && _store.filteredPrompts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store.errorMessage != null && _store.filteredPrompts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _store.errorMessage!,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _store.fetchPromptsForTab(_store.selectedTab),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return child;
  }

  Future<void> _showAddPromptBottomSheet(BuildContext context) async {
    if (_store.keywords.isEmpty) {
      // Show loading indicator or simply await since it is fast
      await _store.fetchKeywords();
    }

    final result = await showModalBottomSheet<_AddPromptResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddPromptBottomSheet(
          defaultTopic: widget.topicName,
          keywords: _store.keywords,
        );
      },
    );

    if (result == null) {
      return;
    }

    _store.addPrompt(
      question: result.prompt,
      promptType: result.promptType,
      selectedKeywordIds: result.keywords,
      topic: result.topic,
    );
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    var localPromptTypes = {..._store.selectedPromptTypes};
    var localMonitoring = _store.monitoringStatusFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      elevation: 12,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                localPromptTypes = {};
                                localMonitoring = MonitoringStatusFilter.all;
                              });
                            },
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Prompt Type',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _store.promptTypeFilters.map((type) {
                          final isChecked = localPromptTypes.contains(type);
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 48) / 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? const Color(0xFFF2F8FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CheckboxListTile(
                                value: isChecked,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  type.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF344054),
                                  ),
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      localPromptTypes.add(type);
                                    } else {
                                      localPromptTypes.remove(type);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(growable: false),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Monitoring Status',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._store.monitoringStatusFilters.map((status) {
                        final isSelected = localMonitoring == status;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF2F8FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            onTap: () {
                              setModalState(() {
                                localMonitoring = status;
                              });
                            },
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFF155EEF)
                                  : const Color(0xFF98A2B3),
                            ),
                            title: Text(
                              status.label,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _store.applyFilters(
                              promptTypes: localPromptTypes,
                              monitoringStatus: localMonitoring,
                            );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatCreatedDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour24 = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$month/$day/${value.year}, $hour12:$minute $period';
  }

  Future<void> _confirmDeletePrompt(PromptItem prompt) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 10,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Delete Prompt',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(Icons.close, color: Color(0xFF98A2B3)),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to delete this prompt from the current list?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF475467),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEAECF0)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF344054),
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A59),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      final success = await _store.deletePromptById(prompt.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt deleted successfully.'),
            backgroundColor: Color(0xFF067647),
          ),
        );
      }
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete prompt failed. Please retry.'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
      }
    }
  }
}

class _AddPromptBottomSheet extends StatefulWidget {
  const _AddPromptBottomSheet({
    required this.defaultTopic,
    this.keywords = const [],
  });

  final String defaultTopic;
  final List<TopicKeyword> keywords;

  @override
  State<_AddPromptBottomSheet> createState() => _AddPromptBottomSheetState();
}

class _AddPromptBottomSheetState extends State<_AddPromptBottomSheet> {
  final TextEditingController _promptController = TextEditingController();

  final List<String> _topics = const [
    'Higher Education in IT',
    'IT Career Readiness',
    'Specialized Research Fields',
    'University Comparison',
    'Brand Awareness',
  ];

  final List<_CategoryData> _categories = const [
    _CategoryData(
      title: 'Informational',
      badgeColor: Color(0xFF1D9BF0),
      description:
          "Users are seeking knowledge or learning about a topic: definitions, explanations, guides, tutorials, 'What is [brand]?', brand discovery.",
    ),
    _CategoryData(
      title: 'Commercial',
      badgeColor: Color(0xFFF59E0B),
      description:
          "Users are researching before making a purchase decision: product features, benefits, comparisons, reviews, 'best [product]', 'A vs B'.",
    ),
    _CategoryData(
      title: 'Transactional',
      badgeColor: Color(0xFF22C55E),
      description:
          "Users intend to take action or make a purchase: pricing, signup, demo request, trial, 'buy [product]', 'download', subscription.",
    ),
    _CategoryData(
      title: 'Navigational',
      badgeColor: Color(0xFFE11D48),
      description:
          'Users want to reach a specific brand or page: official website, login page, product page, dashboard, app access.',
    ),
  ];


  late String _selectedTopic;
  late String _selectedCategory;
  final Set<TopicKeyword> _selectedKeywords = {};

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.defaultTopic;
    _selectedCategory = _categories.first.title;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildPromptField(),
                        const SizedBox(height: 14),
                        _buildTopicDropdown(),
                        const SizedBox(height: 14),
                        _buildCategorySection(),
                        const SizedBox(height: 14),
                        _buildKeywordSection(),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEAECF0)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF344054),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Add Prompt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      _AddPromptResult(
        prompt: promptText,
        topic: _selectedTopic,
        promptType: _categoryToPromptType(_selectedCategory),
        keywords: _selectedKeywords.map((k) => k.id).toList(),
      ),
    );
  }

  PromptTypeFilter _categoryToPromptType(String categoryTitle) {
    switch (categoryTitle) {
      case 'Informational':
        return PromptTypeFilter.informational;
      case 'Commercial':
        return PromptTypeFilter.commercial;
      case 'Transactional':
        return PromptTypeFilter.transactional;
      case 'Navigational':
        return PromptTypeFilter.navigational;
      default:
        return PromptTypeFilter.informational;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Prompt',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D2939),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add a new prompt to your list for tracking and analysis.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Color(0xFF98A2B3)),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildPromptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prompt',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your prompt here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topic',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showTopicPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTopic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTopicPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Topic',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 8),
                ..._topics.map((topic) {
                  final isSelected = topic == _selectedTopic;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(topic),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF155EEF))
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(topic),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == _selectedTopic) {
      return;
    }

    setState(() {
      _selectedTopic = selected;
    });
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final isOneColumn = constraints.maxWidth < 560;
            final cardWidth = isOneColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - gap) / 2;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category.title;
                return SizedBox(
                  width: cardWidth,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.title;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF6A00)
                              : const Color(0xFFD0D5DD),
                          width: isSelected ? 1.5 : 1,
                        ),
                        color: isSelected
                            ? const Color(0xFFFFF8F3)
                            : const Color(0xFFFCFCFD),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: category.badgeColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  category.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Color(0xFFFF6A00),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            category.description,
                            style: const TextStyle(
                              color: Color(0xFF475467),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKeywordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keywords (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.keywords.map((keyword) {
            final isSelected = _selectedKeywords.contains(keyword);
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedKeywords.remove(keyword);
                  } else {
                    _selectedKeywords.add(keyword);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF155EEF)
                        : const Color(0xFFD0D5DD),
                  ),
                  color: isSelected
                      ? const Color(0xFFEFF4FF)
                      : const Color(0xFFF9FAFB),
                ),
                child: Text(
                  keyword.text,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF155EEF)
                        : const Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.title,
    required this.badgeColor,
    required this.description,
  });

  final String title;
  final Color badgeColor;
  final String description;
}

class _AddPromptResult {
  const _AddPromptResult({
    required this.prompt,
    required this.topic,
    required this.promptType,
    required this.keywords,
  });

  final String prompt;
  final String topic;
  final PromptTypeFilter promptType;
  final List<String> keywords;
}
