import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entity/trend/chart_data_point.dart';

/// Bar chart showing content publish count by date bucket.
class ContentTrendChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final bool isLoading;

  const ContentTrendChart({Key? key, required this.data, this.isLoading = false}) : super(key: key);

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
          const Text('Content Publishing Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Number of contents published over time', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 24),
          if (isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else if (data.isEmpty)
            const SizedBox(height: 200, child: Center(child: Text('No content data in this period', style: TextStyle(color: Colors.grey))))
          else
            SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return const Center(
        child: Text('No content data in this period', style: TextStyle(color: Colors.grey)),
      );
    }

    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 1.0 : (maxVal * 1.3);
    final double maxX = data.length > 1 ? (data.length - 1).toDouble() : 1.0;

    const Color lineColor = Color(0xFF8B5CF6); // Purple color from the original bar chart

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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
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
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
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
                '${data[idx].label}\n${s.y.toInt()} items',
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
