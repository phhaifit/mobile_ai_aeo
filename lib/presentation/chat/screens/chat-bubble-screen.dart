import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/presentation/chat/store/chat_store.dart';
import 'package:boilerplate/presentation/chat/widgets/chat-bubble-widget.dart';
import 'package:boilerplate/presentation/chat/widgets/chat-input-field.dart';
import 'package:boilerplate/presentation/chat/widgets/suggestion-chips.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/chat/screens/conversation_list_screen.dart';

/// Main chat screen showing conversation
class ChatBubbleScreen extends StatefulWidget {
  final bool isModal;
  final String? conversationId;

  const ChatBubbleScreen({
    Key? key,
    this.isModal = false,
    this.conversationId,
  }) : super(key: key);

  @override
  State<ChatBubbleScreen> createState() => _ChatBubbleScreenState();
}

class _ChatBubbleScreenState extends State<ChatBubbleScreen> {
  late ChatStore _chatStore;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sample suggestions for quick actions
  static const List<String> _suggestedQuestions = [
    'Business names',
    'Human names',
    'Games name',
    'Pet names',
    'Dish names',
    'Character names',
  ];

  @override
  void initState() {
    super.initState();
    _chatStore = getIt<ChatStore>();
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      _chatStore.selectedConversationId = widget.conversationId!;
    }
    _chatStore.initializeChat();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to the latest message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isModal
          ? null
          : AppBar(
              title: Text('Chatbot AI'),
              centerTitle: true,
              backgroundColor: Colors.purple.shade500,
              elevation: 0,
              actions: [
                IconButton(
                  tooltip: 'Conversations',
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: Observer(
        builder: (_) {
          if (_chatStore.isLoading && _chatStore.messages.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade500,
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_chatStore.hasMessages) {
              _scrollToBottom();
            }
          });

          final content = Column(
            children: [
              // Modal header when shown inside a dialog
              if (widget.isModal)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chatbot AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Conversations',
                        icon: Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConversationListScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              // Error message display
              if (_chatStore.errorStore.errorMessage.isNotEmpty)
                Container(
                  color: Colors.red.shade50,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    _chatStore.errorStore.errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // Messages list
              Expanded(
                child: _chatStore.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _chatStore.messages.length,
                        itemBuilder: (context, index) {
                          final message = _chatStore.messages[index];
                          return ChatBubbleWidget(
                            message: message,
                            isUser: message.isFromUser,
                          );
                        },
                      ),
              ),
              // Suggestion chips
              if (_chatStore.messages.isEmpty ||
                  (_chatStore.messages.isNotEmpty &&
                      _chatStore.messages.last.isFromAssistant))
                SuggestionChipsWidget(
                  suggestions: _suggestedQuestions,
                  onSuggestionTapped: (suggestion) {
                    _chatStore.sendSuggestion(suggestion);
                  },
                ),
              // Input field
              ChatInputFieldWidget(
                controller: _inputController,
                onSendMessage: (message) {
                  _chatStore.sendMessage(message);
                },
                isLoading: _chatStore.isSending,
                canSend: _chatStore.canSendMessage,
                onChanged: (value) {
                  _chatStore.updateMessageInput(value);
                },
              ),
            ],
          );

          if (widget.isModal) {
            // Wrap modal content with rounded corners
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: content,
                  ),
                ),
              ),
            );
          }

          return content;
        },
      ),
    );
  }

  /// Empty state widget when no messages
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 48,
              color: Colors.purple.shade500,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hi, you can ask me anything about names',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'I suggest you some names you can ask me.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
