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

    double parseSafeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    _add(
      'Brand Visibility',
      parseSafeDouble(current['brandMentionsRate']),
      parseSafeDouble(previous['brandMentionsRate']),
    );
    _add(
      'Brand Mentions',
      parseSafeDouble(current['brandMentions']),
      parseSafeDouble(previous['brandMentions']),
    );
    _add(
      'Link Visibility',
      parseSafeDouble(current['linkReferencesRate']),
      parseSafeDouble(previous['linkReferencesRate']),
    );
    _add(
      'Link References',
      parseSafeDouble(current['linkReferences']),
      parseSafeDouble(previous['linkReferences']),
    );

    // Visibility score
    _add(
      'Visibility Score',
      parseSafeDouble(current['brandVisibilityScore']),
      parseSafeDouble(previous['brandVisibilityScore']),
    );

    return comparisons;
  }
}

