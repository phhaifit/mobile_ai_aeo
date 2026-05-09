import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:boilerplate/utils/app_navigator_key.dart';
import 'package:flutter/material.dart';

class AssistantChatComposer extends StatelessWidget {
  const AssistantChatComposer({
    super.key,
    this.embedded = false,
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  /// When true, avoid [IconButton] tooltips (no [Overlay] above [Navigator]).
  final bool embedded;

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: AssistantChatColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              if (embedded)
                Semantics(
                  button: true,
                  label: 'Attachments',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showAttachmentsHint(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.add, color: AssistantChatColors.iconMuted),
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: () => _showAttachmentsHint(context),
                  icon: const Icon(Icons.add, color: AssistantChatColors.iconMuted),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Message AI Assistant...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Material(
                  color: AssistantChatColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isSending ? null : onSend,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: isSending ? Colors.white70 : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ai can make mistakes. consider verifying important information.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AssistantChatColors.disclaimer,
          ),
        ),
      ],
    );
  }

  void _showAttachmentsHint(BuildContext context) {
    final rootCtx = appNavigatorKey.currentContext ?? context;
    ScaffoldMessenger.maybeOf(rootCtx)?.showSnackBar(
      const SnackBar(
        content: Text('Attachments will be available with the API.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
