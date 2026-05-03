import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';

class GetContentProfilesUseCase extends UseCase<List<ContentProfile>, String> {
  final ContentProfileRepository _repository;

  GetContentProfilesUseCase(this._repository);

  @override
  Future<List<ContentProfile>> call({required String params}) {
    return _repository.getContentProfiles(params);
  }
}
