import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/analytics/analytics_metrics.dart';
import 'package:boilerplate/domain/repository/analytics/analytics_repository.dart';

class GetAnalyticsMetricsParams {
  final String projectId;
  final String? startDate;
  final String? endDate;

  GetAnalyticsMetricsParams({
    required this.projectId,
    this.startDate,
    this.endDate,
  });
}

class GetAnalyticsMetricsUseCase
    extends UseCase<AnalyticsMetrics, GetAnalyticsMetricsParams> {
  final AnalyticsRepository _repository;

  GetAnalyticsMetricsUseCase(this._repository);

  @override
  Future<AnalyticsMetrics> call(
      {required GetAnalyticsMetricsParams params}) async {
    return await _repository.getAnalyticsMetrics(
      params.projectId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
