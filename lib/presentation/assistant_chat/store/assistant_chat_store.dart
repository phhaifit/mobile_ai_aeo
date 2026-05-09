import 'dart:developer' as developer;

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

  static const String _pendingAiMessageId = 'msg_ai_pending';

  static const String _sendFailureBubbleText =
      'We could not get a reply from the server. What you see is still from saved data — please try sending again in a moment.';

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

  /// Bumped when starting a new chat or opening another session (clears composer draft).
  @observable
  int composerClearNonce = 0;

  String _newSessionId() =>
      'sess_${DateTime.now().microsecondsSinceEpoch}';

  String _formatError(Object e) {
    if (e is AssistantApiException) return e.message;
    return e.toString();
  }

  void _log(String message, Object e, StackTrace st) {
    developer.log(
      message,
      name: 'AssistantChatStore',
      error: e,
      stackTrace: st,
    );
  }

  @action
  Future<void> loadRecentSessions() async {
    try {
      final list = await _getAssistantRecentSessionsUseCase(
        params: const AssistantNoParams(),
      );
      recentSessions = List<AssistantSessionSummary>.from(list);
    } catch (e, st) {
      recentSessions = [];
      _log('loadRecentSessions failed', e, st);
    }
  }

  @action
  Future<void> loadChat() async {
    isLoadingBootstrap = true;
    errorStore.reset('');
    try {
      final id = sessionId;
      final bootstrap = await _loadAssistantChatUseCase(
        params: LoadAssistantChatParams(conversationId: id),
      );
      suggestions = List<AssistantChatSuggestion>.from(bootstrap.suggestions);
      messages = List<AssistantChatMessage>.from(bootstrap.messages);
      sessionId ??= _newSessionId();
    } catch (e, st) {
      _log('loadChat failed', e, st);
      messages = [];
      suggestions = List<AssistantChatSuggestion>.from(
        defaultAssistantSuggestions(),
      );
      sessionId ??= _newSessionId();
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
    errorStore.reset('');
    await loadRecentSessions();
    composerClearNonce++;
  }

  @action
  Future<void> openSession(String id) async {
    if (id.trim().isEmpty) return;
    sessionId = id.trim();
    errorStore.reset('');
    composerClearNonce++;
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
      errorStore.reset('');
    } catch (e, st) {
      _log('deleteSession failed: ${_formatError(e)}', e, st);
    }
  }

  List<AssistantChatMessage> _withoutPending(List<AssistantChatMessage> list) {
    return list.where((m) => m.id != _pendingAiMessageId).toList();
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

    final typingMessage = AssistantChatMessage(
      id: _pendingAiMessageId,
      role: AssistantChatRole.assistant,
      sentAt: DateTime.now(),
      payload: const AssistantTypingPayload(),
    );

    messages = [...messages, userMessage, typingMessage];
    isSending = true;
    errorStore.reset('');

    try {
      final reply = await _sendAssistantChatMessageUseCase(
        params: SendAssistantChatMessageParams(
          conversationId: sid,
          text: trimmed,
          priorMessages: prior,
        ),
      );
      final base = _withoutPending(messages);
      messages = [...base, reply];
      await loadRecentSessions();
    } catch (e, st) {
      _log('sendMessage failed: ${_formatError(e)}', e, st);
      final base = _withoutPending(messages);
      final friendly = AssistantChatMessage(
        id: 'msg_ai_err_${DateTime.now().millisecondsSinceEpoch}',
        role: AssistantChatRole.assistant,
        sentAt: DateTime.now(),
        payload: const AssistantPlainTextPayload(_sendFailureBubbleText),
      );
      messages = [...base, friendly];
    } finally {
      isSending = false;
    }
  }
}
