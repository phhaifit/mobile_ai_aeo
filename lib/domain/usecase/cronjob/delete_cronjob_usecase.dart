import '../../../domain/repository/cronjob_repository.dart';

class DeleteCronjobUseCase {
  final CronjobRepository repository;

  DeleteCronjobUseCase({required this.repository});

  Future<void> call(String id) async {
    return await repository.deleteCronjob(id);
  }
}
