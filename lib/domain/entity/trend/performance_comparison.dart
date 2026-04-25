class PerformanceComparison {
  final String metricName;
  final double currentValue;
  final double previousValue;
  final double changePercent;
  final bool isImproved;

  PerformanceComparison({
    required this.metricName,
    required this.currentValue,
    required this.previousValue,
    required this.changePercent,
    required this.isImproved,
  });

  /// Builds a list of [PerformanceComparison] entries by diffing two
  /// `MetricsOverviewDto` snapshots (current period vs. previous period).
  static List<PerformanceComparison> fromOverviewDiff(
    Map<String, dynamic> current,
    Map<String, dynamic> previous,
  ) {
    final comparisons = <PerformanceComparison>[];

    void _add(String name, double cur, double prev, {bool lowerIsBetter = false}) {
      final change = prev != 0 ? ((cur - prev) / prev * 100) : 0.0;
      comparisons.add(PerformanceComparison(
        metricName: name,
        currentValue: cur,
        previousValue: prev,
        changePercent: double.parse(change.toStringAsFixed(1)),
        isImproved: lowerIsBetter ? cur <= prev : cur >= prev,
      ));
    }

    _add(
      'Brand Visibility',
      (current['brandMentionsRate'] as num?)?.toDouble() ?? 0,
      (previous['brandMentionsRate'] as num?)?.toDouble() ?? 0,
    );
    _add(
      'Brand Mentions',
      (current['brandMentions'] as num?)?.toDouble() ?? 0,
      (previous['brandMentions'] as num?)?.toDouble() ?? 0,
    );
    _add(
      'Link Visibility',
      (current['linkReferencesRate'] as num?)?.toDouble() ?? 0,
      (previous['linkReferencesRate'] as num?)?.toDouble() ?? 0,
    );
    _add(
      'Link References',
      (current['linkReferences'] as num?)?.toDouble() ?? 0,
      (previous['linkReferences'] as num?)?.toDouble() ?? 0,
    );

    // Visibility score
    _add(
      'Visibility Score',
      (current['brandVisibilityScore'] as num?)?.toDouble() ?? 0,
      (previous['brandVisibilityScore'] as num?)?.toDouble() ?? 0,
    );

    return comparisons;
  }
}

