import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';

void main() {
  group('Cronjob Entity Tests', () {
    test('Cronjob should serialize to Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'job_001',
        name: 'Daily News',
        description: 'Fetch and publish daily news',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [
          PublishingDestination.website,
          PublishingDestination.facebook,
        ],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = cronjob.toMap();

      // Assert
      expect(map['id'], 'job_001');
      expect(map['name'], 'Daily News');
      expect(map['schedule'], Schedule.daily.toJson());
      expect(map['sourceType'], SourceType.promptLibrary.toJson());
      expect(map['articleCountPerRun'], 5);
      expect(map['isEnabled'], true);
      expect(map['destinations'].length, 2);
    });

    test('Cronjob should deserialize from Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'id': 'job_002',
        'name': 'Weekly Update',
        'description': 'Weekly content sync',
        'schedule': 'weekly',
        'schedulePattern': '0 9 * * 0',
        'sourceType': 'website',
        'sourceUrl': 'https://example.com',
        'articleCountPerRun': 10,
        'destinations': ['website', 'linkedin'],
        'isEnabled': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Act
      final cronjob = Cronjob.fromMap(map);

      // Assert
      expect(cronjob.id, 'job_002');
      expect(cronjob.name, 'Weekly Update');
      expect(cronjob.schedule, Schedule.weekly);
      expect(cronjob.sourceType, SourceType.website);
      expect(cronjob.sourceUrl, 'https://example.com');
      expect(cronjob.articleCountPerRun, 10);
      expect(cronjob.isEnabled, false);
    });

    test('Cronjob roundtrip serialization should work', () {
      // Arrange
      final now = DateTime.now();
      final original = Cronjob(
        id: 'job_003',
        name: 'Monthly Report',
        description: 'Monthly content report',
        schedule: Schedule.monthly,
        schedulePattern: '0 9 1 * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 20,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final map = original.toMap();
      final deserialized = Cronjob.fromMap(map);

      // Assert
      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.schedule, original.schedule);
      expect(deserialized.schedulePattern, original.schedulePattern);
      expect(deserialized.sourceType, original.sourceType);
      expect(deserialized.articleCountPerRun, original.articleCountPerRun);
      expect(deserialized.isEnabled, original.isEnabled);
    });
  });
}
