import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;

class PublishContentUseCase {
  final seo_opt.SeoRepository repository;

  PublishContentUseCase({required this.repository});

  /// Publishes the content — backend auto-embeds into vector DB and inserts internal links.
  Future<void> publish(String contentId) {
    return repository.publishContent(contentId);
  }

  /// Republish after SEO optimization to re-trigger internal linking.
  Future<void> republish(String contentId) {
    return repository.republishContent(contentId);
  }
}
