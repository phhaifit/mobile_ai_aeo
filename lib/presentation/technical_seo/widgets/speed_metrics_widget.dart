import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:boilerplate/domain/entity/seo/seo_category.dart';
import 'package:flutter/material.dart';

class SpeedMetricsWidget extends StatelessWidget {
  final SeoAuditResult audit;

  const SpeedMetricsWidget({super.key, required this.audit});

  SeoCategory? _speedCategory() {
    try {
      return audit.categories.firstWhere(
        (c) => c.name.toLowerCase().contains('speed') ||
            c.name.toLowerCase().contains('performance'),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _speedCategory();

    if (category == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No speed data available')),
      );
    }

    final metricNames = ['FCP', 'LCP', 'CLS', 'TBT'];
    final metrics = category.checks
        .where((c) => metricNames.any(
              (m) => c.name.toUpperCase().contains(m),
            ))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Speed & Performance',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (metrics.isEmpty)
          ...category.checks.map((c) => _MetricRow(name: c.name, score: c.score ?? 0))
        else
          ...metrics.map((c) => _MetricRow(name: c.name, score: c.score ?? 0)),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String name;
  final double score;

  const _MetricRow({required this.name, required this.score});

  Color _color() {
    if (score > 70) return Colors.green;
    if (score > 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${score.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
