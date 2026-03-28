// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technical_seo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TechnicalSeoStore on _TechnicalSeoStore, Store {
  late final _$inputUrlAtom =
      Atom(name: '_TechnicalSeoStore.inputUrl', context: context);

  @override
  String get inputUrl {
    _$inputUrlAtom.reportRead();
    return super.inputUrl;
  }

  @override
  set inputUrl(String value) {
    _$inputUrlAtom.reportWrite(value, super.inputUrl, () {
      super.inputUrl = value;
    });
  }

  late final _$currentAuditAtom =
      Atom(name: '_TechnicalSeoStore.currentAudit', context: context);

  @override
  SeoAuditResult? get currentAudit {
    _$currentAuditAtom.reportRead();
    return super.currentAudit;
  }

  @override
  set currentAudit(SeoAuditResult? value) {
    _$currentAuditAtom.reportWrite(value, super.currentAudit, () {
      super.currentAudit = value;
    });
  }

  late final _$auditHistoryAtom =
      Atom(name: '_TechnicalSeoStore.auditHistory', context: context);

  @override
  ObservableList<SeoAuditResult> get auditHistory {
    _$auditHistoryAtom.reportRead();
    return super.auditHistory;
  }

  @override
  set auditHistory(ObservableList<SeoAuditResult> value) {
    _$auditHistoryAtom.reportWrite(value, super.auditHistory, () {
      super.auditHistory = value;
    });
  }

  late final _$crawlerEventsAtom =
      Atom(name: '_TechnicalSeoStore.crawlerEvents', context: context);

  @override
  ObservableList<CrawlerEvent> get crawlerEvents {
    _$crawlerEventsAtom.reportRead();
    return super.crawlerEvents;
  }

  @override
  set crawlerEvents(ObservableList<CrawlerEvent> value) {
    _$crawlerEventsAtom.reportWrite(value, super.crawlerEvents, () {
      super.crawlerEvents = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_TechnicalSeoStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$isPollingAtom =
      Atom(name: '_TechnicalSeoStore.isPolling', context: context);

  @override
  bool get isPolling {
    _$isPollingAtom.reportRead();
    return super.isPolling;
  }

  @override
  set isPolling(bool value) {
    _$isPollingAtom.reportWrite(value, super.isPolling, () {
      super.isPolling = value;
    });
  }

  late final _$startAuditAsyncAction =
      AsyncAction('_TechnicalSeoStore.startAudit', context: context);

  @override
  Future<void> startAudit() {
    return _$startAuditAsyncAction.run(() => super.startAudit());
  }

  late final _$loadHistoryAsyncAction =
      AsyncAction('_TechnicalSeoStore.loadHistory', context: context);

  @override
  Future<void> loadHistory() {
    return _$loadHistoryAsyncAction.run(() => super.loadHistory());
  }

  late final _$loadCrawlerEventsAsyncAction =
      AsyncAction('_TechnicalSeoStore.loadCrawlerEvents', context: context);

  @override
  Future<void> loadCrawlerEvents() {
    return _$loadCrawlerEventsAsyncAction.run(() => super.loadCrawlerEvents());
  }

  late final _$_pollAuditStatusAsyncAction =
      AsyncAction('_TechnicalSeoStore._pollAuditStatus', context: context);

  @override
  Future<void> _pollAuditStatus(String auditId) {
    return _$_pollAuditStatusAsyncAction
        .run(() => super._pollAuditStatus(auditId));
  }

  late final _$_TechnicalSeoStoreActionController =
      ActionController(name: '_TechnicalSeoStore', context: context);

  @override
  void setUrl(String url) {
    final _$actionInfo = _$_TechnicalSeoStoreActionController.startAction(
        name: '_TechnicalSeoStore.setUrl');
    try {
      return super.setUrl(url);
    } finally {
      _$_TechnicalSeoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
inputUrl: ${inputUrl},
currentAudit: ${currentAudit},
auditHistory: ${auditHistory},
crawlerEvents: ${crawlerEvents},
loading: ${loading},
isPolling: ${isPolling}
    ''';
  }
}
