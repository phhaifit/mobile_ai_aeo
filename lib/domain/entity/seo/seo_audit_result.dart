import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/entity/seo/seo_category.dart';

class SeoAuditResult {
  final String auditId;
  final String url;
  final double overallScore;
  final AuditStatus status;
  final List<SeoCategory> categories;
  final DateTime createdAt;

  SeoAuditResult({
    required this.auditId,
    required this.url,
    required this.overallScore,
    required this.status,
    required this.categories,
    required this.createdAt,
  });

  factory SeoAuditResult.fromMap(Map<String, dynamic> map) {
    return SeoAuditResult(
      auditId: (map['audit_id'] ?? map['auditId'] ?? '') as String,
      url: (map['url'] ?? '') as String,
      overallScore: (map['overallScore'] as num).toDouble(),
      status: AuditStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AuditStatus.pending,
      ),
      categories: (map['categories'] as List<dynamic>? ?? [])
          .map((e) => SeoCategory.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() => {
        'auditId': auditId,
        'url': url,
        'overallScore': overallScore,
        'status': status.name,
        'categories': categories.map((c) => c.toMap()).toList(),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
