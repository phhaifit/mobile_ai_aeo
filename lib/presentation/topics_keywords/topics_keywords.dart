import 'package:boilerplate/presentation/topics_keywords/store/topics_keywords_store.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/topic_detail.dart';
import 'package:flutter/material.dart';

class Topic {
  final String name;
  final String alias;
  final String description;

  const Topic({
    required this.name,
    required this.alias,
    required this.description,
  });
}

class TopicsKeywordsScreen extends StatefulWidget {
  @override
  State<TopicsKeywordsScreen> createState() => _TopicsKeywordsScreenState();
}

class _TopicsKeywordsScreenState extends State<TopicsKeywordsScreen> {
  late final TopicsKeywordsStore _store;

  @override
  void initState() {
    super.initState();
    _store = TopicsKeywordsStore();
    _store.searchController.addListener(() {
      _store.setSearchQuery(_store.searchController.text);
    });
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Topics & Keywords'),
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final items = _store.filteredItems;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTopFilters(context),
                if (_store.isDeletingTopics)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: _store.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _store.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _store.errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF667085),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: _store.fetchTopics,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No topics found',
                                    style: TextStyle(color: Color(0xFF667085)),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: items.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildTopicCard(context, items[index]);
                                  },
                                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopFilters(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _store.searchController,
          decoration: InputDecoration(
            hintText: 'Search topics...',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 560;
            if (isSmall) {
              return Column(
                children: [
                  _buildTopicDropdown(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildDateRangeButton(context),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildTopicDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildDateRangeButton(context)),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 560;
            if (isSmall) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildDeleteButton(context),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildAddTopicButton(),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildDeleteButton(context)),
                const SizedBox(width: 8),
                Expanded(child: _buildAddTopicButton()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _store.selectedCount == 0 || _store.isDeletingTopics
          ? null
          : () => _showDeleteSelectedDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB42318),
        side: const BorderSide(color: Color(0xFFFDA29B)),
        backgroundColor: const Color(0xFFFFF1F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: _store.isDeletingTopics
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline),
      label: Text(_store.isDeletingTopics ? 'Deleting...' : 'Delete Topics'),
    );
  }

  Widget _buildAddTopicButton() {
    return ElevatedButton.icon(
      onPressed: _store.isDeletingTopics ? null : () => showAddTopicModal(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6A00),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add Topic'),
    );
  }

  Widget _buildTopicDropdown() {
    final selectedLabel = _store.selectedTopicFilter ?? 'Select topics';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _store.isDeletingTopics ? null : _showTopicFilterPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _store.selectedTopicFilter == null
                      ? const Color(0xFF667085)
                      : const Color(0xFF344054),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
          ],
        ),
      ),
    );
  }

  Future<void> _showTopicFilterPicker() async {
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
                  'Select topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 8),
                ..._store.topicFilters.map((topic) {
                  final isSelected = topic == _store.selectedTopicFilter;
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

    if (selected == null) {
      return;
    }

    _store.setTopicFilter(selected);
  }

  Widget _buildDateRangeButton(BuildContext context) {
    final label = _store.dateRange == null
        ? 'Pick a date range'
        : '${_formatDate(_store.dateRange!.start)} - ${_formatDate(_store.dateRange!.end)}';

    return OutlinedButton.icon(
      onPressed: _store.isDeletingTopics
          ? null
          : () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(now.year + 2),
          initialDateRange: _store.dateRange,
        );
        if (picked != null) {
          _store.setDateRange(picked);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF344054),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      icon: const Icon(Icons.date_range_outlined),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicKeywordItem item) {
    final isRowDeleting = _store.deletingTopicIds.contains(item.id);
    final isInteractionLocked = _store.isDeletingTopics;

    return Dismissible(
      key: ValueKey(item.id),
      direction: isInteractionLocked
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        if (_store.isDeletingTopics) {
          return false;
        }

        final shouldDelete = await _showDeleteSingleDialog(context);
        if (!shouldDelete) {
          return false;
        }

        final deleted = await _store.deleteTopicById(item.id);
        if (!context.mounted) {
          return false;
        }

        if (!deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to delete topic. Please try again.'),
            ),
          );
          return false;
        }

        return true;
      },
      onDismissed: (_) {},
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1.5,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isInteractionLocked
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicDetailScreen(
                  topicName: item.topic,
                  topicId: item.id,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: item.isSelected,
                          onChanged: isInteractionLocked
                              ? null
                              : (value) {
                                  _store.toggleRowSelection(item.id, value ?? false);
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF155EEF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: isInteractionLocked ? null : () {},
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF155EEF),
                          ),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        item.alias,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: item.isMonitoring
                                ? const Color(0xFFE9F8EE)
                                : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Switch(
                            value: item.isMonitoring,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF16A34A),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFF98A2B3),
                            onChanged: isInteractionLocked
                                ? null
                                : (value) {
                                    _store.toggleMonitoring(item.id, value);
                                  },
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${item.activePrompts} prompts',
                          style: const TextStyle(
                            color: Color(0xFF344054),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDateTime(item.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (isRowDeleting)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteSelectedDialog(BuildContext context) async {
    if (_store.isDeletingTopics) {
      return;
    }

    final selectedCount = _store.selectedCount;
    if (selectedCount == 0) {
      return;
    }

    final deleted = await _showDeleteDialog(
      context: context,
      message:
          'Are you sure you want to delete $selectedCount topic(s)? This action cannot be undone.',
    );

    if (deleted) {
      final success = await _store.deleteSelectedTopics();
      if (!context.mounted || success) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete selected topics. Please try again.'),
        ),
      );
    }
  }

  Future<bool> _showDeleteSingleDialog(BuildContext context) {
    return _showDeleteDialog(
      context: context,
      message:
          'Are you sure you want to delete 1 topic(s)? This action cannot be undone.',
    );
  }

  Future<bool> _showDeleteDialog({
    required BuildContext context,
    required String message,
  }) async {
    var isDeleted = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          elevation: 10,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Delete Topics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                        color: const Color(0xFF667085),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE4E7EC)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF344054),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          isDeleted = true;
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE04F16),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return isDeleted;
  }

  void showAddTopicModal(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final content = _AddTopicsModalContent(
      onCancel: () => Navigator.of(context).pop(),
      onSave: (topics) async {
        final success = await _store.addTopics(
          topics
              .map(
                (topic) => (
                  topic: topic.name,
                  alias: topic.alias,
                  description: topic.description,
                ),
              )
              .toList(growable: false),
        );

        if (!context.mounted) {
          return;
        }

        if (success) {
          Navigator.of(context).pop();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to add topics. Please try again.'),
          ),
        );
      },
    );

    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: content,
            ),
          );
        },
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 900,
            child: content,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour24 = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$month/$day/${date.year}, $hour12:$minute:$second $period';
  }
}

