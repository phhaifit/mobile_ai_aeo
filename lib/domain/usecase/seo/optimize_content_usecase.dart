import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;

class OptimizeContentUseCase {
  final seo_opt.SeoRepository repository;

  OptimizeContentUseCase({required this.repository});

  Future<void> call(String contentId, String improvement) {
    return repository.optimizeContent(contentId, improvement);
  }
}
