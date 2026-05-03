import 'package:boilerplate/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart';
import 'package:flutter/material.dart';

class PromptTabScreen extends StatelessWidget {
  const PromptTabScreen({
    super.key,
    required this.searchController,
    required this.prompts,
    required this.isDeletingPrompt,
    required this.monitoringCapacity,
    required this.isMonitoringCapacityLoading,
    required this.monitoringCapacityError,
    required this.onOpenFilters,
    required this.onOpenAddPrompt,
    required this.onRefreshPrompt,
    required this.onDeletePrompt,
    required this.onRetryMonitoring,
    required this.formatCreatedDate,
  });

  final TextEditingController searchController;
  final List<PromptItem> prompts;
  final bool isDeletingPrompt;
  final MonitoringCapacity? monitoringCapacity;
  final bool isMonitoringCapacityLoading;
  final String? monitoringCapacityError;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenAddPrompt;
  final ValueChanged<PromptItem> onRefreshPrompt;
  final ValueChanged<PromptItem> onDeletePrompt;
  final VoidCallback onRetryMonitoring;
  final String Function(DateTime) formatCreatedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchAndFilterBar(
          searchController: searchController,
          onOpenFilters: onOpenFilters,
          onOpenAddPrompt: onOpenAddPrompt,
        ),
        const SizedBox(height: 12),
        _MonitoringCapacitySection(
          capacity: monitoringCapacity,
          isLoading: isMonitoringCapacityLoading,
          errorMessage: monitoringCapacityError,
          onRetry: onRetryMonitoring,
        ),
        if (isDeletingPrompt) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(
            minHeight: 3,
            color: Color(0xFFFF6A00),
            backgroundColor: Color(0xFFEAECF0),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: prompts.isEmpty
              ? const Center(
                  child: Text(
                    'No prompts found',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                )
              : ListView.separated(
                  itemCount: prompts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final prompt = prompts[index];
                    return _PromptCard(
                      prompt: prompt,
                      onRefresh: () => onRefreshPrompt(prompt),
                      onDelete: () => onDeletePrompt(prompt),
                      formatCreatedDate: formatCreatedDate,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.searchController,
    required this.onOpenFilters,
    required this.onOpenAddPrompt,
  });

  final TextEditingController searchController;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenAddPrompt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search prompts...',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onOpenFilters,
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF344054),
                side: const BorderSide(color: Color(0xFFD0D5DD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onOpenAddPrompt,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Prompt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonitoringCapacitySection extends StatelessWidget {
  const _MonitoringCapacitySection({
    required this.capacity,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final MonitoringCapacity? capacity;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && capacity == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (errorMessage != null && capacity == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB42318), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final data = capacity;
    if (data == null) {
      return const SizedBox.shrink();
    }

    final trackingPercent = data.limit > 0
        ? (data.monitoredCount / data.limit).clamp(0, 1).toDouble()
        : 0.0;
    final availableCount =
      (data.totalCount - data.exhaustedCount).clamp(0, data.totalCount);
    final canWritePercent = data.totalCount > 0
      ? (availableCount / data.totalCount).clamp(0, 1).toDouble()
        : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CapacityCounter(
                  title: 'Monitoring',
                  value: '${data.monitoredCount} / ${data.limit}',
                  valueColor: const Color(0xFFB54708),
                ),
              ),
              Container(width: 1, height: 74, color: const Color(0xFFEAECF0)),
              Expanded(
                child: _CapacityCounter(
                  title: 'Can write blog',
                  value: '$availableCount / ${data.totalCount}',
                  valueColor: const Color(0xFF067647),
                ),
              ),
            ],
          ),
          Container(height: 1, color: const Color(0xFFEAECF0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                _CapacityProgressRow(
                  dotColor: const Color(0xFFFF6A00),
                  label: 'Tracking',
                  ratioLabel:
                      '${data.monitoredCount} / ${data.limit} - ${(trackingPercent * 100).toStringAsFixed(0)}%',
                  value: trackingPercent,
                ),
                const SizedBox(height: 8),
                _CapacityProgressRow(
                  dotColor: const Color(0xFF12B76A),
                  label: 'Can write blog',
                  ratioLabel:
                      '$availableCount / ${data.totalCount} - ${(canWritePercent * 100).toStringAsFixed(0)}%',
                  value: canWritePercent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityCounter extends StatelessWidget {
  const _CapacityCounter({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF344054),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityProgressRow extends StatelessWidget {
  const _CapacityProgressRow({
    required this.dotColor,
    required this.label,
    required this.ratioLabel,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String ratioLabel;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: value,
              valueColor: AlwaysStoppedAnimation<Color>(dotColor),
              backgroundColor: const Color(0xFFEAECF0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            ratioLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.prompt,
    required this.onRefresh,
    required this.onDelete,
    required this.formatCreatedDate,
  });

  final PromptItem prompt;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final String Function(DateTime) formatCreatedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt.question,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: prompt.keywords
                .map((keyword) => _KeywordLabel(keyword: keyword))
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LLM: ${prompt.llm}',
              style: const TextStyle(
                color: Color(0xFF344054),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaItem(
                  title: 'Brand Mentioned',
                  value: prompt.brandMentioned,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaItem(
                  title: 'Link Appeared',
                  value: prompt.linkAppeared,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaItem(
                  title: 'Sentiment',
                  value: prompt.sentiment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                formatCreatedDate(prompt.createdAt),
                style: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Color(0xFF98A2B3)),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon:
                    const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF101828),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordLabel extends StatelessWidget {
  const _KeywordLabel({required this.keyword});

  final PromptKeyword keyword;

  @override
  Widget build(BuildContext context) {
    final style = _styleForType(keyword.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        border: Border.all(color: style.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        keyword.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _KeywordStyle _styleForType(PromptKeywordType type) {
    switch (type) {
      case PromptKeywordType.informational:
        return const _KeywordStyle(
          background: Color(0xFFEFF8FF),
          border: Color(0xFFB2DDFF),
          foreground: Color(0xFF175CD3),
        );
      case PromptKeywordType.commercial:
        return const _KeywordStyle(
          background: Color(0xFFFFF6ED),
          border: Color(0xFFFDDCAB),
          foreground: Color(0xFFB54708),
        );
      case PromptKeywordType.topicKeyword:
        return const _KeywordStyle(
          background: Color(0xFFF5F3FF),
          border: Color(0xFFD9D6FE),
          foreground: Color(0xFF5925DC),
        );
      case PromptKeywordType.neutral:
        return const _KeywordStyle(
          background: Color(0xFFF9FAFB),
          border: Color(0xFFEAECF0),
          foreground: Color(0xFF475467),
        );
    }
  }
}

class _KeywordStyle {
  const _KeywordStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
