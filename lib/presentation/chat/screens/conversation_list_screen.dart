import 'package:flutter/material.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/usecase/chat/get-recent-conversations-usecase.dart';
import 'package:boilerplate/domain/entity/chat/chat-conversation.dart';
import 'package:boilerplate/presentation/chat/screens/chat-bubble-screen.dart';
import 'package:boilerplate/presentation/chat/store/chat_store.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final GetRecentConversationsUseCase _getRecentConversationsUseCase =
      getIt<GetRecentConversationsUseCase>();

  late Future<List<ChatConversation>> _futureConversations;

  @override
  void initState() {
    super.initState();
    _futureConversations = _getRecentConversationsUseCase.call(
      params: GetRecentConversationsParams(limit: 20, useMockData: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ChatConversation>>(
        future: _futureConversations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load conversations'));
          }

          final convos = snapshot.data ?? [];
          if (convos.isEmpty) {
            return Center(child: Text('No conversations yet'));
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: convos.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = convos[index];
              final lastMessage =
                  c.messages.isNotEmpty ? c.messages.last.content : '';
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(c.title ?? 'Conversation'),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Set selected conversation and open ChatBubbleScreen
                    final chatStore = getIt<ChatStore>();
                    chatStore.selectedConversationId = c.id ?? '';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatBubbleScreen(conversationId: c.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
