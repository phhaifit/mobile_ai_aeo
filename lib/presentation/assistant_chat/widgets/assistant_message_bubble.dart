import 'dart:async';

import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_message_payload.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssistantDateSeparator extends StatelessWidget {
  const AssistantDateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AssistantChatColors.datePillBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AssistantChatColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({super.key, required this.message});

  final AssistantChatMessage message;

  static String _timeLabel(DateTime t) =>
      DateFormat.jm().format(t); // locale-aware time

  @override
  Widget build(BuildContext context) {
    final payload = message.payload;

    if (message.isUser && payload is UserTextPayload) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.82,
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AssistantChatColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    payload.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeLabel(message.sentAt),
              style: const TextStyle(
                fontSize: 11,
                color: AssistantChatColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (!message.isUser && payload is AssistantPlainTextPayload) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.88,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AssistantChatColors.cardShadow,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  payload.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AssistantChatColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!message.isUser && payload is AssistantTypingPayload) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _AssistantTypingBubble(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AssistantTypingBubble extends StatefulWidget {
  const _AssistantTypingBubble();

  static const String _line =
      'One moment, we are preparing a reply for you';

  @override
  State<_AssistantTypingBubble> createState() => _AssistantTypingBubbleState();
}

class _AssistantTypingBubbleState extends State<_AssistantTypingBubble> {
  late final Timer _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cycle ".", "..", "..." (1 → 3 dots) continuously.
    final dotCount = 1 + (_tick % 3);
    final ellipsis = '.' * dotCount;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.88,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AssistantChatColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '${_AssistantTypingBubble._line} $ellipsis',
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AssistantChatColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
