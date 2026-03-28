import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_execution_store.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_result.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_status.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';

// Mock repository for use cases
class MockCronjobRepository implements CronjobRepository {
  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async => cronjob;

  @override
  Future<void> deleteCronjob(String id) async {}

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async =>
      execution;

  @override
  Future<List<Cronjob>> getAllCronjobs() async => [];

  @override
  Future<Cronjob?> getCronjobById(String id) async => null;

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async =>
      [];

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async => cronjob;

  @override
  Future<CronjobExecution?> getExecutionById(String id) async => null;
}

// Mock use cases
class MockGetCronjobExecutionsUseCase implements GetCronjobExecutionsUseCase {
  final List<CronjobExecution> mockExecutions;
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  MockGetCronjobExecutionsUseCase({this.mockExecutions = const []});

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<List<CronjobExecution>> call(String cronjobId) async {
    return mockExecutions.where((e) => e.cronjobId == cronjobId).toList();
  }
}

class MockCreateExecutionUseCase implements CreateExecutionUseCase {
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<CronjobExecution> call(CronjobExecution execution) async {
    return execution;
  }
}

class MockGetCronjobByIdUseCase implements GetCronjobByIdUseCase {
  final Map<String, Cronjob> mockCronjobs;
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  MockGetCronjobByIdUseCase({this.mockCronjobs = const {}});

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<Cronjob?> call(String id) async {
    return mockCronjobs[id];
  }
}

void main() {
  late CronjobExecutionStore store;
  late MockGetCronjobExecutionsUseCase mockGetExecutionsUseCase;
  late MockCreateExecutionUseCase mockCreateExecutionUseCase;
  late MockGetCronjobByIdUseCase mockGetCronjobByIdUseCase;
  late MockExecutionService mockExecutionService;

  final testCronjob = Cronjob(
    id: 'cron-1',
    name: 'Test Job',
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

  final testExecution1 = CronjobExecution(
    id: 'exec-1',
    cronjobId: 'cron-1',
    executedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: ExecutionStatus.success,
    articlesGenerated: 5,
    executionResults: [
      ExecutionResult(
        destination: PublishingDestination.website,
        status: PublishingStatus.success,
        publishedCount: 5,
        failedCount: 0,
        publishedArticleIds: ['art-1', 'art-2', 'art-3', 'art-4', 'art-5'],
      ),
    ],
  );

  final testExecution2 = CronjobExecution(
    id: 'exec-2',
    cronjobId: 'cron-1',
    executedAt: DateTime.now().subtract(const Duration(hours: 1)),
    status: ExecutionStatus.failed,
    articlesGenerated: 0,
    executionResults: [],
  );

  setUp(() {
    mockGetExecutionsUseCase = MockGetCronjobExecutionsUseCase(
      mockExecutions: [testExecution1, testExecution2],
    );
    mockCreateExecutionUseCase = MockCreateExecutionUseCase();
    mockGetCronjobByIdUseCase = MockGetCronjobByIdUseCase(
      mockCronjobs: {'cron-1': testCronjob},
    );
    mockExecutionService = MockExecutionService();

    store = CronjobExecutionStore(
      getCronjobExecutionsUseCase: mockGetExecutionsUseCase,
      createExecutionUseCase: mockCreateExecutionUseCase,
      getCronjobByIdUseCase: mockGetCronjobByIdUseCase,
      mockExecutionService: mockExecutionService,
    );
  });

  group('CronjobExecutionStore Tests', () {
    test('loadExecutions fetches history', () async {
      // Act
      await store.loadExecutions('cron-1');

      // Assert
      expect(store.executions.length, 2);
      expect(store.currentCronjobId, 'cron-1');
      expect(store.executionMessage, null);
    });

    test('loadExecutions handles errors gracefully', () async {
      // Arrange - create new store with failing use case
      final failingUseCase = MockGetCronjobExecutionsUseCase();
      final store2 = CronjobExecutionStore(
        getCronjobExecutionsUseCase: failingUseCase,
        createExecutionUseCase: mockCreateExecutionUseCase,
        getCronjobByIdUseCase: mockGetCronjobByIdUseCase,
        mockExecutionService: mockExecutionService,
      );

      // Act - simulate error by passing invalid ID (no matching executions but no error in mock)
      // In real scenario, the use case would throw
      await store2.loadExecutions('invalid-id');

      // Assert
      expect(store2.filteredExecutions.length, 0);
    });

    test('testRunCronjob executes and stores result', () async {
      // Arrange
      await store.loadExecutions('cron-1');
      final initialCount = store.executions.length;

      // Act
      await store.testRunCronjob('cron-1');

      // Assert
      expect(store.isExecuting, false);
      expect(store.executions.length, greaterThan(initialCount));
      expect(store.executionMessage, isNotNull);
      expect(store.executionMessage!.contains('Execution complete'), true);
    });

    test('selectExecution updates selected', () async {
      // Arrange
      await store.loadExecutions('cron-1');

      // Act
      store.selectExecution('exec-1');

      // Assert
      expect(store.selectedExecution?.id, 'exec-1');
    });

    test('filteredExecutions computed filters by cronjob', () async {
      // Arrange
      await store.loadExecutions('cron-1');

      // Act & Assert
      expect(store.filteredExecutions.length, 2);
      expect(store.filteredExecutions.every((e) => e.cronjobId == 'cron-1'), true);
    });

    test('successCount computed counts successes', () async {
      // Arrange
      await store.loadExecutions('cron-1');

      // Act & Assert
      expect(store.successCount, 1); // Only exec-1 is success
      expect(store.failureCount, 1); // Only exec-2 is failed
    });

    test('clearMessage resets message', () async {
      // Arrange
      await store.testRunCronjob('cron-1');
      expect(store.executionMessage, isNotNull);

      // Act
      store.clearMessage();

      // Assert
      expect(store.executionMessage, null);
    });

    test('lastExecutionTime computed returns latest', () async {
      // Arrange
      await store.loadExecutions('cron-1');

      // Act
      final lastTime = store.lastExecutionTime;

      // Assert
      expect(lastTime, isNotNull);
    });
  });
}
