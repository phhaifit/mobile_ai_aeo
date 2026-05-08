import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_accent.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_icon.dart';

/// Static starter prompts (not from API).
List<AssistantChatSuggestion> defaultAssistantSuggestions() {
  return const [
    AssistantChatSuggestion(
      id: 'sug_email',
      title: 'Draft an Email',
      description:
          'Help me write a professional follow-up email after a client meeting.',
      accent: AssistantSuggestionAccent.primaryBlue,
      icon: AssistantSuggestionIcon.compose,
    ),
    AssistantChatSuggestion(
      id: 'sug_brainstorm',
      title: 'Brainstorm Ideas',
      description:
          'Give me 5 creative marketing concepts for a new coffee launch.',
      accent: AssistantSuggestionAccent.slateBlue,
      icon: AssistantSuggestionIcon.lightbulb,
    ),
  ];
}
