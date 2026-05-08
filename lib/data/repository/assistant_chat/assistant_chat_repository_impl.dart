import 'package:boilerplate/data/datasource/assistant_chat/assistant_chat_data_source.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_bootstrap.dart';
import 'package:boilerplate/domain/entity/assistant_chat/assistant_chat_message.dart';
import 'package:boilerplate/domain/repository/assistant_chat/assistant_chat_repository.dart';

class AssistantChatRepositoryImpl implements AssistantChatRepository {
  AssistantChatRepositoryImpl(this._dataSource);

  final AssistantChatDataSource _dataSource;

  @override
  Future<AssistantChatBootstrap> loadChat({String? conversationId}) {
    return _dataSource.fetchBootstrap(conversationId: conversationId);
  }

  @override
  Future<AssistantChatMessage> sendUserMessage({
    String? conversationId,
    required String text,
  }) {
    return _dataSource.sendMessage(
      conversationId: conversationId,
      userText: text,
    );
  }
}
