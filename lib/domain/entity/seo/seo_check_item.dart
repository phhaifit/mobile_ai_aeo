import 'package:boilerplate/domain/entity/seo/check_status.dart';

class SeoCheckItem {
  /// Insight ID from backend — used for PATCH /content-insights/:id
  final String? id;
  final String name;
  final String description;
  final CheckStatus status;
  final String? recommendation;
  final double? score;

  SeoCheckItem({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    this.recommendation,
    this.score,
  });

  factory SeoCheckItem.fromMap(Map<String, dynamic> map) {
    return SeoCheckItem(
      id: map['id']?.toString(),
      name: (map['name'] ?? map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: CheckStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'warning').toString(),
        orElse: () => CheckStatus.warning,
      ),
      recommendation: map['recommendation']?.toString(),
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status.name,
        'recommendation': recommendation,
        'score': score,
      };
}
