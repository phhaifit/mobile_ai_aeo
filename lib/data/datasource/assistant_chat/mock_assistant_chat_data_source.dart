import 'package:boilerplate/data/datasource/assistant_chat/assistant_chat_data_source.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_role.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_suggestion.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_accent.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_suggestion_icon.dart';

/// In-memory mock matching the product UI. Replace registration in DI with an
/// API-backed [AssistantChatDataSource] without touching domain or stores.
class MockAssistantChatDataSource implements AssistantChatDataSource {
  static const Duration _networkDelay = Duration(milliseconds: 700);

  @override
  Future<AssistantChatBootstrap> fetchBootstrap({String? conversationId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();
    final userAt = DateTime(now.year, now.month, now.day, 10, 42);
    final assistantAt = userAt.add(const Duration(seconds: 5));

    return AssistantChatBootstrap(
      suggestions: const [
        AssistantChatSuggestion(
          id: 'sug_email',
          title: 'Draft an Email',
          description:
              'Help me write a professional follow-up email after a client meeting.',
          accent: AssistantSuggestionAccent.primaryBlue,
          icon: AssistantSuggestionIcon.compose,
        ),
        AssistantChatSuggestion(
          id: 'sug_brainstorm',
          title: 'Brainstorm Ideas',
          description:
              'Give me 5 creative marketing concepts for a new coffee launch.',
          accent: AssistantSuggestionAccent.slateBlue,
          icon: AssistantSuggestionIcon.lightbulb,
        ),
      ],
      messages: [
        AssistantChatMessage(
          id: 'msg_user_q3',
          role: AssistantChatRole.user,
          sentAt: userAt,
          payload: const UserTextPayload(
            'Can you help me summarize the main points from the Q3 report?',
          ),
        ),
        AssistantChatMessage(
          id: 'msg_asst_q3',
          role: AssistantChatRole.assistant,
          sentAt: assistantAt,
          payload: const AssistantStructuredPayload(
            intro:
                'Certainly. Based on the Q3 documentation, here are the primary highlights:',
            bullets: [
              AssistantHighlightBullet(
                title: 'Revenue Growth:',
                description:
                    'Overall revenue increased by 14% compared to Q2, driven largely by the enterprise segment and expansion in key regional markets.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Future<AssistantChatMessage> sendMessage({
    String? conversationId,
    required String userText,
  }) async {
    await Future<void>.delayed(_networkDelay);

    return AssistantChatMessage(
      id: 'msg_asst_${DateTime.now().millisecondsSinceEpoch}',
      role: AssistantChatRole.assistant,
      sentAt: DateTime.now(),
      payload: AssistantPlainTextPayload(
        'Thanks for your message. When the chat API is connected, this reply '
        'will come from the server. You asked: "${userText.trim()}"',
      ),
    );
  }
}
