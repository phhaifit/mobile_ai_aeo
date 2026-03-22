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
          final rows = _store.filteredItems;
          return Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const tableMinWidth = 980.0;
                        final tableWidth = constraints.maxWidth < tableMinWidth
                            ? tableMinWidth
                            : constraints.maxWidth;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              children: [
                                _buildTableHeader(),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: rows.length,
                                    itemBuilder: (context, index) {
                                      final item = rows[index];
                                      return _buildDataRow(item);
                                    },
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      height: 1,
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _store.searchController,
            decoration: InputDecoration(
              hintText: 'Search topics...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: true,
              fillColor: Colors.white,
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
          Row(
            children: [
              Expanded(child: _buildTopicDropdown()),
              const SizedBox(width: 8),
              Expanded(child: _buildDateRangeButton(context)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _store.selectedCount == 0 ? null : () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB42318),
                    side: const BorderSide(color: Color(0xFFFDA29B)),
                    backgroundColor: const Color(0xFFFFF1F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Topics'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicDropdown() {
    return DropdownButtonFormField<String>(
      value: _store.selectedTopicFilter,
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

  Widget _buildTableHeader() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Center(
              child: Checkbox(
                value: _store.isAllSelected,
                onChanged: (value) {
                  _store.toggleSelectAll(value ?? false);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const Expanded(flex: 3, child: _HeaderText('TOPIC')),
          const Expanded(flex: 3, child: _HeaderText('ALIAS')),
          const Expanded(flex: 5, child: _HeaderText('DESCRIPTION')),
          const Expanded(flex: 3, child: _HeaderText('MONITORING STATUS')),
          const Expanded(flex: 2, child: _HeaderText('ACTIVE PROMPTS')),
          const Expanded(flex: 3, child: _HeaderText('CREATED AT')),
          const SizedBox(
              width: 56, child: Center(child: _HeaderText('ACTIONS'))),
        ],
      ),
    );
  }

  Widget _buildDataRow(TopicKeywordItem item) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Checkbox(
              value: item.isSelected,
              onChanged: (value) {
                _store.toggleRowSelection(item.id, value ?? false);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              child: Text(
                item.topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF155EEF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.alias,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Switch(
                value: item.isMonitoring,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF16A34A),
                onChanged: (value) {
                  _store.toggleMonitoring(item.id, value);
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.activePrompts}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(_formatDateTime(item.createdAt)),
          ),
          SizedBox(
            width: 56,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF155EEF)),
            ),
          ),
        ],
      ),
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

class _HeaderText extends StatelessWidget {
  final String value;

  const _HeaderText(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF667085),
        fontSize: 12,
      ),
    );
  }
}
