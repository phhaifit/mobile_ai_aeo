import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/data/repository/cronjob_repository_impl.dart';
import 'package:boilerplate/data/local/datasource/cronjob_datasource_impl.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database database;
  late CronjobDataSourceImpl dataSource;
  late CronjobRepositoryImpl repository;
  late MockExecutionService executionService;

  setUp(() async {
    // Create in-memory database for integration tests
    // Use unique database name for each test to avoid interference
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    database = await databaseFactoryMemory.openDatabase('integration_test_$timestamp.db');
    dataSource = CronjobDataSourceImpl(database: database);
    repository = CronjobRepositoryImpl(localDataSource: dataSource);
    executionService = MockExecutionService();
  });

  tearDown(() async {
    await database.close();
  });

  group('Cronjob Integration Tests', () {
    test('Full cronjob lifecycle: create, retrieve, update, delete', () async {
      // Arrange
      final now = DateTime.now();
      final initialCronjob = Cronjob(
        id: 'integration_001',
        name: 'Integration Test Job',
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

      // Act & Assert - Create
      final created = await repository.createCronjob(initialCronjob);
      expect(created.id, 'integration_001');
      expect(created.name, 'Integration Test Job');

      // Act & Assert - Retrieve by ID
      final retrieved = await repository.getCronjobById('integration_001');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Integration Test Job');

      // Act & Assert - Retrieve all
      var allCronjobs = await repository.getAllCronjobs();
      expect(allCronjobs.length, 1);

      // Act & Assert - Update
      final updated = Cronjob(
        id: 'integration_001',
        name: 'Updated Integration Job',
        description: 'Updated description',
        schedule: Schedule.weekly,
        schedulePattern: '0 9 * * 0',
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com',
        articleCountPerRun: 10,
        destinations: [PublishingDestination.facebook, PublishingDestination.linkedin],
        isEnabled: false,
        createdAt: now,
        updatedAt: now.add(const Duration(hours: 1)),
      );

      final updatedResult = await repository.updateCronjob(updated);
      expect(updatedResult.name, 'Updated Integration Job');
      expect(updatedResult.schedule, Schedule.weekly);

      // Act & Assert - Delete
      await repository.deleteCronjob('integration_001');
      allCronjobs = await repository.getAllCronjobs();
      expect(allCronjobs, isEmpty);
    });

    test('Execute cronjob and store execution results', () async {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'integration_exec_001',
        name: 'Executable Job',
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

      // Act - Create cronjob
      await repository.createCronjob(cronjob);

      // Act - Execute cronjob
      final execution = await executionService.executeCronjob(
        'integration_exec_001',
        5,
      );

      // Act - Save execution
      final savedExecution = await repository.createExecution(execution);

      // Assert
      expect(savedExecution.cronjobId, 'integration_exec_001');
      expect(savedExecution.articlesGenerated, greaterThan(0));
      expect(savedExecution.executionResults, isNotEmpty);

      // Act - Retrieve execution
      final retrievedExecution = await repository.getExecutionById(savedExecution.id);
      expect(retrievedExecution, isNotNull);
      expect(retrievedExecution!.id, savedExecution.id);
    });

    test('Multiple cronjobs and executions in database', () async {
      // Arrange
      final now = DateTime.now();

      final job1 = Cronjob(
        id: 'job_1',
        name: 'Job 1',
        description: 'First job',
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

      final job2 = Cronjob(
        id: 'job_2',
        name: 'Job 2',
        description: 'Second job',
        schedule: Schedule.weekly,
        schedulePattern: '0 9 * * 0',
        sourceType: SourceType.website,
        sourceUrl: 'https://example.com',
        articleCountPerRun: 10,
        destinations: [PublishingDestination.facebook],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act - Create both jobs
      await repository.createCronjob(job1);
      await repository.createCronjob(job2);

      // Act - Execute both jobs
      final exec1 = await executionService.executeCronjob('job_1', 5);
      final exec2 = await executionService.executeCronjob('job_2', 10);

      await repository.createExecution(exec1);
      await repository.createExecution(exec2);

      // Assert - Check data consistency
      final allJobs = await repository.getAllCronjobs();
      expect(allJobs.length, 2);

      final job1Execs = await repository.getCronjobExecutions('job_1');
      final job2Execs = await repository.getCronjobExecutions('job_2');

      expect(job1Execs.length, 1);
      expect(job2Execs.length, 1);
    });
  });
}
