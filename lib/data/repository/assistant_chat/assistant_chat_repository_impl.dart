import 'dart:convert';

import 'package:boilerplate/data/network/apis/assistant/assistant_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_role.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_default_suggestions.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_session_summary.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_send_message_input.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

class AssistantChatRepositoryImpl implements AssistantChatRepository {
  AssistantChatRepositoryImpl(
    this._api,
    this._prefs,
  );

  final AssistantApi _api;
  final SharedPreferenceHelper _prefs;

  static const int _maxRecentSessions = 30;

  @override
  Future<AssistantChatBootstrap> loadChat({String? conversationId}) async {
    final suggestions = defaultAssistantSuggestions();
    final sid = conversationId?.trim();
    if (sid != null && sid.isNotEmpty) {
      final messages = await _api.getSession(sid);
      return AssistantChatBootstrap(
        suggestions: suggestions,
        messages: messages,
      );
    }
    return AssistantChatBootstrap(
      suggestions: suggestions,
      messages: const [],
    );
  }

  @override
  Future<AssistantChatMessage> sendUserMessage({
    required AssistantSendMessageInput input,
  }) async {
    final text = input.userText.trim();
    if (text.isEmpty) {
      throw const AssistantApiException('Message is empty');
    }

    final sid = input.sessionId?.trim();
    final hasSession = sid != null && sid.isNotEmpty;

    final List<Map<String, String>>? historyJson = hasSession
        ? null
        : _historyMaps(input.priorMessages);

    final replyText = await _api.postChat(
      message: text,
      sessionId: hasSession ? sid : null,
      history: historyJson,
    );

    if (hasSession) {
      await _upsertRecent(
        AssistantSessionSummary(
          id: sid,
          title: _sessionTitle(text),
          updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    return AssistantChatMessage(
      id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
      role: AssistantChatRole.assistant,
      sentAt: DateTime.now(),
      payload: AssistantPlainTextPayload(replyText),
    );
  }

  @override
  Future<List<AssistantSessionSummary>> readRecentSessions() async {
    final raw = await _prefs.getAssistantRecentSessionsRaw();
    final list = raw.map(AssistantSessionSummary.fromJson).toList();
    list.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return list;
  }

  @override
  Future<void> deleteSessionRemote(String sessionId) async {
    final id = sessionId.trim();
    if (id.isEmpty) return;
    await _api.deleteSession(id);
    await _removeRecent(id);
  }

  List<Map<String, String>> _historyMaps(List<AssistantChatMessage> msgs) {
    final out = <Map<String, String>>[];
    for (final m in msgs) {
      final role = m.isUser ? 'user' : 'bot';
      final content = _plainContent(m);
      if (content.isEmpty) continue;
      out.add({'role': role, 'content': content});
    }
    return out;
  }

  String _plainContent(AssistantChatMessage m) {
    final p = m.payload;
    if (p is UserTextPayload) return p.text;
    if (p is AssistantPlainTextPayload) return p.text;
    if (p is AssistantTypingPayload) return '';
    return '';
  }

  String _sessionTitle(String latestUserText) {
    final t = latestUserText.trim();
    if (t.length <= 42) return t;
    return '${t.substring(0, 39)}...';
  }

  Future<void> _upsertRecent(AssistantSessionSummary entry) async {
    final list = await readRecentSessions();
    list.removeWhere((e) => e.id == entry.id);
    final next = [entry, ...list];
    final capped = next.take(_maxRecentSessions).toList();
    await _prefs.saveAssistantRecentSessionsRaw(
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _removeRecent(String id) async {
    final list = await readRecentSessions();
    list.removeWhere((e) => e.id == id);
    await _prefs.saveAssistantRecentSessionsRaw(
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}
