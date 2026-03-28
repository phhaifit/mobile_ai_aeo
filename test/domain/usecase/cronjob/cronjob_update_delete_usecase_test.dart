import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';

// Mock repository
class MockCronjobRepository implements CronjobRepository {
  final List<Cronjob> _data = [];

  @override
  Future<List<Cronjob>> getAllCronjobs() async => _data;

  @override
  Future<Cronjob?> getCronjobById(String id) async =>
      _data.firstWhereOrNull((c) => c.id == id);

  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async {
    _data.add(cronjob);
    return cronjob;
  }

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async {
    _data.removeWhere((c) => c.id == cronjob.id);
    _data.add(cronjob);
    return cronjob;
  }

  @override
  Future<void> deleteCronjob(String id) async =>
      _data.removeWhere((c) => c.id == id);

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async => [];

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async => execution;

  @override
  Future<CronjobExecution?> getExecutionById(String executionId) async => null;
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
  late MockCronjobRepository mockRepository;

  setUp(() {
    mockRepository = MockCronjobRepository();
  });

  group('Cronjob Update and Delete UseCase Tests', () {
    test('UpdateCronjobUseCase should update cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final original = Cronjob(
        id: 'job_001',
        name: 'Original',
        description: 'Original desc',
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
        name: 'Updated',
        description: 'Updated desc',
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

      await mockRepository.createCronjob(original);
      final useCase = UpdateCronjobUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call(updated);

      // Assert
      expect(result.name, 'Updated');
      expect(result.description, 'Updated desc');
      expect(result.schedule, Schedule.weekly);
      expect(result.isEnabled, false);
    });

    test('DeleteCronjobUseCase should delete cronjob', () async {
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

      await mockRepository.createCronjob(cronjob);
      final useCase = DeleteCronjobUseCase(repository: mockRepository);

      // Act
      await useCase.call('job_to_delete');
      final allCronjobs = await mockRepository.getAllCronjobs();

      // Assert
      expect(allCronjobs, isEmpty);
    });
  });
}
