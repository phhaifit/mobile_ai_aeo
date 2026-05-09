import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'dart:async';

/// Mock data source providing realistic chatbot conversations
/// Used for development and testing without backend API
class ChatMockDataSource {
  // Constants for mock data
  static const String _defaultConversationId = 'conv_mock_001';
  static const String _assistantId = 'assistant';

  // In-memory storage for mock data
  static final Map<String, ChatConversation> _mockConversations = {};
  static int _messageCounter = 0;
  static int _conversationCounter = 0;

  /// Initialize mock data on first access
  static void _initializeMockData() {
    if (_mockConversations.isNotEmpty) return;

    final now = DateTime.now();

    // Create default mock conversation
    final defaultConversation = ChatConversation(
      id: _defaultConversationId,
      title: 'Ask Engine Optimization Guide',
      messages: [
        ChatMessage(
          id: 'msg_001',
          conversationId: _defaultConversationId,
          sender: _assistantId,
          content:
              'Hi, you can ask me anything about names. I suggest you some names you can ask me.',
          timestamp: now.subtract(Duration(minutes: 5)),
        ),
        ChatMessage(
          id: 'msg_002',
          conversationId: _defaultConversationId,
          sender: _assistantId,
          content:
              'Here are some categories: Business names, Human names, Game names, Pet names, Dish names, Character names, and more!',
          timestamp: now.subtract(Duration(minutes: 4, seconds: 30)),
        ),
      ],
      createdAt: now.subtract(Duration(minutes: 10)),
      updatedAt: now.subtract(Duration(minutes: 4, seconds: 30)),
      isActive: true,
    );

    _mockConversations[_defaultConversationId] = defaultConversation;
  }

  /// Fetches mock messages for a conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    _initializeMockData();

    final conversation = _mockConversations[conversationId];
    if (conversation == null) {
      throw Exception('Conversation not found: $conversationId');
    }

    return conversation.messages;
  }

  /// Simulates sending a message and getting a mock response
  Future<ChatMessage> sendMessage(
    String conversationId,
    ChatMessage userMessage,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    _initializeMockData();

    final conversation = _mockConversations[conversationId];
    if (conversation == null) {
      throw Exception('Conversation not found: $conversationId');
    }

    // Generate response based on user message content
    final assistantResponse = _generateMockResponse(userMessage.content);

    // Create response message
    final responseMessage = ChatMessage(
      id: _generateMessageId(),
      conversationId: conversationId,
      sender: _assistantId,
      content: assistantResponse,
      timestamp: DateTime.now(),
    );

    // Update conversation with both messages
    final updatedMessages = [
      ...conversation.messages,
      userMessage,
      responseMessage,
    ];

    final updatedConversation = conversation.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    _mockConversations[conversationId] = updatedConversation;

    return responseMessage;
  }

  /// Retrieves a mock conversation
  Future<ChatConversation> getConversation(String conversationId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    _initializeMockData();

    final conversation = _mockConversations[conversationId];
    if (conversation == null) {
      throw Exception('Conversation not found: $conversationId');
    }

    return conversation;
  }

  /// Creates a new empty mock conversation
  Future<ChatConversation> createConversation({
    String title = 'New Conversation',
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    _initializeMockData();

    final newId = _generateConversationId();

    final newConversation = ChatConversation.empty(
      id: newId,
      title: title,
    );

    _mockConversations[newId] = newConversation;

    return newConversation;
  }

  /// Fetches recent mock conversations
  Future<List<ChatConversation>> getRecentConversations({
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));

    _initializeMockData();

    final conversations = _mockConversations.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return conversations.take(limit).toList();
  }

  /// Generates contextual mock responses based on user input
  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Map of keywords to mock responses
    const responseMap = {
      'business name':
          'Here are some great business name suggestions:\n• TechVenture Pro\n• CloudSync Solutions\n• Digital Growth Labs\n• Innovation Hub Co.',
      'human name':
          'Here are some popular human names:\n• Emma\n• Sophia\n• Oliver\n• Liam\n• Ava\n• Noah',
      'game name':
          'Here are some creative game names:\n• Shadow\'s Legacy\n• Quantum Quest\n• Nexus Warriors\n• Ethereal Realms\n• Cosmic Frontier',
      'pet name':
          'Here are some adorable pet names:\n• Luna\n• Charlie\n• Max\n• Bella\n• Rocky\n• Daisy',
      'dish name':
          'Here are some delicious dish names:\n• Garlic Herb Pasta\n• Teriyaki Salmon\n• Truffle Risotto\n• Mediterranean Salad\n• Spicy Thai Curry',
      'character name':
          'Here are some unique character names:\n• Lyra Shadowborn\n• Kai Stormwind\n• Elara Starlight\n• Marcus Ironheart\n• Luna Moonwhisper',
      'random name':
          'Here are some random creative names:\n• Zenith Aurora\n• Phoenix Rising\n• Stellar Voyage\n• Mystic Haven\n• Luminous Path',
      'help':
          'I can help you generate names for:\n• Business ventures\n• Human characters\n• Video game characters\n• Pets\n• Dishes\n• And much more!\n\nJust tell me what category you\'d like names for!',
    };

    // Find matching response or return default
    for (final keyword in responseMap.keys) {
      if (lowerMessage.contains(keyword)) {
        return responseMap[keyword]!;
      }
    }

    // Default response for unmatched queries
    return 'That\'s an interesting question! I can help you with:\n• Business names\n• Human names\n• Game character names\n• Pet names\n• Dish names\n• And more!\n\nWhat would you like me to help you with?';
  }

  /// Generates unique message IDs
  String _generateMessageId() {
    _messageCounter++;
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_messageCounter}';
  }

  /// Generates unique conversation IDs
  String _generateConversationId() {
    _conversationCounter++;
    return 'conv_${DateTime.now().millisecondsSinceEpoch}_${_conversationCounter}';
  }

  /// Clears all mock data (useful for testing)
  void clearMockData() {
    _mockConversations.clear();
    _messageCounter = 0;
    _conversationCounter = 0;
  }

  /// Resets mock data to initial state
  void resetMockData() {
    clearMockData();
    _initializeMockData();
  }
}
