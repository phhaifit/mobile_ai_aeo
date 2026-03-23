import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/repository/cronjob_repository.dart';

class UpdateCronjobUseCase {
  final CronjobRepository repository;

  UpdateCronjobUseCase({required this.repository});

  Future<Cronjob> call(Cronjob cronjob) async {
    return await repository.updateCronjob(cronjob);
  }
}
