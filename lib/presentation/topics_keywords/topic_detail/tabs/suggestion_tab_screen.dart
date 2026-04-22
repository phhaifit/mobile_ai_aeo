import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_suggestion.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level tab widget — mobile-native layout
// ─────────────────────────────────────────────────────────────────────────────
class SuggestionTabScreen extends StatelessWidget {
  const SuggestionTabScreen({
    super.key,
    required this.store,
    required this.topicName,
    required this.onEdit,
    required this.formatCreatedAt,
  });

  final TopicDetailStore store;
  final String topicName;
  final ValueChanged<TopicSuggestion> onEdit;
  final String Function(DateTime) formatCreatedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Control strip ─────────────────────────────────────────────────
        _SuggestionControlStrip(store: store),
        const SizedBox(height: 10),

        // ── Intent filter chips (horizontal scroll) ────────────────────────
        _IntentFilterChips(store: store),
        const SizedBox(height: 10),

        // ── Suggestion list ────────────────────────────────────────────────
        Expanded(
          child: _SuggestionContent(
            store: store,
            topicName: topicName,
            onEdit: onEdit,
            formatCreatedAt: formatCreatedAt,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top control strip: Generate For + Suggest More + count
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionControlStrip extends StatelessWidget {
  const _SuggestionControlStrip({required this.store});

  final TopicDetailStore store;

  @override
  Widget build(BuildContext context) {
    final count = store.filteredSuggestions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Generate For row
        Row(
          children: [
            const Text(
              'Generate for',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {}, // future: open persona picker
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          'No persona (generic)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF344054),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF667085),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Suggest More + count row
        Row(
          children: [
            // Count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count suggestion${count == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ),
            const Spacer(),
            // Suggest More button
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed:
                    store.isSuggestingMore ? null : store.suggestMoreFromApi,
                icon: store.isSuggestingMore
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 14),
                label: Text(
                  store.isSuggestingMore ? 'Generating…' : 'Suggest More',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal scrollable intent filter chips
// ─────────────────────────────────────────────────────────────────────────────
class _IntentFilterChips extends StatelessWidget {
  const _IntentFilterChips({required this.store});

  final TopicDetailStore store;

  @override
  Widget build(BuildContext context) {
    final intents = store.availableSuggestionIntents;
    final selected = store.selectedSuggestionIntent;

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _IntentChip(
            label: 'All',
            color: const Color(0xFF344054),
            isSelected: selected == null,
            onTap: () => store.setSuggestionIntentFilter(null),
          ),
          ...intents.map((intent) {
            final cfg = _intentConfig(intent);
            return _IntentChip(
              label: cfg.label,
              color: cfg.color,
              isSelected: selected == intent,
              onTap: () => store.setSuggestionIntentFilter(intent),
            );
          }),
        ],
      ),
    );
  }

  ({String label, Color color}) _intentConfig(SuggestionType type) {
    switch (type) {
      case SuggestionType.informational:
        return (label: 'Informational', color: const Color(0xFF175CD3));
      case SuggestionType.commercial:
        return (label: 'Commercial', color: const Color(0xFFB54708));
      case SuggestionType.transactional:
        return (label: 'Transactional', color: const Color(0xFF067647));
      case SuggestionType.navigational:
        return (label: 'Navigational', color: const Color(0xFF5925DC));
    }
  }
}

class _IntentChip extends StatelessWidget {
  const _IntentChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFD0D5DD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestion content area
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionContent extends StatelessWidget {
  const _SuggestionContent({
    required this.store,
    required this.topicName,
    required this.onEdit,
    required this.formatCreatedAt,
  });

  final TopicDetailStore store;
  final String topicName;
  final ValueChanged<TopicSuggestion> onEdit;
  final String Function(DateTime) formatCreatedAt;

  @override
  Widget build(BuildContext context) {
    if (store.isSuggestionsLoading && store.filteredSuggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.suggestionsError != null && store.filteredSuggestions.isEmpty) {
      return _SuggestionErrorState(
        message: store.suggestionsError!,
        onRetry: store.fetchSuggestions,
      );
    }

    if (store.filteredSuggestions.isEmpty) {
      return _SuggestionEmptyState(onSuggestMore: store.suggestMoreFromApi);
    }

    return RefreshIndicator(
      color: const Color(0xFFFF6A00),
      onRefresh: store.fetchSuggestions,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: store.filteredSuggestions.length +
            (store.hasMoreSuggestions &&
                    store.selectedSuggestionIntent == null
                ? 1
                : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == store.filteredSuggestions.length) {
            return _LoadMoreButton(onTap: store.loadMoreSuggestions);
          }
          final suggestion = store.filteredSuggestions[index];
          return Dismissible(
            key: ValueKey(suggestion.id),
            background: _swipeBg(
              alignment: Alignment.centerLeft,
              color: const Color(0xFFFF6A00),
              label: 'Track',
              icon: Icons.bookmark_add_outlined,
            ),
            secondaryBackground: _swipeBg(
              alignment: Alignment.centerRight,
              color: const Color(0xFFEF4444),
              label: 'Reject',
              icon: Icons.close,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                store.trackSuggestion(suggestion);
              } else {
                store.rejectSuggestion(suggestion.id);
              }
              return true;
            },
            child: SuggestionCard(
              suggestion: suggestion,
              topicName: topicName,
              onEdit: () => onEdit(suggestion),
              onReject: () => store.rejectSuggestion(suggestion.id),
              onTrack: () => store.trackSuggestion(suggestion),
              formatCreatedAt: formatCreatedAt,
            ),
          );
        },
      ),
    );
  }

  Widget _swipeBg({
    required AlignmentGeometry alignment,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestion card — full-width, mobile-optimised
// ─────────────────────────────────────────────────────────────────────────────
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
      shadowColor: Colors.black.withValues(alpha: 0.06),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Prompt text + edit icon ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Color(0xFF155EEF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Date + Intent chip + Topic chip ────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 12,
                      color: Color(0xFF98A2B3),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(suggestion.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                _SuggestionTypeChip(type: suggestion.type),
                _TopicChip(
                  label: suggestion.topicName.isNotEmpty
                      ? suggestion.topicName
                      : topicName,
                ),
              ],
            ),

            // ── Keywords ───────────────────────────────────────────────────
            if (suggestion.keywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: suggestion.keywords
                    .map((kw) => _KeywordChip(label: kw))
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF2F4F7)),
            const SizedBox(height: 10),

            // ── Reject / Track buttons — full width ────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEE1827),
                      side: const BorderSide(color: Color(0xFFEE1827)),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 14),
                    label: const Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6A00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionTypeChip extends StatelessWidget {
  const _SuggestionTypeChip({required this.type});

  final SuggestionType type;

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cfg.border),
      ),
      child: Text(
        cfg.label,
        style: TextStyle(
          color: cfg.fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({String label, Color bg, Color border, Color fg}) _config() {
    switch (type) {
      case SuggestionType.informational:
        return (
          label: 'Informational',
          bg: const Color(0xFFEFF8FF),
          border: const Color(0xFFB2DDFF),
          fg: const Color(0xFF175CD3),
        );
      case SuggestionType.commercial:
        return (
          label: 'Commercial',
          bg: const Color(0xFFFFF6ED),
          border: const Color(0xFFFDDCAB),
          fg: const Color(0xFFB54708),
        );
      case SuggestionType.transactional:
        return (
          label: 'Transactional',
          bg: const Color(0xFFECFDF3),
          border: const Color(0xFFABEFC6),
          fg: const Color(0xFF067647),
        );
      case SuggestionType.navigational:
        return (
          label: 'Navigational',
          bg: const Color(0xFFF5F3FF),
          border: const Color(0xFFD9D6FE),
          fg: const Color(0xFF5925DC),
        );
    }
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF667085),
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error / Load-more
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionEmptyState extends StatelessWidget {
  const _SuggestionEmptyState({required this.onSuggestMore});
  final VoidCallback onSuggestMore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 32,
                color: Color(0xFFFF6A00),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No suggestions yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Tap "Suggest More" to generate\nAI-powered prompt suggestions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF667085),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onSuggestMore,
              icon: const Icon(Icons.auto_awesome, size: 15),
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
          ],
        ),
      ),
    );
  }
}

class _SuggestionErrorState extends StatelessWidget {
  const _SuggestionErrorState({
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 38,
              color: Color(0xFFD0D5DD),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('Load more'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF6A00),
          ),
        ),
      ),
    );
  }
}
