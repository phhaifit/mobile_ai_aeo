import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_send_message_input.dart';

class SendAssistantChatMessageParams {
  const SendAssistantChatMessageParams({
    this.conversationId,
    required this.text,
    required this.priorMessages,
  });

  final String? conversationId;
  final String text;
  final List<AssistantChatMessage> priorMessages;
}

class SendAssistantChatMessageUseCase
    extends UseCase<AssistantChatMessage, SendAssistantChatMessageParams> {
  SendAssistantChatMessageUseCase(this._repository);

  final AssistantChatRepository _repository;

  @override
  Future<AssistantChatMessage> call({
    required SendAssistantChatMessageParams params,
  }) {
    return _repository.sendUserMessage(
      input: AssistantSendMessageInput(
        sessionId: params.conversationId,
        userText: params.text,
        priorMessages: params.priorMessages,
      ),
    );
  }
}
