import 'package:meta/meta.dart';

import 'assistant_chat_message.dart';
import 'assistant_chat_suggestion.dart';

/// Initial payload for the assistant chat screen (suggestions + history).
@immutable
class AssistantChatBootstrap {
  final List<AssistantChatSuggestion> suggestions;
  final List<AssistantChatMessage> messages;

  const AssistantChatBootstrap({
    required this.suggestions,
    required this.messages,
  });
}
