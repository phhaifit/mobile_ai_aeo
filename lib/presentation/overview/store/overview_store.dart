import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/overview/overview_metrics.dart';
import 'package:boilerplate/domain/usecase/overview/get_overview_metrics_usecase.dart';

part 'overview_store.g.dart';

class OverviewStore = _OverviewStore with _$OverviewStore;

abstract class _OverviewStore with Store {
  final String TAG = "_OverviewStore";

  /// Keeps overview loading UI visible briefly even when the API returns quickly.
  static const Duration _minOverviewLoadingUi = Duration(milliseconds: 650);

  // store for handling errors
  final ErrorStore errorStore;

  // use cases
  final GetOverviewMetricsUseCase _getOverviewMetricsUseCase;

  // store variables:-----------------------------------------------------------
  @observable
  double brandVisibilityScore = 0.0;

  @observable
  double brandVisibilityPercent = 0.0;

  @observable
  int brandMentions = 0;

  @observable
  double linkVisibilityPercent = 0.0;

  @observable
  int linkReferences = 0;

  @observable
  double suggestedBenchmark = 0.0;

  @observable
  List<ReferencedDomain> topReferencedDomains = [];

  /// Competitor benchmark scores (labels already friendly; from API + fallbacks).
  @observable
  Map<String, int> competitorScores = {};

  @observable
  bool isLoading = false;

  // constructor:---------------------------------------------------------------
  _OverviewStore(this.errorStore, this._getOverviewMetricsUseCase);

  Future<void> _ensureMinLoadingDuration(Stopwatch sw) async {
    final remaining = _minOverviewLoadingUi - sw.elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  // actions:-------------------------------------------------------------------
  @action
  Future<void> fetchOverviewMetrics(String projectId) async {
    isLoading = true;
    final sw = Stopwatch()..start();
    try {
      // Get current date-time in ISO 8601 format
      final now = DateTime.now();
      final dateTime = now.toIso8601String();

      final params = GetOverviewMetricsParams(
        projectId: projectId,
        startDate: dateTime,
        endDate: dateTime,
      );

      print(
          '$TAG.fetchOverviewMetrics: projectId=$projectId, startDate=$dateTime, endDate=$dateTime');

      final metrics = await _getOverviewMetricsUseCase(params: params);
      final filled = applyOverviewMetricsFallbacks(metrics);

      // Map API response (with fallbacks for empty / zero / null) to store observables
      brandVisibilityScore = filled.brandVisibilityScore;
      brandVisibilityPercent = filled.brandMentionsRate;
      brandMentions = filled.brandMentions;
      linkVisibilityPercent = filled.linkReferencesRate;
      linkReferences = filled.linkReferences;
      suggestedBenchmark = 85.0; // TODO: Get from API response

      competitorScores = Map<String, int>.from(filled.competitors);

      // Map domain distribution to referenced domains
      _mapDomainDistribution(filled.domainDistribution);

      errorStore.setErrorMessage('');
    } catch (error) {
      print('$TAG.fetchOverviewMetrics error: ${error.toString()}');
      errorStore.setErrorMessage(error.toString());
      competitorScores = {};
    } finally {
      await _ensureMinLoadingDuration(sw);
      isLoading = false;
    }
  }

  @action
  Future<void> fetchMockData() async {
    isLoading = true;
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));

      // Generate diverse mock data
      brandVisibilityScore = 42.5;
      suggestedBenchmark = 85.0;
      brandVisibilityPercent = 67.3;
      brandMentions = 1248;
      linkVisibilityPercent = 52.8;
      linkReferences = 756;

      // Generate top referenced domains with diverse data
      competitorScores = {
        'Shopify': 75,
        'HubSpot': 60,
        'Salesforce': 90,
      };

      topReferencedDomains = [
        ReferencedDomain(
          domain: 'techcrunch.com',
          mentions: 180,
          category: 'ChatGPT',
        ),
        ReferencedDomain(
          domain: 'techcrunch.com',
          mentions: 65,
          category: 'Gemini',
        ),
        ReferencedDomain(
          domain: 'techcrunch.com',
          mentions: 40,
          category: 'AI Overview',
        ),
        ReferencedDomain(
          domain: 'forbes.com',
          mentions: 120,
          category: 'Gemini',
        ),
        ReferencedDomain(
          domain: 'forbes.com',
          mentions: 99,
          category: 'AI Overview',
        ),
        ReferencedDomain(
          domain: 'medium.com',
          mentions: 112,
          category: 'AI Overview',
        ),
        ReferencedDomain(
          domain: 'medium.com',
          mentions: 75,
          category: 'ChatGPT',
        ),
        ReferencedDomain(
          domain: 'producthunt.com',
          mentions: 156,
          category: 'ChatGPT',
        ),
        ReferencedDomain(
          domain: 'reddit.com',
          mentions: 143,
          category: 'Gemini',
        ),
        ReferencedDomain(
          domain: 'theverge.com',
          mentions: 128,
          category: 'AI Overview',
        ),
      ];

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(error.toString());
    } finally {
      isLoading = false;
    }
  }

  // private methods:-----------------------------------------------------------
  void _mapDomainDistribution(List<DomainDistribution> apiDomains) {
    final byHost = <String, List<ReferencedDomain>>{};

    for (final domain in apiDomains) {
      final host = domain.domain.trim();
      if (host.isEmpty || domain.count <= 0 || domain.distribution.isEmpty) {
        continue;
      }
      final rows = <ReferencedDomain>[];
      domain.distribution.forEach((category, percentage) {
        final categorizedMentions =
            ((domain.count * percentage) / 100).round();
        rows.add(
          ReferencedDomain(
            domain: domain.domain,
            mentions: categorizedMentions,
            category: category,
          ),
        );
      });
      byHost[host] = rows;
    }

    final rankedHosts = byHost.keys.toList()
      ..sort((a, b) {
        int total(String h) =>
            byHost[h]!.fold<int>(0, (s, r) => s + r.mentions);
        return total(b).compareTo(total(a));
      });

    final out = <ReferencedDomain>[];
    const maxDomains = 12;
    for (var i = 0; i < rankedHosts.length && i < maxDomains; i++) {
      out.addAll(byHost[rankedHosts[i]]!);
    }
    topReferencedDomains = out;
  }

  // dispose:-------------------------------------------------------------------
  @action
  dispose() {}
}

class ReferencedDomain {
  final String domain;
  final int mentions;
  final String category;

  ReferencedDomain({
    required this.domain,
    required this.mentions,
    required this.category,
  });
}
