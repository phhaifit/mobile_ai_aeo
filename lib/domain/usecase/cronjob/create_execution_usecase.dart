import '../../../domain/entity/cronjob/cronjob_execution.dart';
import '../../../domain/repository/cronjob_repository.dart';

class CreateExecutionUseCase {
  final CronjobRepository repository;

  CreateExecutionUseCase({required this.repository});

  Future<CronjobExecution> call(CronjobExecution execution) async {
    return await repository.createExecution(execution);
  }
}
