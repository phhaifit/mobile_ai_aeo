import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/data/repository/cronjob_repository_impl.dart';
import 'package:boilerplate/data/local/datasource/cronjob_datasource.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';

// Mock implementation without mockito
class MockCronjobDataSource implements CronjobDataSource {
  final List<Cronjob> _cronjobs = [];

  @override
  Future<List<Cronjob>> getAllCronjobs() async => _cronjobs;

  @override
  Future<Cronjob?> getCronjobById(String id) async =>
      _cronjobs.firstWhereOrNull((c) => c.id == id);

  @override
  Future<void> saveCronjob(Cronjob cronjob) async {
    _cronjobs.removeWhere((c) => c.id == cronjob.id);
    _cronjobs.add(cronjob);
  }

  @override
  Future<void> deleteCronjob(String id) async =>
      _cronjobs.removeWhere((c) => c.id == id);

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async => [];

  @override
  Future<void> saveExecution(CronjobExecution execution) async {}

  @override
  Future<CronjobExecution?> getExecutionById(String executionId) async => null;

  @override
  Future<void> deleteExecution(String executionId) async {}
}

extension _ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

void main() {
  late CronjobRepositoryImpl repository;
  late MockCronjobDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCronjobDataSource();
    repository = CronjobRepositoryImpl(localDataSource: mockDataSource);
  });

  group('CronjobRepository Tests', () {
    test('getAllCronjobs should return list from datasource', () async {
      // Arrange
      final mockCronjob = Cronjob(
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await mockDataSource.saveCronjob(mockCronjob);

      // Act
      final result = await repository.getAllCronjobs();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.name, 'Test Job');
    });

    test('getCronjobById should return cronjob from datasource', () async {
      // Arrange
      final mockCronjob = Cronjob(
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await mockDataSource.saveCronjob(mockCronjob);

      // Act
      final result = await repository.getCronjobById('job_001');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'Test Job');
    });

    test('createCronjob should save and return cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final newCronjob = Cronjob(
        id: 'job_new',
        name: 'New Job',
        description: 'New test',
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

      // Act
      final result = await repository.createCronjob(newCronjob);

      // Assert
      expect(result.name, 'New Job');
      final saved = await mockDataSource.getCronjobById('job_new');
      expect(saved, isNotNull);
    });

    test('updateCronjob should update timestamp and save', () async {
      // Arrange
      final now = DateTime.now();
      final existingCronjob = Cronjob(
        id: 'job_001',
        name: 'Updated Job',
        description: 'Updated',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );

      // Act
      final result = await repository.updateCronjob(existingCronjob);

      // Assert
      expect(result.name, 'Updated Job');
      expect(result.updatedAt.isAfter(result.createdAt), true);
    });

    test('deleteCronjob should remove from datasource', () async {
      // Arrange
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await mockDataSource.saveCronjob(cronjob);

      // Act
      await repository.deleteCronjob('job_to_delete');

      // Assert
      final result = await mockDataSource.getCronjobById('job_to_delete');
      expect(result, isNull);
    });
  });
}
