import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/entity/cronjob/cronjob_execution.dart';

abstract class CronjobDataSource {
  /// Get all cronjobs from local storage
  Future<List<Cronjob>> getAllCronjobs();

  /// Get a specific cronjob by ID
  Future<Cronjob?> getCronjobById(String id);

  /// Save or update a cronjob in local storage
  Future<void> saveCronjob(Cronjob cronjob);

  /// Delete a cronjob from local storage
  Future<void> deleteCronjob(String id);

  /// Get all executions for a specific cronjob
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId);

  /// Save or update a cronjob execution in local storage
  Future<void> saveExecution(CronjobExecution execution);

  /// Get execution details by ID
  Future<CronjobExecution?> getExecutionById(String executionId);

  /// Delete an execution from local storage
  Future<void> deleteExecution(String executionId);
}
