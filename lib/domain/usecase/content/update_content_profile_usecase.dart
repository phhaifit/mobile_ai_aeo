import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';

class UpdateContentProfileUseCase extends UseCase<ContentProfile, UpdateContentProfileParams> {
  final ContentProfileRepository _repository;

  UpdateContentProfileUseCase(this._repository);

  @override
  Future<ContentProfile> call({required UpdateContentProfileParams params}) {
    return _repository.updateContentProfile(
      projectId: params.projectId,
      contentProfileId: params.contentProfileId,
      name: params.name,
      description: params.description,
      voiceAndTone: params.voiceAndTone,
      audience: params.audience,
    );
  }
}

class UpdateContentProfileParams {
  final String projectId;
  final String contentProfileId;
  final String name;
  final String description;
  final String voiceAndTone;
  final String audience;

  UpdateContentProfileParams({
    required this.projectId,
    required this.contentProfileId,
    required this.name,
    required this.description,
    required this.voiceAndTone,
    required this.audience,
  });
}
