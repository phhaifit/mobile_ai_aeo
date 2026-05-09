import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/domain/usecase/chat/get-chat-messages-usecase.dart';
import 'package:boilerplate/domain/usecase/chat/send-chat-message-usecase.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStore with _$ChatStore;

abstract class _ChatStore with Store {
  // Constructor:---------------------------------------------------------------
  _ChatStore(
    this._getChatMessagesUseCase,
    this._sendChatMessageUseCase,
    this.errorStore,
  ) {
    _setupDisposers();
  }

  // Use cases:-----------------------------------------------------------------
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendChatMessageUseCase _sendChatMessageUseCase;

  // Stores:--------------------------------------------------------------------
  final ErrorStore errorStore;

  // Store variables:-----------------------------------------------------------
  static const String _defaultConversationId = 'conv_mock_001';

  @observable
  String selectedConversationId = _defaultConversationId;

  @observable
  List<ChatMessage> messages = [];

  @observable
  String messageInput = '';

  @observable
  bool isSending = false;

  @observable
  bool isLoading = false;

  @observable
  bool isChatWindowOpen = false;

  // Computed properties:-------------------------------------------------------
  @computed
  bool get hasMessages => messages.isNotEmpty;

  @computed
  bool get canSendMessage => messageInput.trim().isNotEmpty && !isSending;

  // Disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      // Auto-clear input after successful send
      reaction(
        (_) => isSending,
        (sending) {
          if (!sending && messageInput.isNotEmpty && messages.isNotEmpty) {
            // Message was likely sent, clear input
          }
        },
      ),
    ];
  }

  // Actions:-------------------------------------------------------------------

  /// Initialize chat with default conversation
  @action
  Future<void> initializeChat() async {
    selectedConversationId = _defaultConversationId;
    await fetchMessages();
  }

  /// Fetch messages from selected conversation
  @action
  Future<void> fetchMessages() async {
    if (selectedConversationId.isEmpty) return;

    isLoading = true;
    try {
      final messageList = await _getChatMessagesUseCase.call(
        params: GetChatMessagesParams(
          conversationId: selectedConversationId,
          useMockData: true,
        ),
      );
      messages = messageList;
      errorStore.setErrorMessage('');
    } catch (e) {
      final errorMessage = e is DioException
          ? DioExceptionUtil.handleError(e)
          : 'Failed to fetch messages';
      errorStore.setErrorMessage(errorMessage);
      messages = [];
    } finally {
      isLoading = false;
    }
  }

  /// Update message input field
  @action
  void updateMessageInput(String input) {
    messageInput = input;
    if (errorStore.errorMessage.isNotEmpty) {
      errorStore.setErrorMessage('');
    }
  }

  /// Send a message and fetch updated conversation
  @action
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || selectedConversationId.isEmpty) return;
    if (isSending) return;

    isSending = true;
    try {
      // Create and send message
      await _sendChatMessageUseCase.call(
        params: SendChatMessageParams(
          conversationId: selectedConversationId,
          content: content.trim(),
          sender: 'user',
          useMockData: true,
        ),
      );

      // Clear input on success
      messageInput = '';

      // Fetch updated messages
      await fetchMessages();

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage('Failed to send message');
    } finally {
      isSending = false;
    }
  }

  /// Send quick suggestion response
  @action
  Future<void> sendSuggestion(String suggestionText) async {
    await sendMessage(suggestionText);
  }

  /// Toggle chat window open/closed state
  @action
  void toggleChatWindow() {
    isChatWindowOpen = !isChatWindowOpen;
  }

  /// Open chat window
  @action
  void openChatWindow() {
    isChatWindowOpen = true;
    if (messages.isEmpty) {
      initializeChat();
    }
  }

  /// Close chat window
  @action
  void closeChatWindow() {
    isChatWindowOpen = false;
  }

  /// Clear all messages
  @action
  void clearMessages() {
    messages = [];
    messageInput = '';
  }

  /// Reset chat to initial state
  @action
  void resetChat() {
    clearMessages();
    selectedConversationId = _defaultConversationId;
    errorStore.setErrorMessage('');
  }

  // Cleanup:-------------------------------------------------------------------
  void dispose() {
    for (var disposer in _disposers) {
      disposer();
    }
  }
}
