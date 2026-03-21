import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';

class SummarizeContentUseCase extends UseCase<ContentResult, ContentRequest> {
  final ContentRepository _contentRepository;

  SummarizeContentUseCase(this._contentRepository);

  @override
  Future<ContentResult> call({required ContentRequest params}) {
    final request = ContentRequest(
      text: params.text,
      operation: ContentOperation.summarize,
      options: params.options,
    );
    return _contentRepository.processContent(request);
  }
}
