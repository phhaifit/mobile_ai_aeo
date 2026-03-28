import '../../domain/entity/cronjob/cronjob.dart';
import '../../domain/entity/cronjob/cronjob_execution.dart';
import '../../domain/entity/cronjob/execution_result.dart';
import '../../domain/entity/cronjob/execution_status.dart';
import '../../domain/entity/cronjob/publishing_destination.dart';
import '../../domain/entity/cronjob/publishing_status.dart';
import '../../domain/entity/cronjob/schedule.dart';
import '../../domain/entity/cronjob/source_type.dart';

/// Seed data for cronjob feature
class CronjobSeedData {
  /// Get sample cronjobs
  static List<Cronjob> getSampleCronjobs() {
    return [
      Cronjob(
        id: 'job-001',
        name: 'Daily AI News Updates',
        description: 'Automatically generate and publish daily AI news summaries',
        isEnabled: true,
        schedule: Schedule.daily,
        schedulePattern: '0 8 * * *', // Every day at 8 AM
        destinations: [
          PublishingDestination.website,
          PublishingDestination.facebook,
        ],
        articleCountPerRun: 5,
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Cronjob(
        id: 'job-002',
        name: 'Product Launch Articles',
        description: 'Generate marketing articles for upcoming product launches',
        isEnabled: true,
        schedule: Schedule.weekly,
        schedulePattern: '0 9 * * 1', // Every Monday at 9 AM
        destinations: [
          PublishingDestination.website,
          PublishingDestination.linkedin,
          PublishingDestination.facebook,
        ],
        articleCountPerRun: 3,
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      Cronjob(
        id: 'job-003',
        name: 'Industry Trends Analysis',
        description: 'Analyze and publish weekly industry trend reports',
        isEnabled: true,
        schedule: Schedule.weekly,
        schedulePattern: '0 10 * * 5', // Every Friday at 10 AM
        destinations: [PublishingDestination.linkedin],
        articleCountPerRun: 4,
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com/trends',
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Cronjob(
        id: 'job-004',
        name: 'Customer Success Stories',
        description: 'Create and publish customer case study articles',
        isEnabled: false,
        schedule: Schedule.weekly,
        schedulePattern: '0 11 * * 3', // Every Wednesday at 11 AM
        destinations: [
          PublishingDestination.website,
          PublishingDestination.linkedin,
        ],
        articleCountPerRun: 2,
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        updatedAt: DateTime.now().subtract(Duration(days: 10)),
      ),
      Cronjob(
        id: 'job-005',
        name: 'SEO Optimized Blog Posts',
        description: 'Generate SEO-optimized blog content automatically',
        isEnabled: true,
        schedule: Schedule.daily,
        schedulePattern: '0 7 * * *', // Every day at 7 AM
        destinations: [PublishingDestination.website],
        articleCountPerRun: 6,
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Get sample executions for a cronjob
  static List<CronjobExecution> getSampleExecutions(String cronjobId) {
    final now = DateTime.now();
    
    return [
      // Recent successful execution
      CronjobExecution(
        id: 'exec-001',
        cronjobId: cronjobId,
        executedAt: now.subtract(Duration(hours: 4)),
        status: ExecutionStatus.success,
        articlesGenerated: 5,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_001_website',
              'article_002_website',
              'article_003_website',
              'article_004_website',
              'article_005_website',
            ],
          ),
          ExecutionResult(
            destination: PublishingDestination.facebook,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_001_facebook',
              'article_002_facebook',
              'article_003_facebook',
              'article_004_facebook',
              'article_005_facebook',
            ],
          ),
        ],
        errorMessage: null,
        completedAt: now.subtract(Duration(hours: 3, minutes: 55)),
      ),

      // Partial failure execution
      CronjobExecution(
        id: 'exec-002',
        cronjobId: cronjobId,
        executedAt: now.subtract(Duration(days: 1)),
        status: ExecutionStatus.partial,
        articlesGenerated: 5,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_006_website',
              'article_007_website',
              'article_008_website',
              'article_009_website',
              'article_010_website',
            ],
          ),
          ExecutionResult(
            destination: PublishingDestination.facebook,
            status: PublishingStatus.partial,
            publishedCount: 3,
            failedCount: 2,
            errorMessage: 'Rate limit exceeded on Facebook API',
            publishedArticleIds: [
              'article_006_facebook',
              'article_007_facebook',
              'article_008_facebook',
            ],
          ),
        ],
        errorMessage: 'Some destinations failed to publish all articles',
        completedAt: now.subtract(Duration(days: 1, hours: 23, minutes: 50)),
      ),

      // Failed execution
      CronjobExecution(
        id: 'exec-003',
        cronjobId: cronjobId,
        executedAt: now.subtract(Duration(days: 2)),
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [],
        errorMessage: 'Authentication failed - Please check API credentials',
        completedAt: now.subtract(Duration(days: 2, minutes: 5)),
      ),

      // Older successful execution
      CronjobExecution(
        id: 'exec-004',
        cronjobId: cronjobId,
        executedAt: now.subtract(Duration(days: 3)),
        status: ExecutionStatus.success,
        articlesGenerated: 5,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_011_website',
              'article_012_website',
              'article_013_website',
              'article_014_website',
              'article_015_website',
            ],
          ),
          ExecutionResult(
            destination: PublishingDestination.facebook,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_011_facebook',
              'article_012_facebook',
              'article_013_facebook',
              'article_014_facebook',
              'article_015_facebook',
            ],
          ),
        ],
        errorMessage: null,
        completedAt: now.subtract(Duration(days: 2, hours: 23, minutes: 50)),
      ),

      // Older partial failure
      CronjobExecution(
        id: 'exec-005',
        cronjobId: cronjobId,
        executedAt: now.subtract(Duration(days: 4)),
        status: ExecutionStatus.partial,
        articlesGenerated: 5,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [
              'article_016_website',
              'article_017_website',
              'article_018_website',
              'article_019_website',
              'article_020_website',
            ],
          ),
          ExecutionResult(
            destination: PublishingDestination.facebook,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 5,
            errorMessage: 'Network connection timeout',
            publishedArticleIds: [],
          ),
        ],
        errorMessage: 'Failed to publish to Facebook',
        completedAt: now.subtract(Duration(days: 4, hours: 23, minutes: 45)),
      ),
    ];
  }

  /// Get statistics for dashboard
  static Map<String, dynamic> getStatistics(List<CronjobExecution> executions) {
    int successCount = 0;
    int partialCount = 0;
    int failedCount = 0;
    int totalArticles = 0;

    for (final execution in executions) {
      totalArticles += execution.articlesGenerated;
      
      switch (execution.status) {
        case ExecutionStatus.success:
          successCount++;
          break;
        case ExecutionStatus.partial:
          partialCount++;
          break;
        case ExecutionStatus.failed:
          failedCount++;
          break;
      }
    }

    return {
      'totalExecutions': executions.length,
      'successCount': successCount,
      'partialCount': partialCount,
      'failedCount': failedCount,
      'totalArticlesGenerated': totalArticles,
      'successRate': executions.isEmpty
          ? 0.0
          : (successCount / executions.length * 100).toStringAsFixed(1),
    };
  }
}
