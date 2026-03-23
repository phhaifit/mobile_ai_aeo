import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_suggestion.dart';
import 'package:flutter/material.dart';

class SuggestionTabScreen extends StatelessWidget {
  const SuggestionTabScreen({
    super.key,
    required this.suggestions,
    required this.topicName,
    required this.onSuggestMore,
    required this.onReject,
    required this.onTrack,
    required this.onEdit,
    required this.formatCreatedAt,
  });

  final List<TopicSuggestion> suggestions;
  final String topicName;
  final VoidCallback onSuggestMore;
  final ValueChanged<TopicSuggestion> onReject;
  final ValueChanged<TopicSuggestion> onTrack;
  final ValueChanged<TopicSuggestion> onEdit;
  final String Function(DateTime) formatCreatedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onSuggestMore,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Suggest More'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A00),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SuggestionList(
            suggestions: suggestions,
            topicName: topicName,
            onReject: onReject,
            onTrack: onTrack,
            onEdit: onEdit,
            onSuggestMore: onSuggestMore,
            formatCreatedAt: formatCreatedAt,
          ),
        ),
      ],
    );
  }
}

class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.topicName,
    required this.onReject,
    required this.onTrack,
    required this.onEdit,
    required this.onSuggestMore,
    required this.formatCreatedAt,
  });

  final List<TopicSuggestion> suggestions;
  final String topicName;
  final ValueChanged<TopicSuggestion> onReject;
  final ValueChanged<TopicSuggestion> onTrack;
  final ValueChanged<TopicSuggestion> onEdit;
  final VoidCallback onSuggestMore;
  final String Function(DateTime) formatCreatedAt;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No suggestions available',
              style: TextStyle(
                color: Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onSuggestMore,
              child: const Text('Suggest More'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return Dismissible(
          key: ValueKey(suggestion.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6A00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Track',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              onTrack(suggestion);
            } else {
              onReject(suggestion);
            }
            return true;
          },
          child: SuggestionCard(
            suggestion: suggestion,
            topicName: topicName,
            onEdit: () => onEdit(suggestion),
            onReject: () => onReject(suggestion),
            onTrack: () => onTrack(suggestion),
            formatCreatedAt: formatCreatedAt,
          ),
        );
      },
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.topicName,
    required this.onEdit,
    required this.onReject,
    required this.onTrack,
    required this.formatCreatedAt,
  });

  final TopicSuggestion suggestion;
  final String topicName;
  final VoidCallback onEdit;
  final VoidCallback onReject;
  final VoidCallback onTrack;
  final String Function(DateTime) formatCreatedAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 780;
            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF155EEF),
                  splashRadius: 18,
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE1827),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Track'),
                ),
              ],
            );

            final metadata = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  formatCreatedAt(suggestion.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
                _SuggestionTagChip(
                  label: _suggestionTypeLabel(suggestion.type),
                  kind: suggestion.type,
                ),
                _SuggestionTagChip(
                  label: topicName,
                  kind: SuggestionType.navigational,
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.35,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 10),
                  metadata,
                  const SizedBox(height: 10),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.35,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 10),
                      metadata,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }

  String _suggestionTypeLabel(SuggestionType type) {
    switch (type) {
      case SuggestionType.informational:
        return 'Informational';
      case SuggestionType.commercial:
        return 'Commercial';
      case SuggestionType.transactional:
        return 'Transactional';
      case SuggestionType.navigational:
        return 'Navigational';
    }
  }
}

class _SuggestionTagChip extends StatelessWidget {
  const _SuggestionTagChip({
    required this.label,
    required this.kind,
  });

  final String label;
  final SuggestionType kind;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsByKind(kind);
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      side: BorderSide(color: colors.border),
      backgroundColor: colors.background,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  ({Color background, Color border, Color foreground}) _colorsByKind(
    SuggestionType type,
  ) {
    switch (type) {
      case SuggestionType.informational:
        return (
          background: const Color(0xFFEFF8FF),
          border: const Color(0xFFB2DDFF),
          foreground: const Color(0xFF175CD3),
        );
      case SuggestionType.commercial:
        return (
          background: const Color(0xFFFFF6ED),
          border: const Color(0xFFFDDCAB),
          foreground: const Color(0xFFB54708),
        );
      case SuggestionType.transactional:
        return (
          background: const Color(0xFFECFDF3),
          border: const Color(0xFFABEFC6),
          foreground: const Color(0xFF067647),
        );
      case SuggestionType.navigational:
        return (
          background: const Color(0xFFF5F3FF),
          border: const Color(0xFFD9D6FE),
          foreground: const Color(0xFF5925DC),
        );
    }
  }
}
