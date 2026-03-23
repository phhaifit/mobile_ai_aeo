import '../../../domain/entity/cronjob/cronjob_execution.dart';
import '../../../domain/repository/cronjob_repository.dart';

class GetExecutionByIdUseCase {
  final CronjobRepository repository;

  GetExecutionByIdUseCase({required this.repository});

  Future<CronjobExecution?> call(String executionId) async {
    return await repository.getExecutionById(executionId);
  }
}
