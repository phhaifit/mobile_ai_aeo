import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_result.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_status.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';

class CronjobSeedData {
  /// Generate demo cronjobs for initial app launch
  static List<Cronjob> generateDemoCronjobs() {
    final now = DateTime.now();

    return [
      // Cronjob 1: Daily SEO Tips
      Cronjob(
        id: 'job-seo-tips',
        name: 'Daily SEO Tips',
        description: 'Generates daily SEO optimization tips from industry blogs',
        schedule: Schedule.daily,
        schedulePattern: '0 8 * * *', // Daily at 8 AM
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 3,
        destinations: [
          PublishingDestination.website,
          PublishingDestination.linkedin,
        ],
        isEnabled: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),

      // Cronjob 2: Weekly Industry News
      Cronjob(
        id: 'job-industry-news',
        name: 'Weekly Industry News',
        description: 'Curated weekly news from major tech publications',
        schedule: Schedule.weekly,
        schedulePattern: '0 9 * * 1', // Every Monday at 9 AM
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com/tech-news-feed',
        articleCountPerRun: 5,
        destinations: [
          PublishingDestination.website,
          PublishingDestination.linkedin,
        ],
        isEnabled: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),

      // Cronjob 3: Product Updates
      Cronjob(
        id: 'job-product-updates',
        name: 'Product Updates',
        description: 'Monthly product release notes and feature announcements',
        schedule: Schedule.monthly,
        schedulePattern: '0 10 1 * *', // 1st of each month at 10 AM
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 2,
        destinations: [
          PublishingDestination.website,
          PublishingDestination.facebook,
        ],
        isEnabled: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),

      // Cronjob 4: Market Analysis (Disabled)
      Cronjob(
        id: 'job-market-analysis',
        name: 'Market Analysis',
        description: 'Monthly market trend analysis and insights',
        schedule: Schedule.monthly,
        schedulePattern: '0 14 15 * *', // 15th of each month at 2 PM
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 4,
        destinations: [
          PublishingDestination.wikipedia,
        ],
        isEnabled: false, // This job is currently disabled
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),

      // Cronjob 5: Daily Digest
      Cronjob(
        id: 'job-daily-digest',
        name: 'Daily Digest',
        description: 'Daily digest of top trending topics in AI and tech',
        schedule: Schedule.daily,
        schedulePattern: '0 6 * * *', // Daily at 6 AM
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com/trending-feed',
        articleCountPerRun: 6,
        destinations: [
          PublishingDestination.website,
          PublishingDestination.linkedin,
        ],
        isEnabled: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Generate demo executions for a cronjob
  static List<CronjobExecution> generateDemoExecutions(String cronjobId) {
    final now = DateTime.now();

    // Different execution patterns based on cronjob ID
    switch (cronjobId) {
      case 'job-seo-tips':
        return [
          // Recent successful execution
          CronjobExecution(
            id: 'exec-seo-1',
            cronjobId: cronjobId,
            executedAt: now,
            status: ExecutionStatus.success,
            articlesGenerated: 3,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-1', 'art-2', 'art-3'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-1', 'art-2', 'art-3'],
              ),
            ],
            errorMessage: null,
            completedAt: now.add(const Duration(minutes: 5)),
          ),

          // Yesterday execution - partial success
          CronjobExecution(
            id: 'exec-seo-2',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 1)),
            status: ExecutionStatus.partial,
            articlesGenerated: 3,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-4', 'art-5', 'art-6'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.failed,
                publishedCount: 0,
                failedCount: 3,
                errorMessage: 'API rate limit exceeded',
                publishedArticleIds: [],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 1, minutes: 3)),
          ),

          // 3 days ago - success
          CronjobExecution(
            id: 'exec-seo-3',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 3)),
            status: ExecutionStatus.success,
            articlesGenerated: 3,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-7', 'art-8', 'art-9'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-7', 'art-8', 'art-9'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 3, minutes: 4)),
          ),

          // 5 days ago - failure
          CronjobExecution(
            id: 'exec-seo-4',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 5)),
            status: ExecutionStatus.failed,
            articlesGenerated: 0,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.failed,
                publishedCount: 0,
                failedCount: 3,
                errorMessage: 'Connection timeout',
                publishedArticleIds: [],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.failed,
                publishedCount: 0,
                failedCount: 3,
                errorMessage: 'Authentication failed',
                publishedArticleIds: [],
              ),
            ],
            errorMessage: 'Failed to generate articles from prompt',
            completedAt: now.subtract(const Duration(days: 5, minutes: 2)),
          ),

          // 7 days ago - success
          CronjobExecution(
            id: 'exec-seo-5',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 7)),
            status: ExecutionStatus.success,
            articlesGenerated: 3,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-10', 'art-11', 'art-12'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 3,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['art-10', 'art-11', 'art-12'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 7, minutes: 5)),
          ),
        ];

      case 'job-industry-news':
        return [
          CronjobExecution(
            id: 'exec-news-1',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 2)),
            status: ExecutionStatus.success,
            articlesGenerated: 5,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 5,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['news-1', 'news-2', 'news-3', 'news-4', 'news-5'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 5,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['news-1', 'news-2', 'news-3', 'news-4', 'news-5'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 2, minutes: 8)),
          ),
          CronjobExecution(
            id: 'exec-news-2',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 9)),
            status: ExecutionStatus.success,
            articlesGenerated: 5,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 5,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['news-6', 'news-7', 'news-8', 'news-9', 'news-10'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 5,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['news-6', 'news-7', 'news-8', 'news-9', 'news-10'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 9, minutes: 7)),
          ),
        ];

      case 'job-product-updates':
        return [
          CronjobExecution(
            id: 'exec-product-1',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 22)),
            status: ExecutionStatus.success,
            articlesGenerated: 2,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 2,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['prod-1', 'prod-2'],
              ),
              ExecutionResult(
                destination: PublishingDestination.facebook,
                status: PublishingStatus.success,
                publishedCount: 2,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['prod-1', 'prod-2'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 22, minutes: 3)),
          ),
        ];

      case 'job-daily-digest':
        return [
          CronjobExecution(
            id: 'exec-digest-1',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(hours: 2)),
            status: ExecutionStatus.success,
            articlesGenerated: 6,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 6,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['dig-1', 'dig-2', 'dig-3', 'dig-4', 'dig-5', 'dig-6'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 6,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['dig-1', 'dig-2', 'dig-3', 'dig-4', 'dig-5', 'dig-6'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(hours: 1, minutes: 55)),
          ),
          CronjobExecution(
            id: 'exec-digest-2',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 1, hours: 2)),
            status: ExecutionStatus.success,
            articlesGenerated: 6,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 6,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['dig-7', 'dig-8', 'dig-9', 'dig-10', 'dig-11', 'dig-12'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.success,
                publishedCount: 6,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['dig-7', 'dig-8', 'dig-9', 'dig-10', 'dig-11', 'dig-12'],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 54)),
          ),
          CronjobExecution(
            id: 'exec-digest-3',
            cronjobId: cronjobId,
            executedAt: now.subtract(const Duration(days: 2, hours: 2)),
            status: ExecutionStatus.partial,
            articlesGenerated: 5,
            executionResults: [
              ExecutionResult(
                destination: PublishingDestination.website,
                status: PublishingStatus.success,
                publishedCount: 5,
                failedCount: 0,
                errorMessage: null,
                publishedArticleIds: ['dig-13', 'dig-14', 'dig-15', 'dig-16', 'dig-17'],
              ),
              ExecutionResult(
                destination: PublishingDestination.linkedin,
                status: PublishingStatus.failed,
                publishedCount: 0,
                failedCount: 5,
                errorMessage: 'Mail server unavailable',
                publishedArticleIds: [],
              ),
            ],
            errorMessage: null,
            completedAt: now.subtract(const Duration(days: 2, hours: 1, minutes: 50)),
          ),
        ];

      default:
        return [];
    }
  }

  /// Get all demo data (cronjobs + executions)
  static Map<String, dynamic> getAllDemoData() {
    final cronjobs = generateDemoCronjobs();
    final executions = <CronjobExecution>[];

    for (final cronjob in cronjobs) {
      executions.addAll(generateDemoExecutions(cronjob.id));
    }

    return {
      'cronjobs': cronjobs,
      'executions': executions,
    };
  }

  /// Generate error scenario executions for testing error handling
  /// 
  /// Returns a list of executions with various error states:
  /// - Network timeout during execution
  /// - API rate limiting
  /// - Authentication failures
  /// - Partial failures with some destinations working
  static List<CronjobExecution> generateErrorScenarioExecutions() {
    final now = DateTime.now();

    return [
      // Scenario 1: Network timeout
      CronjobExecution(
        id: 'exec-error-1',
        cronjobId: 'job-error-1',
        executedAt: now.subtract(const Duration(hours: 3)),
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 3,
            errorMessage: 'Connection timeout - failed to reach server',
            publishedArticleIds: [],
          ),
          ExecutionResult(
            destination: PublishingDestination.linkedin,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 3,
            errorMessage: 'Connection timeout - failed to reach server',
            publishedArticleIds: [],
          ),
        ],
        errorMessage: 'Network error: Connection timeout after 30 seconds',
        completedAt: now.subtract(const Duration(hours: 3, minutes: 2)),
      ),

      // Scenario 2: API Rate Limiting
      CronjobExecution(
        id: 'exec-error-2',
        cronjobId: 'job-error-2',
        executedAt: now.subtract(const Duration(hours: 6)),
        status: ExecutionStatus.partial,
        articlesGenerated: 3,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 3,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: ['art-r1', 'art-r2', 'art-r3'],
          ),
          ExecutionResult(
            destination: PublishingDestination.linkedin,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 3,
            errorMessage: 'Rate limit exceeded - daily post limit reached',
            publishedArticleIds: [],
          ),
        ],
        errorMessage: null,
        completedAt: now.subtract(const Duration(hours: 6, minutes: 1)),
      ),

      // Scenario 3: Authentication Failure
      CronjobExecution(
        id: 'exec-error-3',
        cronjobId: 'job-error-3',
        executedAt: now.subtract(const Duration(hours: 12)),
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 4,
            errorMessage: 'Authentication failed - invalid API credentials',
            publishedArticleIds: [],
          ),
          ExecutionResult(
            destination: PublishingDestination.facebook,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 4,
            errorMessage: 'Authentication failed - token expired',
            publishedArticleIds: [],
          ),
        ],
        errorMessage: 'Failed to authenticate with publishing services',
        completedAt: now.subtract(const Duration(hours: 12, minutes: 2)),
      ),

      // Scenario 4: Invalid Data Format
      CronjobExecution(
        id: 'exec-error-4',
        cronjobId: 'job-error-4',
        executedAt: now.subtract(const Duration(days: 1)),
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.failed,
            publishedCount: 0,
            failedCount: 2,
            errorMessage: 'Invalid data format - article title exceeds 500 characters',
            publishedArticleIds: [],
          ),
        ],
        errorMessage: 'Generation failed: Invalid article format produced',
        completedAt: now.subtract(const Duration(days: 1, minutes: 1)),
      ),
    ];
  }
}
