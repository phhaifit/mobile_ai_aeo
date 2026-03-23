import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/repository/cronjob_repository.dart';

class GetAllCronjobsUseCase {
  final CronjobRepository repository;

  GetAllCronjobsUseCase({required this.repository});

  Future<List<Cronjob>> call() async {
    return await repository.getAllCronjobs();
  }
}
