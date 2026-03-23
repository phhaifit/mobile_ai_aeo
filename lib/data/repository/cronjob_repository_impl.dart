import '../../domain/entity/cronjob/cronjob.dart';
import '../../domain/entity/cronjob/cronjob_execution.dart';
import '../../domain/repository/cronjob_repository.dart';
import '../local/datasource/cronjob_datasource.dart';

class CronjobRepositoryImpl implements CronjobRepository {
  final CronjobDataSource localDataSource;

  CronjobRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Cronjob>> getAllCronjobs() async {
    return await localDataSource.getAllCronjobs();
  }

  @override
  Future<Cronjob?> getCronjobById(String id) async {
    return await localDataSource.getCronjobById(id);
  }

  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async {
    final newCronjob = Cronjob(
      id: cronjob.id,
      name: cronjob.name,
      description: cronjob.description,
      schedule: cronjob.schedule,
      schedulePattern: cronjob.schedulePattern,
      sourceType: cronjob.sourceType,
      sourceUrl: cronjob.sourceUrl,
      articleCountPerRun: cronjob.articleCountPerRun,
      destinations: cronjob.destinations,
      isEnabled: cronjob.isEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await localDataSource.saveCronjob(newCronjob);
    return newCronjob;
  }

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async {
    final updatedCronjob = Cronjob(
      id: cronjob.id,
      name: cronjob.name,
      description: cronjob.description,
      schedule: cronjob.schedule,
      schedulePattern: cronjob.schedulePattern,
      sourceType: cronjob.sourceType,
      sourceUrl: cronjob.sourceUrl,
      articleCountPerRun: cronjob.articleCountPerRun,
      destinations: cronjob.destinations,
      isEnabled: cronjob.isEnabled,
      createdAt: cronjob.createdAt,
      updatedAt: DateTime.now(),
    );
    await localDataSource.saveCronjob(updatedCronjob);
    return updatedCronjob;
  }

  @override
  Future<void> deleteCronjob(String id) async {
    await localDataSource.deleteCronjob(id);
  }

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async {
    return await localDataSource.getCronjobExecutions(cronjobId);
  }

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async {
    await localDataSource.saveExecution(execution);
    return execution;
  }

  @override
  Future<CronjobExecution?> getExecutionById(String executionId) async {
    return await localDataSource.getExecutionById(executionId);
  }
}
