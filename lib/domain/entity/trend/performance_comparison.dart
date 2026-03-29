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
}
