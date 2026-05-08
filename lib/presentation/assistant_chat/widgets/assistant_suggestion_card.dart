import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_accent.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_icon.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:flutter/material.dart';

class AssistantSuggestionCard extends StatelessWidget {
  const AssistantSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final AssistantChatSuggestion suggestion;
  final VoidCallback onTap;

  Color get _accentColor => switch (suggestion.accent) {
        AssistantSuggestionAccent.primaryBlue => AssistantChatColors.primary,
        AssistantSuggestionAccent.slateBlue => AssistantChatColors.slateAccent,
      };

  IconData get _iconData => switch (suggestion.icon) {
        AssistantSuggestionIcon.compose => Icons.edit_note_rounded,
        AssistantSuggestionIcon.lightbulb => Icons.lightbulb_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shadowColor: AssistantChatColors.cardShadow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: AssistantChatColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AssistantChatColors.iconCircleBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconData,
                              color: AssistantChatColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AssistantChatColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  suggestion.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: AssistantChatColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
