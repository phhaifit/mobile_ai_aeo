import '../../repository/trend/trend_repository.dart';

class TriggerAnalysisUseCase {
  final TrendRepository repository;

  TriggerAnalysisUseCase({required this.repository});

  Future<void> call(String projectId) async {
    await repository.triggerAnalysisRun(projectId);
  }
}
