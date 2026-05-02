import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entity/trend/brand_analytics.dart';

class ModelBreakdownChart extends StatelessWidget {
  final List<ModelAnalytics> models;
  final bool isLoading;

  const ModelBreakdownChart({
    Key? key,
    required this.models,
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
          const Text('AI Model Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Total vs brand mentions per AI engine',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else if (models.isEmpty)
            const SizedBox(height: 200, child: Center(child: Text('No data', style: TextStyle(color: Colors.grey))))
          else
            SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot('Total', const Color(0xFF3B82F6)),
        const SizedBox(width: 20),
        _dot('Brand', const Color(0xFF10B981)),
      ],
    );
  }

  Widget _dot(String l, Color c) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(l, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
  ]);

  Widget _buildChart() {
    double mx = 0;
    for (final m in models) { if (m.totalMentions > mx) mx = m.totalMentions.toDouble(); }
    final maxY = mx < 1 ? 1.0 : (mx * 1.3).ceilToDouble();

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1E293B),
          getTooltipItem: (g, gi, rod, ri) {
            if (gi >= models.length) return null;
            final label = ri == 0 ? 'Total' : 'Brand';
            return BarTooltipItem('${models[gi].modelName}\n$label: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 12));
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i >= 0 && i < models.length) {
              return Padding(padding: const EdgeInsets.only(top: 8),
                child: Text(models[i].modelName.replaceAll('AI Overviews', 'AIO'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11)));
            }
            return const Text('');
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(models.length, (i) => BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: models[i].totalMentions.toDouble(), color: const Color(0xFF3B82F6), width: 14,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
        BarChartRodData(toY: models[i].brandMentions.toDouble(), color: const Color(0xFF10B981), width: 14,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
      ], barsSpace: 4)),
    ));
  }
}
