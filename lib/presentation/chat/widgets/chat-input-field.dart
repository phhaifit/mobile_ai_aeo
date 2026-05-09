import 'package:flutter/material.dart';

/// Reusable chat input field widget with send button
class ChatInputFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isLoading;
  final bool canSend;
  final Function(String)? onChanged;

  const ChatInputFieldWidget({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    this.isLoading = false,
    this.canSend = true,
    this.onChanged,
  }) : super(key: key);

  @override
  State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  setState(() {});
                },
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade500,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading || !widget.canSend
                    ? null
                    : () {
                        final message = widget.controller.text;
                        if (message.trim().isNotEmpty) {
                          widget.onSendMessage(message);
                          widget.controller.clear();
                        }
                      },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: widget.canSend
                              ? Colors.white
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
