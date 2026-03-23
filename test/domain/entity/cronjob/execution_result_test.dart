import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_status.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_result.dart';

void main() {
  group('ExecutionResult Entity Tests', () {
    test('ExecutionResult should serialize to Map correctly', () {
      // Arrange
      final executionResult = ExecutionResult(
        destination: PublishingDestination.website,
        status: PublishingStatus.success,
        publishedCount: 5,
        failedCount: 0,
        errorMessage: null,
        publishedArticleIds: ['article_1', 'article_2'],
      );

      // Act
      final map = executionResult.toMap();

      // Assert
      expect(map['destination'], PublishingDestination.website.toJson());
      expect(map['status'], PublishingStatus.success.toJson());
      expect(map['publishedCount'], 5);
      expect(map['failedCount'], 0);
      expect(map['errorMessage'], null);
      expect(map['publishedArticleIds'].length, 2);
    });

    test('ExecutionResult should deserialize from Map correctly', () {
      // Arrange
      final map = {
        'destination': 'website',
        'status': 'success',
        'publishedCount': 3,
        'failedCount': 1,
        'errorMessage': 'Some failed',
        'publishedArticleIds': ['article_1'],
      };

      // Act
      final result = ExecutionResult.fromMap(map);

      // Assert
      expect(result.destination, PublishingDestination.website);
      expect(result.status, PublishingStatus.success);
      expect(result.publishedCount, 3);
      expect(result.failedCount, 1);
      expect(result.errorMessage, 'Some failed');
    });

    test('ExecutionResult roundtrip serialization should work', () {
      // Arrange
      final original = ExecutionResult(
        destination: PublishingDestination.linkedin,
        status: PublishingStatus.partial,
        publishedCount: 2,
        failedCount: 1,
        errorMessage: 'Network error',
        publishedArticleIds: ['art_1'],
      );

      // Act
      final map = original.toMap();
      final deserialized = ExecutionResult.fromMap(map);

      // Assert
      expect(deserialized.destination, original.destination);
      expect(deserialized.status, original.status);
      expect(deserialized.publishedCount, original.publishedCount);
      expect(deserialized.failedCount, original.failedCount);
      expect(deserialized.errorMessage, original.errorMessage);
    });
  });
}
