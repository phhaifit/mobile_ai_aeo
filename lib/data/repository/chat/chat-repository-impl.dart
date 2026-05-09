import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'package:boilerplate/domain/repository/chat/chat-repository.dart';
import 'package:boilerplate/data/datasource/remote/chat/chat-mock-datasource.dart';

/// Concrete implementation of ChatRepository
/// Bridges domain layer with data sources (mock or real)
class ChatRepositoryImpl implements ChatRepository {
  final ChatMockDataSource _mockDataSource;

  ChatRepositoryImpl(this._mockDataSource);

  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    bool useMockData = false,
  }) async {
    try {
      if (useMockData) {
        return await _mockDataSource.getMessages(conversationId);
      }
      // TODO: Implement real API call when backend is ready
      // return await _chatApiClient.getMessages(conversationId);
      throw UnimplementedError(
        'Real data source not implemented yet. Use useMockData=true for now.',
      );
    } catch (e) {
      throw Exception('Failed to fetch chat messages: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage(
    String conversationId,
    ChatMessage message, {
    bool useMockData = false,
  }) async {
    try {
      if (useMockData) {
        return await _mockDataSource.sendMessage(conversationId, message);
      }
      // TODO: Implement real API call when backend is ready
      // return await _chatApiClient.sendMessage(conversationId, message);
      throw UnimplementedError(
        'Real data source not implemented yet. Use useMockData=true for now.',
      );
    } catch (e) {
      throw Exception('Failed to send chat message: $e');
    }
  }

  @override
  Future<ChatConversation> getConversation(
    String conversationId, {
    bool useMockData = false,
  }) async {
    try {
      if (useMockData) {
        return await _mockDataSource.getConversation(conversationId);
      }
      // TODO: Implement real API call when backend is ready
      // return await _chatApiClient.getConversation(conversationId);
      throw UnimplementedError(
        'Real data source not implemented yet. Use useMockData=true for now.',
      );
    } catch (e) {
      throw Exception('Failed to fetch conversation: $e');
    }
  }

  @override
  Future<ChatConversation> createConversation({
    String title = 'New Conversation',
    bool useMockData = false,
  }) async {
    try {
      if (useMockData) {
        return await _mockDataSource.createConversation(title: title);
      }
      // TODO: Implement real API call when backend is ready
      // return await _chatApiClient.createConversation(title);
      throw UnimplementedError(
        'Real data source not implemented yet. Use useMockData=true for now.',
      );
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  @override
  Future<List<ChatConversation>> getRecentConversations({
    int limit = 10,
    bool useMockData = false,
  }) async {
    try {
      if (useMockData) {
        return await _mockDataSource.getRecentConversations(limit: limit);
      }
      // TODO: Implement real API call when backend is ready
      // return await _chatApiClient.getRecentConversations(limit);
      throw UnimplementedError(
        'Real data source not implemented yet. Use useMockData=true for now.',
      );
    } catch (e) {
      throw Exception('Failed to fetch recent conversations: $e');
    }
  }
}
