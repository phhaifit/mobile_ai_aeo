import 'package:boilerplate/domain/entity/seo/seo_category.dart';
import 'package:boilerplate/presentation/technical_seo/widgets/audit_check_item_widget.dart';
import 'package:flutter/material.dart';

class AuditCategoryWidget extends StatelessWidget {
  final SeoCategory category;

  const AuditCategoryWidget({super.key, required this.category});

  Color _scoreColor(double score) {
    if (score > 70) return Colors.green;
    if (score > 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(category.score);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            category.score.toStringAsFixed(0),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category.passCount} passed · ${category.failCount} failed',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: category.checks
            .map((item) => AuditCheckItemWidget(item: item))
            .toList(),
      ),
    );
  }
}
