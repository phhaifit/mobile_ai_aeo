/// API overview payload + [applyOverviewMetricsFallbacks] when fields are empty / null / zero.
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
      brandMentions: _intFromJson(json['brandMentions']),
      brandMentionsRate: _doubleFromJson(json['brandMentionsRate']),
      linkReferences: _intFromJson(json['linkReferences']),
      linkReferencesRate: _doubleFromJson(json['linkReferencesRate']),
      brandVisibilityScore: _doubleFromJson(json['brandVisibilityScore']),
      domainDistribution: json['domainDistribution'] != null
          ? (json['domainDistribution'] as List<dynamic>)
              .map(
                (e) => DomainDistribution.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
          : [],
      competitors: _competitorsFromJson(json['competitors']),
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
      domain: json['domain']?.toString() ?? '',
      count: _intFromJson(json['count']),
      distribution: _distributionFromJson(json['distribution']),
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

// --- JSON helpers ---

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double _doubleFromJson(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

Map<String, double> _distributionFromJson(dynamic raw) {
  if (raw == null || raw is! Map) return {};
  final out = <String, double>{};
  raw.forEach((k, v) {
    out[k.toString()] = _doubleFromJson(v);
  });
  return out;
}

Map<String, int> _competitorsFromJson(dynamic raw) {
  if (raw == null || raw is! Map) return {};
  final out = <String, int>{};
  raw.forEach((k, v) {
    out[k.toString()] = _intFromJson(v);
  });
  return out;
}

// --- Fallback mock (when API sends 0 / null / empty) ---

const int _mockBrandMentions = 42;
const double _mockBrandMentionsRate = 78.3;
const int _mockLinkReferences = 15;
const double _mockLinkReferencesRate = 65.2;
const double _mockBrandVisibilityScore = 85.5;

/// API keys like "Competitor A" → recognizable company names for UI.
const Map<String, String> _competitorDisplayNames = {
  'Competitor A': 'Shopify',
  'Competitor B': 'HubSpot',
  'Competitor C': 'Salesforce',
};

/// Default mock list when API returns no usable `domainDistribution`.
List<DomainDistribution> _mockDefaultDomainDistributions() {
  return [
    DomainDistribution(
      domain: 'github.com',
      count: 1247,
      distribution: const {
        'ChatGPT': 45.2,
        'Gemini': 15.7,
        'AI Overview': 39.1,
      },
    ),
    DomainDistribution(
      domain: 'stackoverflow.com',
      count: 892,
      distribution: const {
        'ChatGPT': 28.0,
        'Gemini': 42.0,
        'AI Overview': 30.0,
      },
    ),
  ];
}

Map<String, int> _mockCompetitors() {
  return {
    'Shopify': 75,
    'HubSpot': 60,
    'Salesforce': 90,
  };
}

bool _domainRowIsUsable(DomainDistribution d) {
  return d.domain.trim().isNotEmpty &&
      d.count > 0 &&
      d.distribution.isNotEmpty;
}

List<DomainDistribution> _effectiveDomainDistribution(
  List<DomainDistribution> list,
) {
  final usable = list.where(_domainRowIsUsable).toList();
  if (usable.isNotEmpty) return usable;
  return _mockDefaultDomainDistributions();
}

Map<String, int> _effectiveCompetitors(Map<String, int> raw) {
  final out = <String, int>{};
  for (final e in raw.entries) {
    final key = e.key.trim();
    if (key.isEmpty) continue;
    final label = _competitorDisplayNames[key] ?? key;
    if (e.value > 0) {
      out[label] = e.value;
    }
  }
  if (out.isEmpty) {
    return _mockCompetitors();
  }
  return out;
}

/// Fills missing numeric / empty list / empty competitor map using mock values.
OverviewMetrics applyOverviewMetricsFallbacks(OverviewMetrics m) {
  return OverviewMetrics(
    brandMentions: m.brandMentions > 0 ? m.brandMentions : _mockBrandMentions,
    brandMentionsRate:
        m.brandMentionsRate > 0 ? m.brandMentionsRate : _mockBrandMentionsRate,
    linkReferences:
        m.linkReferences > 0 ? m.linkReferences : _mockLinkReferences,
    linkReferencesRate: m.linkReferencesRate > 0
        ? m.linkReferencesRate
        : _mockLinkReferencesRate,
    brandVisibilityScore: m.brandVisibilityScore > 0
        ? m.brandVisibilityScore
        : _mockBrandVisibilityScore,
    domainDistribution: _effectiveDomainDistribution(m.domainDistribution),
    competitors: _effectiveCompetitors(m.competitors),
  );
}
