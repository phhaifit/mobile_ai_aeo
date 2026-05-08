// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssistantChatStore on _AssistantChatStore, Store {
  late final _$sessionIdAtom =
      Atom(name: '_AssistantChatStore.sessionId', context: context);

  @override
  String? get sessionId {
    _$sessionIdAtom.reportRead();
    return super.sessionId;
  }

  @override
  set sessionId(String? value) {
    _$sessionIdAtom.reportWrite(value, super.sessionId, () {
      super.sessionId = value;
    });
  }

  late final _$isLoadingBootstrapAtom =
      Atom(name: '_AssistantChatStore.isLoadingBootstrap', context: context);

  @override
  bool get isLoadingBootstrap {
    _$isLoadingBootstrapAtom.reportRead();
    return super.isLoadingBootstrap;
  }

  @override
  set isLoadingBootstrap(bool value) {
    _$isLoadingBootstrapAtom.reportWrite(value, super.isLoadingBootstrap, () {
      super.isLoadingBootstrap = value;
    });
  }

  late final _$isSendingAtom =
      Atom(name: '_AssistantChatStore.isSending', context: context);

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

  late final _$suggestionsAtom =
      Atom(name: '_AssistantChatStore.suggestions', context: context);

  @override
  List<AssistantChatSuggestion> get suggestions {
    _$suggestionsAtom.reportRead();
    return super.suggestions;
  }

  @override
  set suggestions(List<AssistantChatSuggestion> value) {
    _$suggestionsAtom.reportWrite(value, super.suggestions, () {
      super.suggestions = value;
    });
  }

  late final _$messagesAtom =
      Atom(name: '_AssistantChatStore.messages', context: context);

  @override
  List<AssistantChatMessage> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(List<AssistantChatMessage> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$recentSessionsAtom =
      Atom(name: '_AssistantChatStore.recentSessions', context: context);

  @override
  List<AssistantSessionSummary> get recentSessions {
    _$recentSessionsAtom.reportRead();
    return super.recentSessions;
  }

  @override
  set recentSessions(List<AssistantSessionSummary> value) {
    _$recentSessionsAtom.reportWrite(value, super.recentSessions, () {
      super.recentSessions = value;
    });
  }

  late final _$chatErrorAtom =
      Atom(name: '_AssistantChatStore.chatError', context: context);

  @override
  String? get chatError {
    _$chatErrorAtom.reportRead();
    return super.chatError;
  }

  @override
  set chatError(String? value) {
    _$chatErrorAtom.reportWrite(value, super.chatError, () {
      super.chatError = value;
    });
  }

  late final _$loadRecentSessionsAsyncAction =
      AsyncAction('_AssistantChatStore.loadRecentSessions', context: context);

  @override
  Future<void> loadRecentSessions() {
    return _$loadRecentSessionsAsyncAction
        .run(() => super.loadRecentSessions());
  }

  late final _$loadChatAsyncAction =
      AsyncAction('_AssistantChatStore.loadChat', context: context);

  @override
  Future<void> loadChat() {
    return _$loadChatAsyncAction.run(() => super.loadChat());
  }

  late final _$refreshChatAsyncAction =
      AsyncAction('_AssistantChatStore.refreshChat', context: context);

  @override
  Future<void> refreshChat() {
    return _$refreshChatAsyncAction.run(() => super.refreshChat());
  }

  late final _$startNewChatAsyncAction =
      AsyncAction('_AssistantChatStore.startNewChat', context: context);

  @override
  Future<void> startNewChat() {
    return _$startNewChatAsyncAction.run(() => super.startNewChat());
  }

  late final _$openSessionAsyncAction =
      AsyncAction('_AssistantChatStore.openSession', context: context);

  @override
  Future<void> openSession(String id) {
    return _$openSessionAsyncAction.run(() => super.openSession(id));
  }

  late final _$deleteSessionAsyncAction =
      AsyncAction('_AssistantChatStore.deleteSession', context: context);

  @override
  Future<void> deleteSession(String id) {
    return _$deleteSessionAsyncAction.run(() => super.deleteSession(id));
  }

  late final _$sendMessageAsyncAction =
      AsyncAction('_AssistantChatStore.sendMessage', context: context);

  @override
  Future<void> sendMessage(String rawText) {
    return _$sendMessageAsyncAction.run(() => super.sendMessage(rawText));
  }

  late final _$_AssistantChatStoreActionController =
      ActionController(name: '_AssistantChatStore', context: context);

  @override
  void clearChatError() {
    final _$actionInfo = _$_AssistantChatStoreActionController.startAction(
        name: '_AssistantChatStore.clearChatError');
    try {
      return super.clearChatError();
    } finally {
      _$_AssistantChatStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sessionId: ${sessionId},
isLoadingBootstrap: ${isLoadingBootstrap},
isSending: ${isSending},
suggestions: ${suggestions},
messages: ${messages},
recentSessions: ${recentSessions},
chatError: ${chatError}
    ''';
  }
}
