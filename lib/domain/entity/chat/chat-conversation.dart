import 'chat-message.dart';

/// Represents a chat conversation containing multiple messages.
/// Immutable entity following domain layer patterns.
class ChatConversation {
  /// Unique identifier for the conversation
  final String id;

  /// Title or summary of the conversation
  final String title;

  /// List of messages in this conversation
  final List<ChatMessage> messages;

  /// When the conversation was created
  final DateTime createdAt;

  /// When the conversation was last updated
  final DateTime updatedAt;

  /// Whether this conversation is active
  final bool isActive;

  /// Creates a chat conversation with immutable properties
  const ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Creates an empty conversation
  factory ChatConversation.empty({
    required String id,
    String title = 'New Conversation',
  }) {
    final now = DateTime.now();
    return ChatConversation(
      id: id,
      title: title,
      messages: const [],
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
  }

  /// Creates a copy of this conversation with optional field updates
  ChatConversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Gets the last message in the conversation
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Gets the count of messages
  int get messageCount => messages.length;

  /// Adds a new message to the conversation
  ChatConversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'ChatConversation(id: $id, title: $title, messageCount: ${messages.length}, isActive: $isActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          messages == other.messages &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      messages.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isActive.hashCode;
}
