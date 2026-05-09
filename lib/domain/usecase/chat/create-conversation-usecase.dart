import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';

/// Parameters for CreateConversationUseCase
class CreateConversationParams {
  final String title;
  final bool useMockData;

  CreateConversationParams({
    this.title = 'New Conversation',
    this.useMockData = false,
  });
}

/// Use case for creating a new conversation
class CreateConversationUseCase
    extends UseCase<ChatConversation, CreateConversationParams> {
  final ChatRepository _chatRepository;

  CreateConversationUseCase(this._chatRepository);

  @override
  Future<ChatConversation> call({required CreateConversationParams params}) {
    return _chatRepository.createConversation(
      title: params.title,
      useMockData: params.useMockData,
    );
  }
}
