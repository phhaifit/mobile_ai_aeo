// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatStore on _ChatStore, Store {
  Computed<bool>? _$hasMessagesComputed;

  @override
  bool get hasMessages =>
      (_$hasMessagesComputed ??= Computed<bool>(() => super.hasMessages,
              name: '_ChatStore.hasMessages'))
          .value;
  Computed<bool>? _$canSendMessageComputed;

  @override
  bool get canSendMessage =>
      (_$canSendMessageComputed ??= Computed<bool>(() => super.canSendMessage,
              name: '_ChatStore.canSendMessage'))
          .value;

  late final _$selectedConversationIdAtom =
      Atom(name: '_ChatStore.selectedConversationId', context: context);

  @override
  String get selectedConversationId {
    _$selectedConversationIdAtom.reportRead();
    return super.selectedConversationId;
  }

  @override
  set selectedConversationId(String value) {
    _$selectedConversationIdAtom
        .reportWrite(value, super.selectedConversationId, () {
      super.selectedConversationId = value;
    });
  }

  late final _$messagesAtom =
      Atom(name: '_ChatStore.messages', context: context);

  @override
  List<ChatMessage> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(List<ChatMessage> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$messageInputAtom =
      Atom(name: '_ChatStore.messageInput', context: context);

  @override
  String get messageInput {
    _$messageInputAtom.reportRead();
    return super.messageInput;
  }

  @override
  set messageInput(String value) {
    _$messageInputAtom.reportWrite(value, super.messageInput, () {
      super.messageInput = value;
    });
  }

  late final _$isSendingAtom =
      Atom(name: '_ChatStore.isSending', context: context);

  @override
  bool get isSending {
    _$isSendingAtom.reportRead();
    return super.isSending;
  }

  @override
  set isSending(bool value) {
    _$isSendingAtom.reportWrite(value, super.isSending, () {
      super.isSending = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ChatStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isChatWindowOpenAtom =
      Atom(name: '_ChatStore.isChatWindowOpen', context: context);

  @override
  bool get isChatWindowOpen {
    _$isChatWindowOpenAtom.reportRead();
    return super.isChatWindowOpen;
  }

  @override
  set isChatWindowOpen(bool value) {
    _$isChatWindowOpenAtom.reportWrite(value, super.isChatWindowOpen, () {
      super.isChatWindowOpen = value;
    });
  }

  late final _$initializeChatAsyncAction =
      AsyncAction('_ChatStore.initializeChat', context: context);

  @override
  Future<void> initializeChat() {
    return _$initializeChatAsyncAction.run(() => super.initializeChat());
  }

  late final _$fetchMessagesAsyncAction =
      AsyncAction('_ChatStore.fetchMessages', context: context);

  @override
  Future<void> fetchMessages() {
    return _$fetchMessagesAsyncAction.run(() => super.fetchMessages());
  }

  late final _$sendMessageAsyncAction =
      AsyncAction('_ChatStore.sendMessage', context: context);

  @override
  Future<void> sendMessage(String content) {
    return _$sendMessageAsyncAction.run(() => super.sendMessage(content));
  }

  late final _$sendSuggestionAsyncAction =
      AsyncAction('_ChatStore.sendSuggestion', context: context);

  @override
  Future<void> sendSuggestion(String suggestionText) {
    return _$sendSuggestionAsyncAction
        .run(() => super.sendSuggestion(suggestionText));
  }

  late final _$_ChatStoreActionController =
      ActionController(name: '_ChatStore', context: context);

  @override
  void updateMessageInput(String input) {
    final _$actionInfo = _$_ChatStoreActionController.startAction(
        name: '_ChatStore.updateMessageInput');
    try {
      return super.updateMessageInput(input);
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleChatWindow() {
    final _$actionInfo = _$_ChatStoreActionController.startAction(
        name: '_ChatStore.toggleChatWindow');
    try {
      return super.toggleChatWindow();
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void openChatWindow() {
    final _$actionInfo = _$_ChatStoreActionController.startAction(
        name: '_ChatStore.openChatWindow');
    try {
      return super.openChatWindow();
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeChatWindow() {
    final _$actionInfo = _$_ChatStoreActionController.startAction(
        name: '_ChatStore.closeChatWindow');
    try {
      return super.closeChatWindow();
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearMessages() {
    final _$actionInfo = _$_ChatStoreActionController.startAction(
        name: '_ChatStore.clearMessages');
    try {
      return super.clearMessages();
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetChat() {
    final _$actionInfo =
        _$_ChatStoreActionController.startAction(name: '_ChatStore.resetChat');
    try {
      return super.resetChat();
    } finally {
      _$_ChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedConversationId: ${selectedConversationId},
messages: ${messages},
messageInput: ${messageInput},
isSending: ${isSending},
isLoading: ${isLoading},
isChatWindowOpen: ${isChatWindowOpen},
hasMessages: ${hasMessages},
canSendMessage: ${canSendMessage}
    ''';
  }
}
