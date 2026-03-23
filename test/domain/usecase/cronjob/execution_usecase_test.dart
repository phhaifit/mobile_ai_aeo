import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_execution_by_id_usecase.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';

// Mock repository
class MockCronjobRepository implements CronjobRepository {
  final List<Cronjob> _cronjobs = [];
  final List<CronjobExecution> _executions = [];

  @override
  Future<List<Cronjob>> getAllCronjobs() async => _cronjobs;

  @override
  Future<Cronjob?> getCronjobById(String id) async =>
      _cronjobs.firstWhereOrNull((c) => c.id == id);

  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async {
    _cronjobs.add(cronjob);
    return cronjob;
  }

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async {
    _cronjobs.removeWhere((c) => c.id == cronjob.id);
    _cronjobs.add(cronjob);
    return cronjob;
  }

  @override
  Future<void> deleteCronjob(String id) async =>
      _cronjobs.removeWhere((c) => c.id == id);

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async =>
      _executions.where((e) => e.cronjobId == cronjobId).toList();

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async {
    _executions.add(execution);
    return execution;
  }

  @override
  Future<CronjobExecution?> getExecutionById(String executionId) async =>
      _executions.firstWhereOrNull((e) => e.id == executionId);
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

  group('Execution UseCase Tests', () {
    test('GetCronjobExecutionsUseCase should return executions for cronjob', () async {
      // Arrange
      final now = DateTime.now();
      final execution1 = CronjobExecution(
        id: 'exec_001',
        cronjobId: 'job_001',
        executedAt: now,
        status: ExecutionStatus.success,
        articlesGenerated: 5,
        executionResults: [],
        errorMessage: null,
        completedAt: now.add(const Duration(seconds: 10)),
      );

      final execution2 = CronjobExecution(
        id: 'exec_002',
        cronjobId: 'job_001',
        executedAt: now.add(const Duration(hours: 1)),
        status: ExecutionStatus.partial,
        articlesGenerated: 3,
        executionResults: [],
        errorMessage: 'Some failed',
        completedAt: now.add(const Duration(hours: 1, seconds: 15)),
      );

      await mockRepository.createExecution(execution1);
      await mockRepository.createExecution(execution2);

      final useCase = GetCronjobExecutionsUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call('job_001');

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'exec_001');
      expect(result[1].id, 'exec_002');
    });

    test('CreateExecutionUseCase should create new execution', () async {
      // Arrange
      final now = DateTime.now();
      final execution = CronjobExecution(
        id: 'exec_new',
        cronjobId: 'job_001',
        executedAt: now,
        status: ExecutionStatus.success,
        articlesGenerated: 10,
        executionResults: [],
        errorMessage: null,
        completedAt: now.add(const Duration(seconds: 20)),
      );

      final useCase = CreateExecutionUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call(execution);

      // Assert
      expect(result.id, 'exec_new');
      expect(result.status, ExecutionStatus.success);
      expect(result.articlesGenerated, 10);
    });

    test('GetExecutionByIdUseCase should retrieve specific execution', () async {
      // Arrange
      final now = DateTime.now();
      final execution = CronjobExecution(
        id: 'exec_123',
        cronjobId: 'job_001',
        executedAt: now,
        status: ExecutionStatus.failed,
        articlesGenerated: 0,
        executionResults: [],
        errorMessage: 'Network error',
        completedAt: now.add(const Duration(seconds: 5)),
      );

      await mockRepository.createExecution(execution);
      final useCase = GetExecutionByIdUseCase(repository: mockRepository);

      // Act
      final result = await useCase.call('exec_123');

      // Assert
      expect(result, isNotNull);
      expect(result!.status, ExecutionStatus.failed);
      expect(result.errorMessage, 'Network error');
    });
  });
}
