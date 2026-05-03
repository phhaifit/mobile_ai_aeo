import 'package:boilerplate/domain/entity/seo/cluster_plan.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart' as seo_opt;

class GenerateClusterPlanUseCase {
  final seo_opt.SeoRepository repository;

  GenerateClusterPlanUseCase({required this.repository});

  Future<ClusterPlan> call(String projectId, String topic) {
    return repository.generateClusterPlan(projectId, topic);
  }
}
