import 'package:meta/meta.dart';

import 'assistant_suggestion_accent.dart';
import 'assistant_suggestion_icon.dart';

@immutable
class AssistantChatSuggestion {
  final String id;
  final String title;
  final String description;
  final AssistantSuggestionAccent accent;
  final AssistantSuggestionIcon icon;

  const AssistantChatSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.accent,
    required this.icon,
  });
}
