import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';

/// Parameters for GetChatMessagesUseCase
class GetChatMessagesParams {
  final String conversationId;
  final bool useMockData;

  GetChatMessagesParams({
    required this.conversationId,
    this.useMockData = false,
  });
}

/// Use case for fetching chat messages from a conversation
class GetChatMessagesUseCase
    extends UseCase<List<ChatMessage>, GetChatMessagesParams> {
  final ChatRepository _chatRepository;

  GetChatMessagesUseCase(this._chatRepository);

  @override
  Future<List<ChatMessage>> call({required GetChatMessagesParams params}) {
    return _chatRepository.getMessages(
      params.conversationId,
      useMockData: params.useMockData,
    );
  }
}
