import 'publishing_destination.dart';
import 'schedule.dart';
import 'source_type.dart';

class Cronjob {
  String id;
  String name;
  String? description;
  Schedule schedule;
  String schedulePattern;
  SourceType sourceType;
  String? sourceUrl;
  int articleCountPerRun;
  List<PublishingDestination> destinations;
  bool isEnabled;
  DateTime createdAt;
  DateTime updatedAt;

  Cronjob({
    required this.id,
    required this.name,
    this.description,
    required this.schedule,
    required this.schedulePattern,
    required this.sourceType,
    this.sourceUrl,
    required this.articleCountPerRun,
    required this.destinations,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'schedule': schedule.toJson(),
        'schedulePattern': schedulePattern,
        'sourceType': sourceType.toJson(),
        'sourceUrl': sourceUrl,
        'articleCountPerRun': articleCountPerRun,
        'destinations':
            destinations.map((d) => d.toJson()).toList(),
        'isEnabled': isEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Cronjob.fromMap(Map<String, dynamic> json) {
    return Cronjob(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      schedule: ScheduleExtension.fromJson(json['schedule'] as String),
      schedulePattern: json['schedulePattern'] as String,
      sourceType: SourceTypeExtension.fromJson(
        json['sourceType'] as String,
      ),
      sourceUrl: json['sourceUrl'] as String?,
      articleCountPerRun: json['articleCountPerRun'] as int,
      destinations: (json['destinations'] as List)
          .map((d) => PublishingDestinationExtension.fromJson(d as String))
          .toList(),
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
