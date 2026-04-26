import 'package:boilerplate/domain/entity/seo/content_insight.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;

class GetContentInsightsUseCase {
  final seo_opt.SeoRepository repository;

  GetContentInsightsUseCase({required this.repository});

  Future<List<ContentInsight>> call(String contentId) {
    return repository.getContentInsights(contentId);
  }
}
