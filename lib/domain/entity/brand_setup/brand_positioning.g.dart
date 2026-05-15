// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_positioning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandPositioning _$BrandPositioningFromJson(Map<String, dynamic> json) =>
    BrandPositioning(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      positionStatement: json['positionStatement'] as String,
      uniqueValuePropositions:
          (json['uniqueValuePropositions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      competitiveAdvantages: (json['competitiveAdvantages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetMarket: json['targetMarket'] as String?,
      brandVoice: json['brandVoice'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BrandPositioningToJson(BrandPositioning instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'positionStatement': instance.positionStatement,
      'uniqueValuePropositions': instance.uniqueValuePropositions,
      'competitiveAdvantages': instance.competitiveAdvantages,
      'targetMarket': instance.targetMarket,
      'brandVoice': instance.brandVoice,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
