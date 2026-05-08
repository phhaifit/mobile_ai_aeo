import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

class LoadAssistantChatParams {
  final String? conversationId;

  const LoadAssistantChatParams({this.conversationId});
}

class LoadAssistantChatUseCase
    extends UseCase<AssistantChatBootstrap, LoadAssistantChatParams> {
  LoadAssistantChatUseCase(this._repository);

  final AssistantChatRepository _repository;

  @override
  Future<AssistantChatBootstrap> call({
    required LoadAssistantChatParams params,
  }) {
    return _repository.loadChat(conversationId: params.conversationId);
  }
}
