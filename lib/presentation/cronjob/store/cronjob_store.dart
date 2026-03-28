import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';
import 'package:boilerplate/data/service/cronjob_seed_data.dart';

part 'cronjob_store.g.dart';

class CronjobStore = _CronjobStore with _$CronjobStore;

abstract class _CronjobStore with Store {
  final GetAllCronjobsUseCase getAllCronjobsUseCase;
  final GetCronjobByIdUseCase getCronjobByIdUseCase;
  final CreateCronjobUseCase createCronjobUseCase;
  final UpdateCronjobUseCase updateCronjobUseCase;
  final DeleteCronjobUseCase deleteCronjobUseCase;

  _CronjobStore({
    required this.getAllCronjobsUseCase,
    required this.getCronjobByIdUseCase,
    required this.createCronjobUseCase,
    required this.updateCronjobUseCase,
    required this.deleteCronjobUseCase,
  });

  // ============================================================================
  // Observables
  // ============================================================================

  @observable
  List<Cronjob> cronjobs = [];

  @observable
  Cronjob? selectedCronjob;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // Execution history observables (Unit 4 & 5)
  @observable
  List<CronjobExecution> executions = [];

  @observable
  CronjobExecution? currentExecution;

  @observable
  bool isLoadingHistory = false;

  @observable
  String? historyError;

  // Agent activation tracking
  @observable
  String? activeAgentType; // 'website', 'social', 'training' or null

  @observable
  Map<String, dynamic>? activeAgentConfig;

  // ============================================================================
  // Computed Properties
  // ============================================================================

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @computed
  int get totalCronjobs => cronjobs.length;

  @computed
  int get enabledCount => cronjobs.where((c) => c.isEnabled).length;

  @computed
  int get disabledCount => cronjobs.where((c) => !c.isEnabled).length;

  // ============================================================================
  // Actions
  // ============================================================================

  @action
  Future<void> loadCronjobs() async {
    isLoading = true;
    errorMessage = null;

    try {
      // Try to load from repository
      cronjobs = await getAllCronjobsUseCase();
      
      // If empty, load seed data for demo
      if (cronjobs.isEmpty) {
        cronjobs = CronjobSeedData.getSampleCronjobs();
      }
    } catch (e) {
      // On error, load seed data for demo
      cronjobs = CronjobSeedData.getSampleCronjobs();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> createCronjob(Cronjob cronjob) async {
    try {
      final created = await createCronjobUseCase(cronjob);
      cronjobs.add(created);
      selectedCronjob = null;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to create cronjob: ${e.toString()}';
      rethrow;
    }
  }

  @action
  Future<void> updateCronjob(Cronjob cronjob) async {
    try {
      final updated = await updateCronjobUseCase(cronjob);

      // Update in list
      final index = cronjobs.indexWhere((c) => c.id == cronjob.id);
      if (index >= 0) {
        cronjobs[index] = updated;
      }

      // Refresh selected if it was the updated one
      if (selectedCronjob?.id == cronjob.id) {
        selectedCronjob = updated;
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to update cronjob: ${e.toString()}';
      rethrow;
    }
  }

  @action
  Future<void> deleteCronjob(String cronjobId) async {
    try {
      await deleteCronjobUseCase(cronjobId);
      cronjobs.removeWhere((c) => c.id == cronjobId);

      if (selectedCronjob?.id == cronjobId) {
        selectedCronjob = null;
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to delete cronjob: ${e.toString()}';
      rethrow;
    }
  }

  @action
  void selectCronjob(String? cronjobId) {
    if (cronjobId == null) {
      selectedCronjob = null;
    } else {
      try {
        selectedCronjob = cronjobs.firstWhere(
          (c) => c.id == cronjobId,
          orElse: () => throw Exception('Cronjob not found: $cronjobId'),
        );
        errorMessage = null;
      } catch (e) {
        errorMessage = 'Failed to select cronjob: ${e.toString()}';
      }
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void clearSelection() {
    selectedCronjob = null;
  }

  @action
  void clearHistoryError() {
    historyError = null;
  }

  // ============================================================================
  // Execution History Actions (Unit 4 & 5)
  // ============================================================================

  @action
  Future<void> loadExecutionHistory(String cronjobId) async {
    isLoadingHistory = true;
    historyError = null;

    try {
      // Load seed data for demo
      executions = CronjobSeedData.getSampleExecutions(cronjobId);
    } catch (e) {
      historyError = 'Failed to load execution history: ${e.toString()}';
    } finally {
      isLoadingHistory = false;
    }
  }

  @action
  Future<void> retryLoadExecutionHistory(String cronjobId) async {
    // Clear previous error and retry
    clearHistoryError();
    await loadExecutionHistory(cronjobId);
  }

  @action
  Future<void> loadExecutionDetails(String executionId) async {
    isLoadingHistory = true;
    historyError = null;

    try {
      // Get the first matching execution from loaded executions
      if (executions.isNotEmpty) {
        final execution = executions.firstWhere(
          (e) => e.id == executionId,
          orElse: () => executions.first,
        );
        currentExecution = execution;
      }
    } catch (e) {
      historyError = 'Failed to load execution details: ${e.toString()}';
    } finally {
      isLoadingHistory = false;
    }
  }

  @action
  Future<void> retryLoadExecutionDetails(String executionId) async {
    // Clear previous error and retry
    clearHistoryError();
    await loadExecutionDetails(executionId);
  }

  @action
  void clearExecutionHistory() {
    executions = [];
    currentExecution = null;
    historyError = null;
  }

  // ============================================================================
  // Agent Activation Methods
  // ============================================================================

  @action
  void activateAgent(String agentType, Map<String, dynamic> config) {
    // Deactivate previous agent if any
    if (activeAgentType != null && activeAgentType != agentType) {
      activeAgentType = null;
      activeAgentConfig = null;
    }
    // Activate new agent
    activeAgentType = agentType;
    activeAgentConfig = config;
  }

  @action
  void deactivateAgent() {
    activeAgentType = null;
    activeAgentConfig = null;
  }

  bool isAgentActive(String agentType) => activeAgentType == agentType;

  // ============================================================================
  // Mock Data Methods (replaced with seed data)
  // ============================================================================
}
