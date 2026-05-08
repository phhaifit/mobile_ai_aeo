import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';

/// Abstraction over chat data. Swap [AssistantChatRepositoryImpl] wiring from
/// mock to remote [AssistantChatDataSource] without changing use cases.
abstract class AssistantChatRepository {
  Future<AssistantChatBootstrap> loadChat({String? conversationId});

  Future<AssistantChatMessage> sendUserMessage({
    String? conversationId,
    required String text,
  });
}
