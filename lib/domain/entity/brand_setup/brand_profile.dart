import 'package:json_annotation/json_annotation.dart';

part 'brand_profile.g.dart';

@JsonSerializable()
class BrandProfile {
  final String id;
  final String projectId;
  final String brandName;
  final String brandDescription;
  final String industry;
  final String targetAudience;
  final String? logoUrl;
  final String? websiteUrl;
  final List<String>? keywords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BrandProfile({
    required this.id,
    required this.projectId,
    required this.brandName,
    required this.brandDescription,
    required this.industry,
    required this.targetAudience,
    this.logoUrl,
    this.websiteUrl,
    this.keywords,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandProfile.fromJson(Map<String, dynamic> json) =>
      _$BrandProfileFromJson(json);

  Map<String, dynamic> toJson() => _$BrandProfileToJson(this);

  BrandProfile copyWith({
    String? id,
    String? projectId,
    String? brandName,
    String? brandDescription,
    String? industry,
    String? targetAudience,
    String? logoUrl,
    String? websiteUrl,
    List<String>? keywords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BrandProfile(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        brandName: brandName ?? this.brandName,
        brandDescription: brandDescription ?? this.brandDescription,
        industry: industry ?? this.industry,
        targetAudience: targetAudience ?? this.targetAudience,
        logoUrl: logoUrl ?? this.logoUrl,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        keywords: keywords ?? this.keywords,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'BrandProfile(id: $id, projectId: $projectId, brandName: $brandName)';
}
