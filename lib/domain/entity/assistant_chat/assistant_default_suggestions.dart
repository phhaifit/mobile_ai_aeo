import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_accent.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_icon.dart';

/// Static starter prompts (not from API).
List<AssistantChatSuggestion> defaultAssistantSuggestions() {
  return const [
    AssistantChatSuggestion(
      id: 'sug_project_bh',
      title: 'Create "Bác Hồ Kính Yêu" project',
      description:
          'Create a project named bác hồ kính yêu',
      accent: AssistantSuggestionAccent.primaryBlue,
      icon: AssistantSuggestionIcon.compose,
    ),
    AssistantChatSuggestion(
      id: 'sug_writing_style',
      title: 'New writing style',
      description: 'Create a new writing style',
      accent: AssistantSuggestionAccent.slateBlue,
      icon: AssistantSuggestionIcon.lightbulb,
    ),
  ];
}
