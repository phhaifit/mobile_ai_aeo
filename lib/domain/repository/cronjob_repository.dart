import '../entity/cronjob/cronjob.dart';
import '../entity/cronjob/cronjob_execution.dart';

abstract class CronjobRepository {
  /// Get all cronjobs
  Future<List<Cronjob>> getAllCronjobs();

  /// Get a specific cronjob by ID
  Future<Cronjob?> getCronjobById(String id);

  /// Create a new cronjob
  Future<Cronjob> createCronjob(Cronjob cronjob);

  /// Update an existing cronjob
  Future<Cronjob> updateCronjob(Cronjob cronjob);

  /// Delete a cronjob by ID
  Future<void> deleteCronjob(String id);

  /// Get all executions for a specific cronjob
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId);

  /// Create a new cronjob execution
  Future<CronjobExecution> createExecution(CronjobExecution execution);

  /// Get execution details by ID
  Future<CronjobExecution?> getExecutionById(String executionId);
}
