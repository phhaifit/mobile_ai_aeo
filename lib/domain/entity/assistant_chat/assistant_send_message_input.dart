import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';

/// Arguments for POST /assistant/chat (session + optional client-side history).
class AssistantSendMessageInput {
  const AssistantSendMessageInput({
    required this.sessionId,
    required this.userText,
    required this.priorMessages,
  });

  /// Non-empty when using Mongo-backed session (backend ignores [priorMessages]).
  final String? sessionId;

  final String userText;

  /// Messages already in the thread before this user turn.
  final List<AssistantChatMessage> priorMessages;
}
