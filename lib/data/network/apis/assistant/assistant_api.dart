import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_role.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:dio/dio.dart';

/// FastAPI assistant endpoints (see `/docs`, `/openapi.json` on the AI service).
class AssistantApi {
  AssistantApi(this._dioClient);

  final DioClient _dioClient;

  /// POST /assistant/chat
  Future<String> postChat({
    required String message,
    String? sessionId,
    List<Map<String, String>>? history,
  }) async {
    final body = <String, dynamic>{
      'message': message,
    };
    final sid = sessionId?.trim();
    if (sid != null && sid.isNotEmpty) {
      body['session_id'] = sid;
    }
    if (history != null && history.isNotEmpty) {
      body['history'] = history;
    }

    try {
      final response = await _dioClient.dio.post(
        Endpoints.assistantChat,
        data: body,
      );
      return _parseChatReply(response);
    } on DioException catch (e) {
      throw AssistantApiException.fromDio(e);
    }
  }

  /// GET /assistant/session/{session_id}
  Future<List<AssistantChatMessage>> getSession(String sessionId) async {
    try {
      final response = await _dioClient.dio.get(
        Endpoints.assistantSession(sessionId.trim()),
      );
      return _parseSessionMessages(response, sessionId.trim());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw AssistantApiException.fromDio(e);
    }
  }

  /// DELETE /assistant/session/{session_id}
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await _dioClient.dio.delete(
        Endpoints.assistantSession(sessionId.trim()),
      );
      _ensureSuccessMap(response.data);
    } on DioException catch (e) {
      throw AssistantApiException.fromDio(e);
    }
  }

  String _parseChatReply(Response response) {
    final data = response.data;
    if (data is! Map) {
      throw const AssistantApiException('Invalid chat response');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['status']?.toString() != 'success') {
      throw AssistantApiException(
        map['detail']?.toString() ?? map['message']?.toString() ?? 'Chat failed',
      );
    }
    final reply = map['reply']?.toString();
    if (reply == null || reply.isEmpty) {
      throw const AssistantApiException('Empty reply from assistant');
    }
    return reply;
  }

  List<AssistantChatMessage> _parseSessionMessages(
    Response response,
    String sessionId,
  ) {
    final data = response.data;
    if (data is! Map) {
      throw const AssistantApiException('Invalid session response');
    }
    final map = Map<String, dynamic>.from(data);
    if (map['status']?.toString() != 'success') {
      throw AssistantApiException(
        map['detail']?.toString() ?? 'Failed to load session',
      );
    }
    final raw = map['messages'];
    if (raw is! List) return [];
    final out = <AssistantChatMessage>[];
    var i = 0;
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final roleRaw = m['role']?.toString() ?? '';
      final content = m['content']?.toString() ?? '';
      if (content.isEmpty) continue;
      final role = roleRaw.toLowerCase();
      final isUser = role == 'user';
      out.add(
        AssistantChatMessage(
          id: '${sessionId}_$i',
          role: isUser ? AssistantChatRole.user : AssistantChatRole.assistant,
          sentAt: DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch + i,
          ),
          payload: isUser
              ? UserTextPayload(content)
              : AssistantPlainTextPayload(content),
        ),
      );
      i++;
    }
    return out;
  }

  void _ensureSuccessMap(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    if (map['status']?.toString() != 'success') {
      throw AssistantApiException(
        map['detail']?.toString() ?? 'Delete session failed',
      );
    }
  }
}

/// Thrown when assistant HTTP calls fail or return an error payload.
class AssistantApiException implements Exception {
  const AssistantApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory AssistantApiException.fromDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String msg;
    if (data is Map) {
      msg = data['detail']?.toString() ??
          data['message']?.toString() ??
          e.message ??
          'Request failed';
    } else if (data is String && data.trim().isNotEmpty) {
      msg = data.trim();
    } else {
      msg = e.message ?? 'Network error';
    }
    if (code == 503) {
      msg = 'Assistant storage is unavailable ($msg).';
    } else if (code == 400) {
      msg = 'Invalid request ($msg).';
    } else if (code == 500) {
      msg = 'Assistant error ($msg).';
    }
    return AssistantApiException(msg, statusCode: code);
  }

  @override
  String toString() => message;
}
