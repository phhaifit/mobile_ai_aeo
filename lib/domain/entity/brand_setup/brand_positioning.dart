import 'package:json_annotation/json_annotation.dart';

part 'brand_positioning.g.dart';

@JsonSerializable()
class BrandPositioning {
  final String id;
  final String projectId;
  final String positionStatement;
  final List<String>? uniqueValuePropositions;
  final List<String>? competitiveAdvantages;
  final String? targetMarket;
  final String? brandVoice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BrandPositioning({
    required this.id,
    required this.projectId,
    required this.positionStatement,
    this.uniqueValuePropositions,
    this.competitiveAdvantages,
    this.targetMarket,
    this.brandVoice,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandPositioning.fromJson(Map<String, dynamic> json) =>
      _$BrandPositioningFromJson(json);

  Map<String, dynamic> toJson() => _$BrandPositioningToJson(this);

  BrandPositioning copyWith({
    String? id,
    String? projectId,
    String? positionStatement,
    List<String>? uniqueValuePropositions,
    List<String>? competitiveAdvantages,
    String? targetMarket,
    String? brandVoice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BrandPositioning(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        positionStatement: positionStatement ?? this.positionStatement,
        uniqueValuePropositions:
            uniqueValuePropositions ?? this.uniqueValuePropositions,
        competitiveAdvantages:
            competitiveAdvantages ?? this.competitiveAdvantages,
        targetMarket: targetMarket ?? this.targetMarket,
        brandVoice: brandVoice ?? this.brandVoice,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'BrandPositioning(id: $id, projectId: $projectId)';
}
