import 'publishing_status.dart';
import 'publishing_destination.dart';

class ExecutionResult {
  PublishingDestination destination;
  PublishingStatus status;
  int publishedCount;
  int failedCount;
  String? errorMessage;
  List<String> publishedArticleIds;

  ExecutionResult({
    required this.destination,
    required this.status,
    required this.publishedCount,
    required this.failedCount,
    this.errorMessage,
    required this.publishedArticleIds,
  });

  Map<String, dynamic> toMap() => {
        'destination': destination.toJson(),
        'status': status.toJson(),
        'publishedCount': publishedCount,
        'failedCount': failedCount,
        'errorMessage': errorMessage,
        'publishedArticleIds': publishedArticleIds,
      };

  factory ExecutionResult.fromMap(Map<String, dynamic> json) {
    return ExecutionResult(
      destination: PublishingDestinationExtension.fromJson(
        json['destination'] as String,
      ),
      status:
          PublishingStatusExtension.fromJson(json['status'] as String),
      publishedCount: json['publishedCount'] as int,
      failedCount: json['failedCount'] as int,
      errorMessage: json['errorMessage'] as String?,
      publishedArticleIds:
          List<String>.from(json['publishedArticleIds'] as List),
    );
  }
}
