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
