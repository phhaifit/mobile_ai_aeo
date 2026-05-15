// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandProfile _$BrandProfileFromJson(Map<String, dynamic> json) => BrandProfile(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      brandName: json['brandName'] as String,
      brandDescription: json['brandDescription'] as String,
      industry: json['industry'] as String,
      targetAudience: json['targetAudience'] as String,
      logoUrl: json['logoUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BrandProfileToJson(BrandProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'brandName': instance.brandName,
      'brandDescription': instance.brandDescription,
      'industry': instance.industry,
      'targetAudience': instance.targetAudience,
      'logoUrl': instance.logoUrl,
      'websiteUrl': instance.websiteUrl,
      'keywords': instance.keywords,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
