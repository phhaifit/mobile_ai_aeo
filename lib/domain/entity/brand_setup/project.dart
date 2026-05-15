import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        ownerId: ownerId ?? this.ownerId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'Project(id: $id, name: $name, ownerId: $ownerId)';
}
