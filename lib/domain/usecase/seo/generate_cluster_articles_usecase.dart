import 'package:boilerplate/domain/entity/seo/cluster_plan.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;

/// Returns the jobId to be used for SSE streaming status updates.
class GenerateClusterArticlesUseCase {
  final seo_opt.SeoRepository repository;

  GenerateClusterArticlesUseCase({required this.repository});

  Future<String> call(String projectId, ClusterPlan plan) {
    return repository.generateClusterArticles(projectId, plan);
  }
}