class _AddTopicsModalContent extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function(List<Topic>) onSave;

  const _AddTopicsModalContent({
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_AddTopicsModalContent> createState() => _AddTopicsModalContentState();
}

class _AddTopicsModalContentState extends State<_AddTopicsModalContent>
    with TickerProviderStateMixin {
  final List<_TopicEditingRow> _rows = [_TopicEditingRow()];

  bool _showValidationError = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_TopicEditingRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length == 1) {
      _rows.first.clear();
      return;
    }

    setState(() {
      final removed = _rows.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final topics = _rows.map((row) => row.toTopic()).where((topic) {
      return topic.name.isNotEmpty ||
          topic.alias.isNotEmpty ||
          topic.description.isNotEmpty;
    }).toList(growable: false);

    if (topics.isEmpty) {
      setState(() {
        _showValidationError = true;
      });
      return;
    }

    final hasInvalidTopicName =
        topics.any((topic) => topic.name.trim().isEmpty);
    if (hasInvalidTopicName) {
      setState(() {
        _showValidationError = true;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(topics);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Topics',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF98A2B3),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Organize your topics with custom names, aliases, and descriptions. Paste multiple topics separated by new lines or semicolons.',
              style: TextStyle(
                color: Color(0xFF475467),
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD0D5DD)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 840,
                    maxWidth: 840,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TopicTableHeader(),
                      const Divider(height: 1, color: Color(0xFFE4E7EC)),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: Column(
                          children: [
                            for (var i = 0; i < _rows.length; i++)
                              TopicRow(
                                key: ValueKey(_rows[i].id),
                                index: i + 1,
                                nameController: _rows[i].nameController,
                                aliasController: _rows[i].aliasController,
                                descriptionController:
                                    _rows[i].descriptionController,
                                onDelete: () => _removeRow(i),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE4E7EC)),
                      InkWell(
                        onTap: _addRow,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Color(0xFF98A2B3),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Click to add new topic...',
                                  style: TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Alias...',
                                  style: TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Description...',
                                  style: TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 56),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showValidationError) ...[
              const SizedBox(height: 10),
              const Text(
                'Each entered row must have a topic name before saving.',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE4E7EC)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF344054),
                    side: const BorderSide(color: Color(0xFFD0D5DD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Topics',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTableHeader extends StatelessWidget {
  const _TopicTableHeader();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF667085),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: labelStyle)),
          Expanded(flex: 3, child: Text('TOPIC NAME', style: labelStyle)),
          SizedBox(width: 12),
          Expanded(flex: 2, child: Text('ALIAS', style: labelStyle)),
          SizedBox(width: 12),
          Expanded(flex: 4, child: Text('DESCRIPTION', style: labelStyle)),
          SizedBox(width: 12),
          SizedBox(width: 44, child: Text('ACTIONS', style: labelStyle)),
        ],
      ),
    );
  }
}

class TopicRow extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController aliasController;
  final TextEditingController descriptionController;
  final VoidCallback onDelete;

  const TopicRow({
    super.key,
    required this.index,
    required this.nameController,
    required this.aliasController,
    required this.descriptionController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFF5D00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _RoundedInput(
              controller: nameController,
              hintText: 'Enter topic name',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _RoundedInput(
              controller: aliasController,
              hintText: 'Enter alias',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _RoundedInput(
              controller: descriptionController,
              hintText: 'Add a short description',
              minLines: 2,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: const Color(0xFFF04438),
              splashRadius: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;

  const _RoundedInput({
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF98A2B3)),
        ),
      ),
    );
  }
}

class _TopicEditingRow {
  final String id = UniqueKey().toString();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aliasController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Topic toTopic() {
    return Topic(
      name: nameController.text.trim(),
      alias: aliasController.text.trim(),
      description: descriptionController.text.trim(),
    );
  }

  void clear() {
    nameController.clear();
    aliasController.clear();
    descriptionController.clear();
  }

  void dispose() {
    nameController.dispose();
    aliasController.dispose();
    descriptionController.dispose();
  }
}
