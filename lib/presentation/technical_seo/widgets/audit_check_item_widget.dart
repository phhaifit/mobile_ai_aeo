import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/entity/seo/seo_check_item.dart';
import 'package:flutter/material.dart';

class AuditCheckItemWidget extends StatelessWidget {
  final SeoCheckItem item;

  const AuditCheckItemWidget({super.key, required this.item});

  IconData _icon() {
    switch (item.status) {
      case CheckStatus.pass:
        return Icons.check_circle;
      case CheckStatus.fail:
        return Icons.cancel;
      case CheckStatus.warning:
        return Icons.warning_amber_rounded;
    }
  }

  Color _color() {
    switch (item.status) {
      case CheckStatus.pass:
        return Colors.green;
      case CheckStatus.fail:
        return Colors.red;
      case CheckStatus.warning:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), color: _color(), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (item.recommendation != null &&
                    item.recommendation!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fix: ${item.recommendation}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
