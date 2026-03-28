import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entity/trend/performance_comparison.dart';

class PeriodComparisonWidget extends StatelessWidget {
  final List<PerformanceComparison> comparisons;
  final bool isLoading;

  const PeriodComparisonWidget({
    Key? key,
    required this.comparisons,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'This Week vs Last Week',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildLegend(),
          SizedBox(height: 30),
          if (isLoading)
            SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (comparisons.isEmpty)
            SizedBox(
              height: 250,
              child: Center(child: Text('No comparison data available')),
            )
          else
            SizedBox(
              height: 250,
              child: _buildChart(),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('This Week', Colors.blue),
        SizedBox(width: 24),
        _buildLegendItem('Last Week', Colors.grey[400]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // Only use percentage metrics to make scale comparable
    final chartMetrics = comparisons.where((c) =>
        c.metricName.contains('Visibility') || 
        c.metricName.contains('Sentiment')).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // Fixed to 100 since we're using percentage metrics
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final metric = chartMetrics[groupIndex];
              final isCurrent = rodIndex == 0;
              final label = isCurrent ? 'This Week' : 'Last Week';
              return BarTooltipItem(
                '${metric.metricName}\n$label: ${rod.toY.toStringAsFixed(1)}%',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartMetrics.length) {
                  final name = chartMetrics[value.toInt()].metricName;
                  // Shorten names for better fit
                  final shortName = name.replaceAll('Brand ', '')
                      .replaceAll('Sentiment', 'Sent.')
                      .replaceAll('Visibility', 'Vis.');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      shortName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          chartMetrics.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: chartMetrics[index].currentValue,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: chartMetrics[index].previousValue,
                color: Colors.grey[400]!,
                width: 16,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            barsSpace: 4,
          ),
        ),
      ),
    );
  }
}
