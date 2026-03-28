import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/entity/cronjob/execution_status.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_executions_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_execution_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/data/service/mock_execution_service.dart';

part 'cronjob_execution_store.g.dart';

class CronjobExecutionStore = _CronjobExecutionStore with _$CronjobExecutionStore;

abstract class _CronjobExecutionStore with Store {
  final GetCronjobExecutionsUseCase getCronjobExecutionsUseCase;
  final CreateExecutionUseCase createExecutionUseCase;
  final GetCronjobByIdUseCase getCronjobByIdUseCase;
  final MockExecutionService mockExecutionService;

  _CronjobExecutionStore({
    required this.getCronjobExecutionsUseCase,
    required this.createExecutionUseCase,
    required this.getCronjobByIdUseCase,
    required this.mockExecutionService,
  });

  // ============================================================================
  // Observables
  // ============================================================================

  @observable
  List<CronjobExecution> executions = [];

  @observable
  CronjobExecution? selectedExecution;

  @observable
  bool isExecuting = false;

  @observable
  String? executionMessage;

  @observable
  String? currentCronjobId;

  // ============================================================================
  // Computed Properties
  // ============================================================================

  @computed
  List<CronjobExecution> get filteredExecutions =>
      executions.where((e) => e.cronjobId == currentCronjobId).toList();

  @computed
  bool get isProcessing => isExecuting;

  @computed
  int get totalExecutions => executions.length;

  @computed
  String? get lastExecutionTime {
    if (filteredExecutions.isEmpty) return null;
    final sorted = filteredExecutions.toList()
      ..sort((a, b) => b.executedAt.compareTo(a.executedAt));
    return sorted.first.executedAt.toString();
  }

  @computed
  int get successCount => filteredExecutions
      .where((e) => e.status == ExecutionStatus.success)
      .length;

  @computed
  int get failureCount => filteredExecutions
      .where((e) => e.status == ExecutionStatus.failed)
      .length;

  @computed
  int get partialCount => filteredExecutions
      .where((e) => e.status == ExecutionStatus.partial)
      .length;

  // ============================================================================
  // Actions
  // ============================================================================

  @action
  Future<void> loadExecutions(String cronjobId) async {
    currentCronjobId = cronjobId;
    executionMessage = null;

    try {
      executions = await getCronjobExecutionsUseCase(cronjobId);
    } catch (e) {
      executionMessage = 'Failed to load executions: ${e.toString()}';
      rethrow;
    }
  }

  @action
  Future<void> testRunCronjob(String cronjobId) async {
    isExecuting = true;
    executionMessage = 'Running cronjob...';

    try {
      // Get cronjob details
      final cronjob = await getCronjobByIdUseCase(cronjobId);
      if (cronjob == null) {
        throw Exception('Cronjob not found: $cronjobId');
      }

      // Execute with mock service
      final execution = await mockExecutionService.executeCronjob(
        cronjobId,
        cronjob.articleCountPerRun,
      );

      // Save execution to database
      final savedExecution = await createExecutionUseCase(execution);

      // Add to list (most recent first)
      executions.insert(0, savedExecution);

      // Update message with summary
      final successCount = savedExecution.executionResults
          .where((r) => r.status.name == 'success')
          .length;
      final totalDestinations = savedExecution.executionResults.length;

      executionMessage =
          'Execution complete: ${savedExecution.articlesGenerated} articles, '
          '$successCount/$totalDestinations destinations succeeded';
    } catch (e) {
      executionMessage = 'Execution failed: ${e.toString()}';
      rethrow;
    } finally {
      isExecuting = false;
    }
  }

  @action
  void selectExecution(String? executionId) {
    if (executionId == null) {
      selectedExecution = null;
    } else {
      try {
        selectedExecution = executions.firstWhere(
          (e) => e.id == executionId,
          orElse: () => throw Exception('Execution not found: $executionId'),
        );
      } catch (e) {
        executionMessage = 'Failed to select execution: ${e.toString()}';
      }
    }
  }

  @action
  void clearMessage() {
    executionMessage = null;
  }

  @action
  void clearSelection() {
    selectedExecution = null;
  }
}
