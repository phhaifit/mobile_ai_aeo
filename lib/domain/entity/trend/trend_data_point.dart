class TrendDataPoint {
  final DateTime date;
  final String weekLabel;
  final double brandVisibility;
  final int brandMentions;
  final double linkVisibility;
  final int linkReferences;
  final double sentimentPositive;
  final double sentimentNegative;
  final double overallScore;

  TrendDataPoint({
    required this.date,
    required this.weekLabel,
    required this.brandVisibility,
    required this.brandMentions,
    required this.linkVisibility,
    required this.linkReferences,
    required this.sentimentPositive,
    required this.sentimentNegative,
    required this.overallScore,
  });
}
