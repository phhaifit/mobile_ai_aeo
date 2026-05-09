import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';

/// Parameters for SendChatMessageUseCase
class SendChatMessageParams {
  final String conversationId;
  final String content;
  final String sender;
  final bool useMockData;

  SendChatMessageParams({
    required this.conversationId,
    required this.content,
    this.sender = 'user',
    this.useMockData = false,
  });
}

/// Use case for sending a new message to a conversation
class SendChatMessageUseCase
    extends UseCase<ChatMessage, SendChatMessageParams> {
  final ChatRepository _chatRepository;

  SendChatMessageUseCase(this._chatRepository);

  @override
  Future<ChatMessage> call({required SendChatMessageParams params}) {
    // Create a new message with generated ID and timestamp
    final newMessage = ChatMessage(
      id: _generateMessageId(),
      conversationId: params.conversationId,
      sender: params.sender,
      content: params.content,
      timestamp: DateTime.now(),
    );

    return _chatRepository.sendMessage(
      params.conversationId,
      newMessage,
      useMockData: params.useMockData,
    );
  }

  /// Generates a unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${(Math.random() * 10000).toInt()}';
  }
}

// Workaround for generating random numbers without importing dart:math at module level
class Math {
  static final _random = DateTime.now().millisecond;
  static double random() {
    return (_random / 1000.0) * (DateTime.now().microsecond % 1000) / 1000.0;
  }
}
