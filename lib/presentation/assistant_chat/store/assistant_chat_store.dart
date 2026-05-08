import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/network/apis/assistant/assistant_api.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_role.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_default_suggestions.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_session_summary.dart';
import 'package:boilerplate/domain/usecase/assistant_chat/delete_assistant_session_usecase.dart';
import 'package:boilerplate/domain/usecase/assistant_chat/get_assistant_recent_sessions_usecase.dart';
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
    this._getAssistantRecentSessionsUseCase,
    this._deleteAssistantSessionUseCase,
  );

  final ErrorStore errorStore;
  final LoadAssistantChatUseCase _loadAssistantChatUseCase;
  final SendAssistantChatMessageUseCase _sendAssistantChatMessageUseCase;
  final GetAssistantRecentSessionsUseCase _getAssistantRecentSessionsUseCase;
  final DeleteAssistantSessionUseCase _deleteAssistantSessionUseCase;

  /// Mongo-backed session id (client-generated until server accepts it).
  @observable
  String? sessionId;

  @observable
  bool isLoadingBootstrap = false;

  @observable
  bool isSending = false;

  @observable
  List<AssistantChatSuggestion> suggestions = [];

  @observable
  List<AssistantChatMessage> messages = [];

  @observable
  List<AssistantSessionSummary> recentSessions = [];

  /// User-facing error for Snackbar (cleared on next action).
  @observable
  String? chatError;

  String _newSessionId() =>
      'sess_${DateTime.now().microsecondsSinceEpoch}';

  @action
  void clearChatError() {
    chatError = null;
  }

  String _formatError(Object e) {
    if (e is AssistantApiException) return e.message;
    return e.toString();
  }

  @action
  Future<void> loadRecentSessions() async {
    try {
      final list = await _getAssistantRecentSessionsUseCase(
        params: const AssistantNoParams(),
      );
      recentSessions = List<AssistantSessionSummary>.from(list);
    } catch (e) {
      recentSessions = [];
      chatError = _formatError(e);
      errorStore.setErrorMessage(_formatError(e));
    }
  }

  @action
  Future<void> loadChat() async {
    isLoadingBootstrap = true;
    errorStore.reset('');
    chatError = null;
    try {
      final id = sessionId;
      final bootstrap = await _loadAssistantChatUseCase(
        params: LoadAssistantChatParams(conversationId: id),
      );
      suggestions = List<AssistantChatSuggestion>.from(bootstrap.suggestions);
      messages = List<AssistantChatMessage>.from(bootstrap.messages);
      sessionId ??= _newSessionId();
    } catch (e) {
      final msg = _formatError(e);
      chatError = msg;
      errorStore.setErrorMessage(msg);
    } finally {
      isLoadingBootstrap = false;
    }
  }

  @action
  Future<void> refreshChat() async {
    final prev = List<AssistantChatMessage>.from(messages);
    await loadChat();
    if (messages.isEmpty && prev.isNotEmpty) {
      messages = prev;
    }
  }

  /// New thread: new session id, empty messages, static suggestions.
  @action
  Future<void> startNewChat() async {
    sessionId = _newSessionId();
    messages = [];
    suggestions = List<AssistantChatSuggestion>.from(
      defaultAssistantSuggestions(),
    );
    chatError = null;
    errorStore.reset('');
    await loadRecentSessions();
  }

  @action
  Future<void> openSession(String id) async {
    if (id.trim().isEmpty) return;
    sessionId = id.trim();
    chatError = null;
    errorStore.reset('');
    await loadChat();
    await loadRecentSessions();
  }

  @action
  Future<void> deleteSession(String id) async {
    if (id.trim().isEmpty) return;
    try {
      await _deleteAssistantSessionUseCase(
        params: DeleteAssistantSessionParams(sessionId: id.trim()),
      );
      if (sessionId == id.trim()) {
        await startNewChat();
      } else {
        await loadRecentSessions();
      }
      chatError = null;
      errorStore.reset('');
    } catch (e) {
      final msg = _formatError(e);
      chatError = msg;
      errorStore.setErrorMessage(msg);
    }
  }

  @action
  Future<void> sendMessage(String rawText) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty || isSending) return;

    final prior = List<AssistantChatMessage>.from(messages);
    sessionId ??= _newSessionId();
    final sid = sessionId;

    final userMessage = AssistantChatMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      role: AssistantChatRole.user,
      sentAt: DateTime.now(),
      payload: UserTextPayload(trimmed),
    );

    messages = [...messages, userMessage];
    isSending = true;
    errorStore.reset('');
    chatError = null;

    try {
      final reply = await _sendAssistantChatMessageUseCase(
        params: SendAssistantChatMessageParams(
          conversationId: sid,
          text: trimmed,
          priorMessages: prior,
        ),
      );
      messages = [...messages, reply];
      await loadRecentSessions();
    } catch (e) {
      messages = prior;
      final msg = _formatError(e);
      chatError = msg;
      errorStore.setErrorMessage(msg);
    } finally {
      isSending = false;
    }
  }
}
