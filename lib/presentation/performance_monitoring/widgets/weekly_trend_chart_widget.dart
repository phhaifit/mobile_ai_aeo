import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entity/trend/trend_period.dart';

class WeeklyTrendChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String selectedMetric;
  final TrendPeriod selectedPeriod;
  final Function(String) onMetricChanged;
  final Function(TrendPeriod) onPeriodChanged;
  final bool isLoading;

  const WeeklyTrendChartWidget({
    Key? key,
    required this.labels,
    required this.values,
    required this.selectedMetric,
    required this.selectedPeriod,
    required this.onMetricChanged,
    required this.onPeriodChanged,
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
          _buildHeader(),
          SizedBox(height: 20),
          _buildMetricTabs(),
          SizedBox(height: 30),
          if (isLoading)
            SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weekly Trend',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<TrendPeriod>(
          value: selectedPeriod,
          icon: Icon(Icons.arrow_drop_down),
          underline: SizedBox(),
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          onChanged: (TrendPeriod? newValue) {
            if (newValue != null) {
              onPeriodChanged(newValue);
            }
          },
          items: [
            DropdownMenuItem(value: TrendPeriod.last4Weeks, child: Text('Last 4 Weeks')),
            DropdownMenuItem(value: TrendPeriod.last8Weeks, child: Text('Last 8 Weeks')),
            DropdownMenuItem(value: TrendPeriod.last12Weeks, child: Text('Last 12 Weeks')),
            DropdownMenuItem(value: TrendPeriod.last24Weeks, child: Text('Last 24 Weeks')),
          ],
        )
      ],
    );
  }

  Widget _buildMetricTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMetricTab('overallScore', 'Overall Score'),
          _buildMetricTab('brandVisibility', 'Visibility'),
          _buildMetricTab('brandMentions', 'Mentions'),
          _buildMetricTab('sentimentPositive', 'Sentiment (+)'),
          _buildMetricTab('linkVisibility', 'Links'),
        ],
      ),
    );
  }

  Widget _buildMetricTab(String key, String title) {
    final isSelected = selectedMetric == key;
    return GestureDetector(
      onTap: () => onMetricChanged(key),
      child: Container(
        margin: EdgeInsets.only(right: 12.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (values.isEmpty || labels.isEmpty) {
      return Center(child: Text('No data available'));
    }

    final double maxY = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final double minY = values.reduce((a, b) => a < b ? a : b) * 0.8;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4 > 0 ? (maxY - minY) / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(index.toDouble(), values[index]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
