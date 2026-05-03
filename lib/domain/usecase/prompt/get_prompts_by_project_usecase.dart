import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/prompt/prompt_summary.dart';
import 'package:boilerplate/domain/repository/prompt/prompt_repository.dart';

class GetPromptsByProjectUseCase
    extends UseCase<List<PromptSummary>, String> {
  final PromptRepository _repository;

  GetPromptsByProjectUseCase(this._repository);

  @override
  Future<List<PromptSummary>> call({required String params}) {
    return _repository.getPromptsByProject(params);
  }
}
