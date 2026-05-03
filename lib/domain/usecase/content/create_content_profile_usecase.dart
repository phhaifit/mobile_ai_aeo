import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';

class CreateContentProfileUseCase extends UseCase<ContentProfile, CreateContentProfileParams> {
  final ContentProfileRepository _repository;

  CreateContentProfileUseCase(this._repository);

  @override
  Future<ContentProfile> call({required CreateContentProfileParams params}) {
    return _repository.createContentProfile(
      projectId: params.projectId,
      name: params.name,
      description: params.description,
      voiceAndTone: params.voiceAndTone,
      audience: params.audience,
    );
  }
}

class CreateContentProfileParams {
  final String projectId;
  final String name;
  final String description;
  final String voiceAndTone;
  final String audience;

  CreateContentProfileParams({
    required this.projectId,
    required this.name,
    required this.description,
    required this.voiceAndTone,
    required this.audience,
  });
}
