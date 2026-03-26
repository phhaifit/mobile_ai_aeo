class InternalLinkSuggestion {
  final String sourcePage;
  final String targetPage;
  final String anchorText;
  final int relevanceScore;

  InternalLinkSuggestion({
    required this.sourcePage,
    required this.targetPage,
    required this.anchorText,
    required this.relevanceScore,
  });
}
