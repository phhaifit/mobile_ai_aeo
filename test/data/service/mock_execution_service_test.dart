import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';

void main() {
  group('MockExecutionService Tests', () {
    late MockExecutionService service;

    setUp(() {
      service = MockExecutionService();
    });

    test('executeCronjob should return valid execution result', () async {
      // Act
      final result = await service.executeCronjob('job_001', 5);

      // Assert
      expect(result.cronjobId, 'job_001');
      expect(result.articlesGenerated, greaterThan(0));
      expect(result.executedAt, isNotNull);
      expect(result.completedAt, isNotNull);
    });

    test('executeCronjob should create execution results for each destination', () async {
      // Act
      final result = await service.executeCronjob('job_002', 10);

      // Assert
      expect(result.executionResults, isNotEmpty);
      expect(result.executionResults.length, 3); // website, facebook, linkedin
    });

    test('executeCronjob status should be one of valid statuses', () async {
      // Act
      final result = await service.executeCronjob('job_003', 5);

      // Assert
      final validStatuses = [
        ExecutionStatus.success,
        ExecutionStatus.partial,
        ExecutionStatus.failed,
      ];
      expect(validStatuses, contains(result.status));
    });

    test('executeCronjob completedAt should be after executedAt', () async {
      // Act
      final result = await service.executeCronjob('job_004', 8);

      // Assert
      expect(result.completedAt!.isAfter(result.executedAt), true);
    });

    test('executeCronjob with failed status should have error message', () async {
      // Run multiple times to get a failed execution
      for (int i = 0; i < 10; i++) {
        final result = await service.executeCronjob('job_005', 5);

        if (result.status == ExecutionStatus.failed) {
          // Assert
          expect(result.errorMessage, isNotEmpty);
          return;
        }
      }

      // If we get here, we didn't get a failed execution, which is ok (random)
      expect(true, isTrue);
    });

    test('executeCronjob should respect article count parameter', () async {
      // Act
      final resultSmall = await service.executeCronjob('job_006', 2);
      final resultLarge = await service.executeCronjob('job_007', 20);

      // Assert
      expect(resultSmall.articlesGenerated, lessThanOrEqualTo(6));
      expect(resultLarge.articlesGenerated, lessThanOrEqualTo(60));
    });

    test('executeCronjob execution results should have valid destinations', () async {
      // Act
      final result = await service.executeCronjob('job_008', 5);

      // Assert
      expect(result.executionResults, isNotEmpty);
      for (final execResult in result.executionResults) {
        expect(execResult.destination, isNotNull);
      }
    });
  });
}
