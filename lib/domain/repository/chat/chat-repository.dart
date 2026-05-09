import '../../entity/chat/chat-message.dart';
import '../../entity/chat/chat-conversation.dart';

/// Abstract repository for chat operations
/// Defines the contract for both real and mock data sources
abstract class ChatRepository {
  /// Fetches messages for a specific conversation
  ///
  /// Parameters:
  /// - conversationId: The ID of the conversation to fetch messages for
  /// - useMockData: Whether to use mock data (for development/testing)
  ///
  /// Returns: A list of ChatMessage objects in chronological order
  /// Throws: Exception if operation fails
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    bool useMockData = false,
  });

  /// Sends a new message to a conversation
  ///
  /// Parameters:
  /// - conversationId: The ID of the conversation
  /// - message: The ChatMessage to send
  /// - useMockData: Whether to use mock data (for development/testing)
  ///
  /// Returns: The created ChatMessage (with server-assigned ID and timestamp)
  /// Throws: Exception if operation fails
  Future<ChatMessage> sendMessage(
    String conversationId,
    ChatMessage message, {
    bool useMockData = false,
  });

  /// Retrieves a specific conversation
  ///
  /// Parameters:
  /// - conversationId: The ID of the conversation to retrieve
  /// - useMockData: Whether to use mock data (for development/testing)
  ///
  /// Returns: The ChatConversation object with all messages
  /// Throws: Exception if conversation not found or operation fails
  Future<ChatConversation> getConversation(
    String conversationId, {
    bool useMockData = false,
  });

  /// Creates a new empty conversation
  ///
  /// Parameters:
  /// - title: Optional title for the conversation (default: 'New Conversation')
  /// - useMockData: Whether to use mock data (for development/testing)
  ///
  /// Returns: The newly created ChatConversation
  /// Throws: Exception if operation fails
  Future<ChatConversation> createConversation({
    String title = 'New Conversation',
    bool useMockData = false,
  });

  /// Fetches recent conversations for the current user
  ///
  /// Parameters:
  /// - limit: Maximum number of conversations to return (default: 10)
  /// - useMockData: Whether to use mock data (for development/testing)
  ///
  /// Returns: A list of ChatConversation objects sorted by most recent first
  /// Throws: Exception if operation fails
  Future<List<ChatConversation>> getRecentConversations({
    int limit = 10,
    bool useMockData = false,
  });
}
