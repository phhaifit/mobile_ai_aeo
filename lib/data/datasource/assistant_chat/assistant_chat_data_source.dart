import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';

/// Remote or local origin of chat payloads. Implement with REST/WebSocket
/// when the backend is ready; [MockAssistantChatDataSource] is used for UI.
abstract class AssistantChatDataSource {
  Future<AssistantChatBootstrap> fetchBootstrap({String? conversationId});

  Future<AssistantChatMessage> sendMessage({
    String? conversationId,
    required String userText,
  });
}
