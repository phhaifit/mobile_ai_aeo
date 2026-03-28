import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_status.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_result.dart';

void main() {
  group('CronjobExecution Entity Tests', () {
    test('CronjobExecution should serialize to Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final execution = CronjobExecution(
        id: 'exec_001',
        cronjobId: 'job_001',
        executedAt: now,
        status: ExecutionStatus.success,
        articlesGenerated: 5,
        executionResults: [
          ExecutionResult(
            destination: PublishingDestination.website,
            status: PublishingStatus.success,
            publishedCount: 5,
            failedCount: 0,
            errorMessage: null,
            publishedArticleIds: [],
          ),
        ],
        errorMessage: null,
        completedAt: now.add(const Duration(seconds: 30)),
      );

      // Act
      final map = execution.toMap();

      // Assert
      expect(map['id'], 'exec_001');
      expect(map['cronjobId'], 'job_001');
      expect(map['status'], ExecutionStatus.success.toJson());
      expect(map['articlesGenerated'], 5);
      expect(map['executionResults'].length, 1);
      expect(map['errorMessage'], null);
    });

    test('CronjobExecution should deserialize from Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'id': 'exec_002',
        'cronjobId': 'job_002',
        'executedAt': now.toIso8601String(),
        'status': 'partial',
        'articlesGenerated': 3,
        'executionResults': [
          {
            'destination': 'website',
            'status': 'success',
            'publishedCount': 3,
            'failedCount': 0,
            'errorMessage': null,
            'publishedArticleIds': [],
          },
        ],
        'errorMessage': 'Some issues',
        'completedAt': now.add(const Duration(minutes: 1)).toIso8601String(),
      };

      // Act
      final execution = CronjobExecution.fromMap(map);

      // Assert
      expect(execution.id, 'exec_002');
      expect(execution.cronjobId, 'job_002');
      expect(execution.status, ExecutionStatus.partial);
      expect(execution.articlesGenerated, 3);
      expect(execution.executionResults.length, 1);
    });

    test('CronjobExecution roundtrip serialization should work', () {
      // Arrange
      final now = DateTime.now();
      final original = CronjobExecution(
        id: 'exec_003',
        cronjobId: 'job_003',
        executedAt: now,
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [],
        errorMessage: 'Network error',
        completedAt: now.add(const Duration(seconds: 5)),
      );

      // Act
      final map = original.toMap();
      final deserialized = CronjobExecution.fromMap(map);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.cronjobId, original.cronjobId);
      expect(deserialized.status, original.status);
      expect(deserialized.articlesGenerated, original.articlesGenerated);
      expect(deserialized.errorMessage, original.errorMessage);
    });
  });
}
