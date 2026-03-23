import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
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

  group('Cronjob UseCase Tests', () {
    test('GetAllCronjobsUseCase should return all cronjobs', () async {
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
      await mockRepository.createCronjob(cronjob);

      final useCase = GetAllCronjobsUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.name, 'Test Job');
    });

    test('GetCronjobByIdUseCase should return specific cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final cronjob = Cronjob(
        id: 'job_123',
        name: 'Specific Job',
        description: 'Test',
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
      await mockRepository.createCronjob(cronjob);

      final useCase = GetCronjobByIdUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call('job_123');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'Specific Job');
    });

    test('CreateCronjobUseCase should create new cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final newCronjob = Cronjob(
        id: 'job_new',
        name: 'New Job',
        description: 'Brand new',
        schedule: Schedule.monthly,
        schedulePattern: '0 9 1 * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 15,
        destinations: [PublishingDestination.linkedin],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final useCase = CreateCronjobUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call(newCronjob);
      final allCronjobs = await mockRepository.getAllCronjobs();

      // Assert
      expect(result.name, 'New Job');
      expect(allCronjobs.length, 1);
      expect(allCronjobs.first.id, 'job_new');
    });
  });
}
