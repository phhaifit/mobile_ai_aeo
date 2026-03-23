import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/data/local/datasource/cronjob_datasource_impl.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database database;
  late CronjobDataSourceImpl dataSource;

  setUp(() async {
    // Create in-memory database for testing
    database = await databaseFactoryMemory.openDatabase('test.db');
    dataSource = CronjobDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('CronjobDataSource Tests', () {
    test('saveCronjob and getAllCronjobs should persist data', () async {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'job_001',
        name: 'Test Job',
        description: 'Test description',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await dataSource.saveCronjob(cronjob);
      final result = await dataSource.getAllCronjobs();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.name, 'Test Job');
    });

    test('getCronjobById should retrieve specific cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'job_001',
        name: 'Test Job',
        description: 'Test',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await dataSource.saveCronjob(cronjob);
      final result = await dataSource.getCronjobById('job_001');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'Test Job');
    });

    test('getCronjobById should return null for non-existent ID', () async {
      // Act
      final result = await dataSource.getCronjobById('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('deleteCronjob should remove cronjob from storage', () async {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'job_to_delete',
        name: 'Delete Me',
        description: 'Test',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await dataSource.saveCronjob(cronjob);
      await dataSource.deleteCronjob('job_to_delete');
      final result = await dataSource.getCronjobById('job_to_delete');

      // Assert
      expect(result, isNull);
    });

    test('saveCronjob should update existing cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final original = Cronjob(
        id: 'job_001',
        name: 'Original Name',
        description: 'Original',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = Cronjob(
        id: 'job_001',
        name: 'Updated Name',
        description: 'Updated',
        schedule: Schedule.weekly,
        schedulePattern: '0 9 * * 0',
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com',
        articleCountPerRun: 10,
        destinations: [PublishingDestination.facebook],
        isEnabled: false,
        createdAt: now,
        updatedAt: now.add(const Duration(hours: 1)),
      );

      // Act
      await dataSource.saveCronjob(original);
      await dataSource.saveCronjob(updated);
      final result = await dataSource.getAllCronjobs();

      // Assert
      expect(result.length, 1);
      expect(result.first.name, 'Updated Name');
      expect(result.first.schedule, Schedule.weekly);
    });
  });
}
