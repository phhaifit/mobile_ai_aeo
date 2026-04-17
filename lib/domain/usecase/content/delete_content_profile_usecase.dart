import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';

class DeleteContentProfileUseCase extends UseCase<void, DeleteContentProfileParams> {
  final ContentProfileRepository _repository;

  DeleteContentProfileUseCase(this._repository);

  @override
  Future<void> call({required DeleteContentProfileParams params}) {
    return _repository.deleteContentProfile(
      projectId: params.projectId,
      contentProfileId: params.contentProfileId,
    );
  }
}

class DeleteContentProfileParams {
  final String projectId;
  final String contentProfileId;

  DeleteContentProfileParams({
    required this.projectId,
    required this.contentProfileId,
  });
}
