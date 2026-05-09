import 'package:flutter/material.dart';
import 'package:boilerplate/domain/entity/chat/chat-message.dart';
import 'package:boilerplate/constants/app_theme.dart';

/// Widget for displaying a single chat message bubble
class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const ChatBubbleWidget({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple.shade200,
                child: Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.purple.shade500 : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(
                    isUser ? 16 : 4,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 4 : 16,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                softWrap: true,
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.purple.shade500,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
