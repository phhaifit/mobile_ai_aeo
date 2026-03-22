import 'package:boilerplate/presentation/topics_keywords/store/topics_keywords_store.dart';
import 'package:flutter/material.dart';

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
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
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
      onPressed: _store.selectedCount == 0
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
      icon: const Icon(Icons.delete_outline),
      label: const Text('Delete Topics'),
    );
  }

  Widget _buildAddTopicButton() {
    return ElevatedButton.icon(
      onPressed: () {},
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
    return DropdownButtonFormField<String>(
      value: _store.selectedTopicFilter,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
      ),
      hint: const Text('Select topics'),
      items: _store.topicFilters
          .map(
            (topic) => DropdownMenuItem<String>(
              value: topic,
              child: Text(topic, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: _store.setTopicFilter,
    );
  }

  Widget _buildDateRangeButton(BuildContext context) {
    final label = _store.dateRange == null
        ? 'Pick a date range'
        : '${_formatDate(_store.dateRange!.start)} - ${_formatDate(_store.dateRange!.end)}';

    return OutlinedButton.icon(
      onPressed: () async {
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
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
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
        return _showDeleteSingleDialog(context);
      },
      onDismissed: (_) {
        _store.deleteTopicById(item.id);
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1.5,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: item.isSelected,
                      onChanged: (value) {
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
                      onPressed: () {},
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
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF16A34A),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFF98A2B3),
                        onChanged: (value) {
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
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteSelectedDialog(BuildContext context) async {
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
      _store.deleteSelectedTopics();
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
