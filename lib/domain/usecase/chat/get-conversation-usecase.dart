import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';

/// Parameters for GetConversationUseCase
class GetConversationParams {
  final String conversationId;
  final bool useMockData;

  GetConversationParams({
    required this.conversationId,
    this.useMockData = false,
  });
}

/// Use case for fetching a specific conversation
class GetConversationUseCase
    extends UseCase<ChatConversation, GetConversationParams> {
  final ChatRepository _chatRepository;

  GetConversationUseCase(this._chatRepository);

  @override
  Future<ChatConversation> call({required GetConversationParams params}) {
    return _chatRepository.getConversation(
      params.conversationId,
      useMockData: params.useMockData,
    );
  }
}
