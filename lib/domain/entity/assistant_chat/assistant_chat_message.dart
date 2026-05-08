import 'package:meta/meta.dart';

import 'assistant_chat_role.dart';
import 'assistant_message_payload.dart';

@immutable
class AssistantChatMessage {
  final String id;
  final AssistantChatRole role;
  final DateTime sentAt;
  final AssistantMessagePayload payload;

  const AssistantChatMessage({
    required this.id,
    required this.role,
    required this.sentAt,
    required this.payload,
  });

  bool get isUser => role == AssistantChatRole.user;
}
