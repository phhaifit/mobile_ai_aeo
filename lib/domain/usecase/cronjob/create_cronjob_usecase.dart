import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/repository/cronjob_repository.dart';

class CreateCronjobUseCase {
  final CronjobRepository repository;

  CreateCronjobUseCase({required this.repository});

  Future<Cronjob> call(Cronjob cronjob) async {
    return await repository.createCronjob(cronjob);
  }
}
