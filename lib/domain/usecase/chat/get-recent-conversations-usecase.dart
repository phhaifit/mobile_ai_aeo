import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';

/// Parameters for GetRecentConversationsUseCase
class GetRecentConversationsParams {
  final int limit;
  final bool useMockData;

  GetRecentConversationsParams({
    this.limit = 10,
    this.useMockData = false,
  });
}

/// Use case for fetching recent conversations
class GetRecentConversationsUseCase
    extends UseCase<List<ChatConversation>, GetRecentConversationsParams> {
  final ChatRepository _chatRepository;

  GetRecentConversationsUseCase(this._chatRepository);

  @override
  Future<List<ChatConversation>> call(
      {required GetRecentConversationsParams params}) {
    return _chatRepository.getRecentConversations(
      limit: params.limit,
      useMockData: params.useMockData,
    );
  }
}
