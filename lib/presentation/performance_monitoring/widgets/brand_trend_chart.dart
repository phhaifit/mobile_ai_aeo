import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entity/trend/chart_data_point.dart';

/// Line chart for brand analytics trend with metric toggle.
class BrandTrendChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String selectedMetric;
  final Function(String) onMetricChanged;
  final bool isLoading;

  const BrandTrendChart({
    Key? key,
    required this.data,
    required this.selectedMetric,
    required this.onMetricChanged,
    this.isLoading = false,
  }) : super(key: key);

  static const _metrics = {
    'brandMentions': 'Mentions',
    'linkReferences': 'Link Refs',
    'totalResponses': 'Responses',
  };

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
            'Brand Performance Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMetricTabs(),
          const SizedBox(height: 24),
          if (isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(height: 220, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildMetricTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _metrics.entries.map((e) {
          final isSelected = selectedMetric == e.key;
          return GestureDetector(
            onTap: () => onMetricChanged(e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.grey[700],
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available for this period',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 1.0 : (maxVal * 1.3);

    final Color lineColor;
    switch (selectedMetric) {
      case 'linkReferences':
        lineColor = const Color(0xFFF59E0B);
        break;
      case 'totalResponses':
        lineColor = const Color(0xFF10B981);
        break;
      default:
        lineColor = const Color(0xFF3B82F6);
    }

    final double maxX = data.length > 1 ? (data.length - 1).toDouble() : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _labelInterval(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[idx].label,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.length == 1
                ? [
                    FlSpot(0, data[0].value),
                    FlSpot(1, data[0].value), // duplicate to draw a flat line
                  ]
                : List.generate(
                    data.length,
                    (i) => FlSpot(i.toDouble(), data[i].value),
                  ),
            isCurved: true,
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length <= 31,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: lineColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt() < data.length ? s.x.toInt() : 0;
              return LineTooltipItem(
                '${data[idx].label}\n${s.y.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  double _labelInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 31) return 5;
    return (data.length / 6).ceilToDouble();
  }
}
