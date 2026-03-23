import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_store.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_execution_store.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';

// Full mock repository for integration testing
class MockCronjobRepository implements CronjobRepository {
  final List<Cronjob> _cronjobs = [];
  final List<CronjobExecution> _executions = [];

  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async {
    _cronjobs.add(cronjob);
    return cronjob;
  }

  @override
  Future<void> deleteCronjob(String id) async {
    _cronjobs.removeWhere((c) => c.id == id);
  }

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async {
    _executions.add(execution);
    return execution;
  }

  @override
  Future<List<Cronjob>> getAllCronjobs() async => _cronjobs;

  @override
  Future<Cronjob?> getCronjobById(String id) async =>
      _cronjobs.firstWhereOrNull((c) => c.id == id);

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async =>
      _executions.where((e) => e.cronjobId == cronjobId).toList();

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async {
    final index = _cronjobs.indexWhere((c) => c.id == cronjob.id);
    if (index >= 0) {
      _cronjobs[index] = cronjob;
    }
    return cronjob;
  }

  @override
  Future<CronjobExecution?> getExecutionById(String id) async =>
      _executions.firstWhereOrNull((e) => e.id == id);
}

void main() {
  late CronjobStore cronjobStore;
  late CronjobExecutionStore executionStore;
  late MockCronjobRepository repository;
  late MockExecutionService mockExecutionService;

  final testCronjob = Cronjob(
    id: 'cron-1',
    name: 'Integration Test Job',
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

  setUp(() {
    repository = MockCronjobRepository();
    mockExecutionService = MockExecutionService();

    // Create use cases with shared repository
    final getAllUseCase = GetAllCronjobsUseCase(repository: repository);
    final getByIdUseCase = GetCronjobByIdUseCase(repository: repository);
    final createUseCase = CreateCronjobUseCase(repository: repository);
    final updateUseCase = UpdateCronjobUseCase(repository: repository);
    final deleteUseCase = DeleteCronjobUseCase(repository: repository);
    final getExecutionsUseCase =
        GetCronjobExecutionsUseCase(repository: repository);
    final createExecutionUseCase =
        CreateExecutionUseCase(repository: repository);

    // Create stores
    cronjobStore = CronjobStore(
      getAllCronjobsUseCase: getAllUseCase,
      getCronjobByIdUseCase: getByIdUseCase,
      createCronjobUseCase: createUseCase,
      updateCronjobUseCase: updateUseCase,
      deleteCronjobUseCase: deleteUseCase,
    );

    executionStore = CronjobExecutionStore(
      getCronjobExecutionsUseCase: getExecutionsUseCase,
      createExecutionUseCase: createExecutionUseCase,
      getCronjobByIdUseCase: getByIdUseCase,
      mockExecutionService: mockExecutionService,
    );
  });

  group('Store Integration Tests', () {
    test('Full CRUD cycle: Create → Read → Update → Delete', () async {
      // Create
      await cronjobStore.createCronjob(testCronjob);
      expect(cronjobStore.cronjobs.length, 1);

      // Read
      await cronjobStore.loadCronjobs();
      expect(cronjobStore.cronjobs.length, 1);
      expect(cronjobStore.cronjobs[0].id, 'cron-1');

      // Update
      final updated = testCronjob.copyWith(name: 'Updated Job');
      await cronjobStore.updateCronjob(updated);
      expect(cronjobStore.cronjobs[0].name, 'Updated Job');

      // Delete
      await cronjobStore.deleteCronjob('cron-1');
      expect(cronjobStore.cronjobs.length, 0);
    });

    test('Cronjob execution creates history record', () async {
      // Arrange - create cronjob first
      await cronjobStore.createCronjob(testCronjob);
      await executionStore.loadExecutions('cron-1');
      expect(executionStore.executions.length, 0);

      // Act - execute cronjob
      await executionStore.testRunCronjob('cron-1');

      // Assert - execution recorded
      expect(executionStore.executions.length, greaterThan(0));
      expect(executionStore.executions[0].cronjobId, 'cron-1');
      expect(executionStore.isExecuting, false);
    });

    test('Multi-store coordination: Create job, then test execution', () async {
      // Create cronjob
      await cronjobStore.createCronjob(testCronjob);
      cronjobStore.selectCronjob('cron-1');
      expect(cronjobStore.selectedCronjob?.id, 'cron-1');

      // Load execution history (should be empty)
      await executionStore.loadExecutions('cron-1');
      expect(executionStore.executions.length, 0);

      // Run test execution
      await executionStore.testRunCronjob('cron-1');
      expect(executionStore.executions.length, greaterThan(0));

      // Verify execution stats
      expect(executionStore.totalExecutions, greaterThan(0));
      expect(executionStore.successCount, greaterThanOrEqualTo(0));
      expect(executionStore.failureCount, greaterThanOrEqualTo(0));
    });
  });
}

// Extension for firstWhereOrNull (if not available)
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}

// Extension for copyWith on Cronjob
extension CronjobCopyWith on Cronjob {
  Cronjob copyWith({
    String? id,
    String? name,
    String? description,
    Schedule? schedule,
    String? schedulePattern,
    SourceType? sourceType,
    String? sourceUrl,
    int? articleCountPerRun,
    List<PublishingDestination>? destinations,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cronjob(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schedule: schedule ?? this.schedule,
      schedulePattern: schedulePattern ?? this.schedulePattern,
      sourceType: sourceType ?? this.sourceType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      articleCountPerRun: articleCountPerRun ?? this.articleCountPerRun,
      destinations: destinations ?? this.destinations,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
