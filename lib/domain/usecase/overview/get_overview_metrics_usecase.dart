import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/overview/overview_metrics.dart';
import 'package:boilerplate/domain/repository/overview/overview_repository.dart';

class GetOverviewMetricsUseCase
    extends UseCase<OverviewMetrics, GetOverviewMetricsParams> {
  final OverviewRepository _overviewRepository;

  GetOverviewMetricsUseCase(this._overviewRepository);

  @override
  Future<OverviewMetrics> call({required GetOverviewMetricsParams params}) {
    return _overviewRepository.getOverviewMetrics(
      projectId: params.projectId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetOverviewMetricsParams {
  final String projectId;
  final String startDate;
  final String endDate;

  GetOverviewMetricsParams({
    required this.projectId,
    required this.startDate,
    required this.endDate,
  });
}
