import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart showing content distribution by topic.
class ContentTopicChart extends StatelessWidget {
  final Map<String, int> topicCounts;
  final bool isLoading;

  const ContentTopicChart({Key? key, required this.topicCounts, this.isLoading = false}) : super(key: key);

  static const _colors = [
    Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFF06B6D4), Color(0xFF84CC16),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Content by Topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
          else if (topicCounts.isEmpty)
            const SizedBox(height: 160, child: Center(child: Text('No topic data', style: TextStyle(color: Colors.grey))))
          else
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final entries = topicCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return Row(
      children: [
        SizedBox(
          width: 130, height: 130,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: List.generate(entries.length, (i) => PieChartSectionData(
              value: entries[i].value.toDouble(),
              color: _colors[i % _colors.length],
              title: '', radius: 26,
            )),
          )),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length > 5 ? 5 : entries.length, (i) {
              final pct = total > 0 ? (entries[i].value / total * 100).toStringAsFixed(0) : '0';
              final name = entries[i].key.length > 25 ? '${entries[i].key.substring(0, 22)}...' : entries[i].key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(
                    color: _colors[i % _colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(name, style: TextStyle(fontSize: 11, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                  Text('$pct%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }
}
