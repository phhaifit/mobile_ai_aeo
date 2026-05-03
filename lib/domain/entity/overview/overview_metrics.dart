class OverviewMetrics {
  final int brandMentions;
  final double brandMentionsRate;
  final int linkReferences;
  final double linkReferencesRate;
  final double brandVisibilityScore;
  final List<DomainDistribution> domainDistribution;
  final Map<String, int> competitors;

  OverviewMetrics({
    required this.brandMentions,
    required this.brandMentionsRate,
    required this.linkReferences,
    required this.linkReferencesRate,
    required this.brandVisibilityScore,
    required this.domainDistribution,
    required this.competitors,
  });

  factory OverviewMetrics.fromJson(Map<String, dynamic> json) {
    return OverviewMetrics(
      brandMentions: json['brandMentions'] as int? ?? 0,
      brandMentionsRate: (json['brandMentionsRate'] as num?)?.toDouble() ?? 0.0,
      linkReferences: json['linkReferences'] as int? ?? 0,
      linkReferencesRate:
          (json['linkReferencesRate'] as num?)?.toDouble() ?? 0.0,
      brandVisibilityScore:
          (json['brandVisibilityScore'] as num?)?.toDouble() ?? 0.0,
      domainDistribution: json['domainDistribution'] != null
          ? (json['domainDistribution'] as List<dynamic>)
              .map(
                  (e) => DomainDistribution.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      competitors: json['competitors'] != null
          ? Map<String, int>.from(json['competitors'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandMentions': brandMentions,
      'brandMentionsRate': brandMentionsRate,
      'linkReferences': linkReferences,
      'linkReferencesRate': linkReferencesRate,
      'brandVisibilityScore': brandVisibilityScore,
      'domainDistribution': domainDistribution.map((e) => e.toJson()).toList(),
      'competitors': competitors,
    };
  }
}

class DomainDistribution {
  final String domain;
  final int count;
  final Map<String, double> distribution;

  DomainDistribution({
    required this.domain,
    required this.count,
    required this.distribution,
  });

  factory DomainDistribution.fromJson(Map<String, dynamic> json) {
    return DomainDistribution(
      domain: json['domain'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      distribution: json['distribution'] != null
          ? (json['distribution'] as Map).cast<String, double>()
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'count': count,
      'distribution': distribution,
    };
  }
}
