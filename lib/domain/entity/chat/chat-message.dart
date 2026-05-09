/// Represents a single chat message in a conversation.
/// Immutable entity following domain layer patterns.
class ChatMessage {
  /// Unique identifier for the message
  final String id;

  /// ID of the parent conversation
  final String conversationId;

  /// Sender of the message: 'user' or 'assistant'
  final String sender;

  /// Message content/text
  final String content;

  /// When the message was created
  final DateTime timestamp;

  /// Optional metadata for additional information
  final Map<String, dynamic>? metadata;

  /// Creates a chat message with immutable properties
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  /// Creates a copy of this message with optional field updates
  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? sender,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if message is from user
  bool get isFromUser => sender == 'user';

  /// Check if message is from assistant
  bool get isFromAssistant => sender == 'assistant';

  @override
  String toString() =>
      'ChatMessage(id: $id, sender: $sender, content: $content, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          conversationId == other.conversationId &&
          sender == other.sender &&
          content == other.content &&
          timestamp == other.timestamp &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      id.hashCode ^
      conversationId.hashCode ^
      sender.hashCode ^
      content.hashCode ^
      timestamp.hashCode ^
      metadata.hashCode;
}
