import 'dart:math';

import '../../domain/entity/cronjob/cronjob_execution.dart';
import '../../domain/entity/cronjob/execution_result.dart';
import '../../domain/entity/cronjob/execution_status.dart';
import '../../domain/entity/cronjob/publishing_destination.dart';
import '../../domain/entity/cronjob/publishing_status.dart';

class MockExecutionService {
  final Random _random = Random();

  /// Simulate a cronjob execution
  /// Returns a CronjobExecution with mock results
  Future<CronjobExecution> executeCronjob(
    String cronjobId,
    int articleCountPerRun,
  ) async {
    // Simulate network/processing delay
    await Future.delayed(
      Duration(milliseconds: _random.nextInt(2000) + 500),
    );

    final executionId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    // Generate random execution status
    final statusIndex = _random.nextInt(3);
    final statuses = [
      ExecutionStatus.success,
      ExecutionStatus.partial,
      ExecutionStatus.failed,
    ];
    final status = statuses[statusIndex];

    // Generate mock execution results for each destination
    final mockDestinations = [
      PublishingDestination.website,
      PublishingDestination.facebook,
      PublishingDestination.linkedin,
    ];
    final executionResults = <ExecutionResult>[];

    int totalGenerated = 0;

    for (final destination in mockDestinations) {
      final generatedCount = _random.nextInt(articleCountPerRun) + 1;
      totalGenerated += generatedCount;

      final resultStatus = _randomPublishingStatus();
      final failedCount = resultStatus == PublishingStatus.failed
          ? _random.nextInt(generatedCount)
          : 0;
      final publishedCount = generatedCount - failedCount;

      executionResults.add(
        ExecutionResult(
          destination: destination,
          status: resultStatus,
          publishedCount: publishedCount,
          failedCount: failedCount,
          errorMessage: failedCount > 0
              ? 'Some articles failed to publish'
              : null,
          publishedArticleIds: List.generate(
            publishedCount,
            (i) => 'article_${executionId}_${destination.displayName}_$i',
          ),
        ),
      );
    }

    return CronjobExecution(
      id: executionId,
      cronjobId: cronjobId,
      executedAt: now,
      status: status,
      articlesGenerated: totalGenerated,
      executionResults: executionResults,
      errorMessage: status == ExecutionStatus.failed
          ? 'Execution failed due to network error'
          : null,
      completedAt: now.add(Duration(milliseconds: _random.nextInt(1000))),
    );
  }

  /// Generate a random publishing status
  PublishingStatus _randomPublishingStatus() {
    final statuses = [
      PublishingStatus.success,
      PublishingStatus.partial,
      PublishingStatus.failed,
    ];
    return statuses[_random.nextInt(statuses.length)];
  }
}
