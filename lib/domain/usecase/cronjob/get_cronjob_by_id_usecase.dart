import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/repository/cronjob_repository.dart';

class GetCronjobByIdUseCase {
  final CronjobRepository repository;

  GetCronjobByIdUseCase({required this.repository});

  Future<Cronjob?> call(String id) async {
    return await repository.getCronjobById(id);
  }
}
