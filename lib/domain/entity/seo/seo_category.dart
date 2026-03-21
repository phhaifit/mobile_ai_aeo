import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/entity/seo/seo_check_item.dart';

class SeoCategory {
  final String name;
  final double score;
  final List<SeoCheckItem> checks;

  SeoCategory({
    required this.name,
    required this.score,
    required this.checks,
  });

  int get passCount =>
      checks.where((c) => c.status == CheckStatus.pass).length;

  int get failCount =>
      checks.where((c) => c.status == CheckStatus.fail).length;

  factory SeoCategory.fromMap(Map<String, dynamic> map) {
    return SeoCategory(
      name: map['name'] as String,
      score: (map['score'] as num).toDouble(),
      checks: (map['checks'] as List<dynamic>? ?? [])
          .map((e) => SeoCheckItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'score': score,
        'checks': checks.map((c) => c.toMap()).toList(),
      };
}
