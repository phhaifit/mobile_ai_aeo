/// Generic data point used by both brand and content trend charts.
class ChartDataPoint {
  final String label; // e.g. "May 1", "Week 18", "May 2026"
  final double value;
  final DateTime bucketStart;

  ChartDataPoint({
    required this.label,
    required this.value,
    required this.bucketStart,
  });
}
