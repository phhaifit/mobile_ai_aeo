import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';

part 'overview_store.g.dart';

class OverviewStore = _OverviewStore with _$OverviewStore;

abstract class _OverviewStore with Store {
  final String TAG = "_OverviewStore";

  // store for handling errors
  final ErrorStore errorStore;

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

  @observable
  bool isLoading = false;

  // store variables: sentiment data-----------------------------------------
  @observable
  double sentimentPositivePercent = 0.0;

  @observable
  int sentimentPositiveCount = 0;

  @observable
  double sentimentNeutralPercent = 0.0;

  @observable
  int sentimentNeutralCount = 0;

  @observable
  double sentimentNegativePercent = 0.0;

  @observable
  int sentimentNegativeCount = 0;

  // store variables: share of voice data------------------------------------
  @observable
  List<LLMShareData> llmShareData = [];

  // constructor:---------------------------------------------------------------
  _OverviewStore(this.errorStore);

  // actions:-------------------------------------------------------------------
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
      topReferencedDomains = [
        ReferencedDomain(
          domain: 'techcrunch.com',
          mentions: 285,
          category: 'ChatGPT',
        ),
        ReferencedDomain(
          domain: 'forbes.com',
          mentions: 219,
          category: 'Gemini',
        ),
        ReferencedDomain(
          domain: 'medium.com',
          mentions: 187,
          category: 'AI Overview',
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

      // Initialize sentiment data
      sentimentPositivePercent = 64.5;
      sentimentPositiveCount = 423;
      sentimentNeutralPercent = 22.3;
      sentimentNeutralCount = 147;
      sentimentNegativePercent = 13.2;
      sentimentNegativeCount = 87;

      // Initialize share of voice data
      llmShareData = [
        LLMShareData(
          llmName: 'ChatGPT',
          brandPercent: 28.5,
          competitorAvgPercent: 18.2,
        ),
        LLMShareData(
          llmName: 'Gemini',
          brandPercent: 35.2,
          competitorAvgPercent: 22.7,
        ),
        LLMShareData(
          llmName: 'Claude',
          brandPercent: 24.8,
          competitorAvgPercent: 16.5,
        ),
        LLMShareData(
          llmName: 'Perplexity',
          brandPercent: 18.9,
          competitorAvgPercent: 14.2,
        ),
        LLMShareData(
          llmName: 'Copilot',
          brandPercent: 22.4,
          competitorAvgPercent: 19.8,
        ),
      ];

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(error.toString());
    } finally {
      isLoading = false;
    }
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

/// Model class for LLM Share of Voice data
class LLMShareData {
  final String llmName;
  final double brandPercent;
  final double competitorAvgPercent;

  LLMShareData({
    required this.llmName,
    required this.brandPercent,
    required this.competitorAvgPercent,
  });
}
