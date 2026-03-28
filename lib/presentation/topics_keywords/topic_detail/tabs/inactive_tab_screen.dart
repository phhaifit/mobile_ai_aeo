import 'package:boilerplate/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart';
import 'package:flutter/material.dart';

class InactiveTabScreen extends StatelessWidget {
  const InactiveTabScreen({
    super.key,
    required this.prompts,
    required this.onRestorePrompt,
    required this.onDeletePrompt,
    required this.formatDeletedDate,
  });

  final List<PromptItem> prompts;
  final ValueChanged<PromptItem> onRestorePrompt;
  final ValueChanged<PromptItem> onDeletePrompt;
  final String Function(DateTime) formatDeletedDate;

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) {
      return const Center(
        child: Text(
          'No inactive prompts',
          style: TextStyle(color: Color(0xFF667085)),
        ),
      );
    }

    return ListView.separated(
      itemCount: prompts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return _InactivePromptCard(
          prompt: prompt,
          onRestore: () => onRestorePrompt(prompt),
          onDeletePermanently: () => onDeletePrompt(prompt),
          formatDeletedDate: formatDeletedDate,
        );
      },
    );
  }
}

class _InactivePromptCard extends StatelessWidget {
  const _InactivePromptCard({
    required this.prompt,
    required this.onRestore,
    required this.onDeletePermanently,
    required this.formatDeletedDate,
  });

  final PromptItem prompt;
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;
  final String Function(DateTime) formatDeletedDate;

  @override
  Widget build(BuildContext context) {
    final deletedAt = prompt.deletedAt ?? prompt.createdAt;

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
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Color(0xFF98A2B3),
              ),
              Text(
                'Deleted: ${formatDeletedDate(deletedAt)}',
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...prompt.keywords
                  .map((keyword) => _KeywordLabel(keyword: keyword)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            runAlignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: onDeletePermanently,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete Permanently'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('Restore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
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
