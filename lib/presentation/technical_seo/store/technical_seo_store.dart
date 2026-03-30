import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_history_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_audit_status_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/get_crawler_events_usecase.dart';
import 'package:boilerplate/domain/usecase/seo/run_seo_audit_usecase.dart';
import 'package:mobx/mobx.dart';

part 'technical_seo_store.g.dart';

class TechnicalSeoStore = _TechnicalSeoStore with _$TechnicalSeoStore;

abstract class _TechnicalSeoStore with Store {
  static const int _pollIntervalSec = 5;
  static const int _maxPollDurationSec = 300;

  final RunSeoAuditUseCase _runSeoAuditUseCase;
  final GetAuditStatusUseCase _getAuditStatusUseCase;
  final GetAuditHistoryUseCase _getAuditHistoryUseCase;
  final GetCrawlerEventsUseCase _getCrawlerEventsUseCase;
  final ErrorStore errorStore;

  Timer? _pollTimer;
  int _pollElapsedSec = 0;

  _TechnicalSeoStore(
    this._runSeoAuditUseCase,
    this._getAuditStatusUseCase,
    this._getAuditHistoryUseCase,
    this._getCrawlerEventsUseCase,
    this.errorStore,
  );

  @observable
  String inputUrl = '';

  @observable
  SeoAuditResult? currentAudit;

  @observable
  ObservableList<SeoAuditResult> auditHistory = ObservableList();

  @observable
  ObservableList<CrawlerEvent> crawlerEvents = ObservableList();

  @observable
  bool loading = false;

  @observable
  bool isPolling = false;

  @action
  void setUrl(String url) {
    inputUrl = url;
  }

  @action
  Future<void> startAudit() async {
    if (inputUrl.isEmpty) return;
    loading = true;
    errorStore.errorMessage = '';
    _stopPolling();

    try {
      final auditId = await _runSeoAuditUseCase.call(
        params: SeoAuditRequest(url: inputUrl),
      );
      _startPolling(auditId);
    } catch (e) {
      errorStore.errorMessage = e.toString();
      loading = false;
    }
  }

  @action
  Future<void> loadHistory() async {
    try {
      final results = await _getAuditHistoryUseCase.call(params: null);
      auditHistory = ObservableList.of(results);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  Future<void> loadCrawlerEvents() async {
    if (inputUrl.isEmpty) return;
    try {
      final events = await _getCrawlerEventsUseCase.call(params: inputUrl);
      crawlerEvents = ObservableList.of(events);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  void _startPolling(String auditId) {
    isPolling = true;
    _pollElapsedSec = 0;
    _pollTimer = Timer.periodic(
      Duration(seconds: _pollIntervalSec),
      (_) => _pollAuditStatus(auditId),
    );
  }

  @action
  Future<void> _pollAuditStatus(String auditId) async {
    _pollElapsedSec += _pollIntervalSec;
    if (_pollElapsedSec >= _maxPollDurationSec) {
      _stopPolling();
      loading = false;
      errorStore.errorMessage = 'Audit timed out. Please try again.';
      return;
    }

    try {
      final result = await _getAuditStatusUseCase.call(params: auditId);
      currentAudit = result;

      if (result.status == AuditStatus.completed ||
          result.status == AuditStatus.failed) {
        _stopPolling();
        loading = false;
        if (result.status == AuditStatus.completed) {
          await loadHistory();
        }
      }
    } catch (e) {
      _stopPolling();
      loading = false;
      errorStore.errorMessage = e.toString();
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    isPolling = false;
  }

  void dispose() {
    _stopPolling();
  }
}
