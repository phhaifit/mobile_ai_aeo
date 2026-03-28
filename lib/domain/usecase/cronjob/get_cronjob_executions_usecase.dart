import '../../../domain/entity/cronjob/cronjob_execution.dart';
import '../../../domain/repository/cronjob_repository.dart';

class GetCronjobExecutionsUseCase {
  final CronjobRepository repository;

  GetCronjobExecutionsUseCase({required this.repository});

  Future<List<CronjobExecution>> call(String cronjobId) async {
    return await repository.getCronjobExecutions(cronjobId);
  }
}
