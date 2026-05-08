import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

class DeleteAssistantSessionParams {
  const DeleteAssistantSessionParams({required this.sessionId});

  final String sessionId;
}

class DeleteAssistantSessionUseCase
    extends UseCase<void, DeleteAssistantSessionParams> {
  DeleteAssistantSessionUseCase(this._repository);

  final AssistantChatRepository _repository;

  @override
  Future<void> call({required DeleteAssistantSessionParams params}) {
    return _repository.deleteSessionRemote(params.sessionId);
  }
}
