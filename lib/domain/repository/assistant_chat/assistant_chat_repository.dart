import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_session_summary.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_send_message_input.dart';

/// Assistant chat + local recent-session index.
abstract class AssistantChatRepository {
  Future<AssistantChatBootstrap> loadChat({String? conversationId});

  Future<AssistantChatMessage> sendUserMessage({
    required AssistantSendMessageInput input,
  });

  Future<List<AssistantSessionSummary>> readRecentSessions();

  Future<void> deleteSessionRemote(String sessionId);
}
