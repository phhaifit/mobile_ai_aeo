import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

class SendAssistantChatMessageParams {
  final String? conversationId;
  final String text;

  const SendAssistantChatMessageParams({
    this.conversationId,
    required this.text,
  });
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
      conversationId: params.conversationId,
      text: params.text,
    );
  }
}
