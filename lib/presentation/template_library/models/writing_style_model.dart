/// Data model representing a Writing Style template
class WritingStyleModel {
  final String id;
  final String name;
  final String description;
  final String voice;
  final String tone;
  final String audience;
  final String industry;
  final String color;

  WritingStyleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.voice,
    required this.tone,
    required this.audience,
    required this.industry,
    required this.color,
  });

  /// Create a copy of this model with optional field overrides
  WritingStyleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? voice,
    String? tone,
    String? audience,
    String? industry,
    String? color,
  }) {
    return WritingStyleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      voice: voice ?? this.voice,
      tone: tone ?? this.tone,
      audience: audience ?? this.audience,
      industry: industry ?? this.industry,
      color: color ?? this.color,
    );
  }

  @override
  String toString() =>
      'WritingStyleModel(id: $id, name: $name, industry: $industry)';
}

/// Data model representing analysis results from website
class WebsiteAnalysisResult {
  final String targetAudience;
  final String contentTone;
  final String recommendedTemplate;
  final String analysisDetails;
  final DateTime analyzedAt;

  WebsiteAnalysisResult({
    required this.targetAudience,
    required this.contentTone,
    required this.recommendedTemplate,
    required this.analysisDetails,
    required this.analyzedAt,
  });
}
