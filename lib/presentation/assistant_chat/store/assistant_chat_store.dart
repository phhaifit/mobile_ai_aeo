import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_role.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:boilerplate/domain/usecase/assistant_chat/load_assistant_chat_usecase.dart';
import 'package:boilerplate/domain/usecase/assistant_chat/send_assistant_chat_message_usecase.dart';
import 'package:mobx/mobx.dart';

part 'assistant_chat_store.g.dart';

class AssistantChatStore = _AssistantChatStore with _$AssistantChatStore;

abstract class _AssistantChatStore with Store {
  _AssistantChatStore(
    this.errorStore,
    this._loadAssistantChatUseCase,
    this._sendAssistantChatMessageUseCase,
  );

  final ErrorStore errorStore;
  final LoadAssistantChatUseCase _loadAssistantChatUseCase;
  final SendAssistantChatMessageUseCase _sendAssistantChatMessageUseCase;

  /// Optional thread id when the backend supports multiple conversations.
  String? conversationId;

  @observable
  bool isLoadingBootstrap = false;

  @observable
  bool isSending = false;

  @observable
  List<AssistantChatSuggestion> suggestions = [];

  @observable
  List<AssistantChatMessage> messages = [];

  @action
  Future<void> loadChat() async {
    isLoadingBootstrap = true;
    errorStore.reset('');
    try {
      final bootstrap = await _loadAssistantChatUseCase(
        params: LoadAssistantChatParams(conversationId: conversationId),
      );
      suggestions = List<AssistantChatSuggestion>.from(bootstrap.suggestions);
      messages = List<AssistantChatMessage>.from(bootstrap.messages);
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingBootstrap = false;
    }
  }

  @action
  Future<void> refreshChat() async {
    await loadChat();
  }

  @action
  Future<void> sendMessage(String rawText) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty || isSending) return;

    final userMessage = AssistantChatMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      role: AssistantChatRole.user,
      sentAt: DateTime.now(),
      payload: UserTextPayload(trimmed),
    );

    messages = [...messages, userMessage];
    isSending = true;
    errorStore.reset('');

    try {
      final reply = await _sendAssistantChatMessageUseCase(
        params: SendAssistantChatMessageParams(
          conversationId: conversationId,
          text: trimmed,
        ),
      );
      messages = [...messages, reply];
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
    } finally {
      isSending = false;
    }
  }
}
