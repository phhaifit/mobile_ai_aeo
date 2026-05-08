import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_session_summary.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

/// Marker type for use cases with no parameters.
class AssistantNoParams {
  const AssistantNoParams();
}

class GetAssistantRecentSessionsUseCase
    extends UseCase<List<AssistantSessionSummary>, AssistantNoParams> {
  GetAssistantRecentSessionsUseCase(this._repository);

  final AssistantChatRepository _repository;

  @override
  Future<List<AssistantSessionSummary>> call({
    required AssistantNoParams params,
  }) {
    return _repository.readRecentSessions();
  }
}
