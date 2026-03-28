import 'package:boilerplate/domain/entity/seo/check_status.dart';

class SeoCheckItem {
  final String name;
  final String description;
  final CheckStatus status;
  final String? recommendation;
  final double? score;

  SeoCheckItem({
    required this.name,
    required this.description,
    required this.status,
    this.recommendation,
    this.score,
  });

  factory SeoCheckItem.fromMap(Map<String, dynamic> map) {
    return SeoCheckItem(
      name: map['name'] as String,
      description: map['description'] as String,
      status: CheckStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CheckStatus.warning,
      ),
      recommendation: map['recommendation'] as String?,
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'status': status.name,
        'recommendation': recommendation,
        'score': score,
      };
}
