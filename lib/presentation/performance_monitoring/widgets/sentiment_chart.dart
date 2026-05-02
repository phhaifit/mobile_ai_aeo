import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Donut chart for sentiment breakdown.
class SentimentChart extends StatelessWidget {
  final int positive;
  final int neutral;
  final int negative;
  final bool isLoading;

  const SentimentChart({
    Key? key,
    required this.positive,
    required this.neutral,
    required this.negative,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sentiment Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final total = positive + neutral + negative;
    if (total == 0) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No sentiment data available',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Row(
      children: [
        // Donut chart
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                PieChartSectionData(
                  value: positive.toDouble(),
                  color: const Color(0xFF10B981),
                  title: '',
                  radius: 28,
                ),
                PieChartSectionData(
                  value: neutral.toDouble(),
                  color: const Color(0xFF94A3B8),
                  title: '',
                  radius: 28,
                ),
                if (negative > 0)
                  PieChartSectionData(
                    value: negative.toDouble(),
                    color: const Color(0xFFEF4444),
                    title: '',
                    radius: 28,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendRow('Positive', positive, total, const Color(0xFF10B981)),
              const SizedBox(height: 10),
              _legendRow('Neutral', neutral, total, const Color(0xFF94A3B8)),
              const SizedBox(height: 10),
              _legendRow('Negative', negative, total, const Color(0xFFEF4444)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
