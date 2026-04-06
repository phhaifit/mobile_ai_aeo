import 'package:boilerplate/data/network/apis/overview/overview_api.dart';
import 'package:boilerplate/domain/entity/overview/overview_metrics.dart';
import 'package:boilerplate/domain/repository/overview/overview_repository.dart';

class OverviewRepositoryImpl extends OverviewRepository {
  final OverviewApi _overviewApi;

  OverviewRepositoryImpl(this._overviewApi);

  @override
  Future<OverviewMetrics> getOverviewMetrics({
    required String projectId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _overviewApi.getOverviewMetrics(
        projectId: projectId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('OverviewRepositoryImpl.getOverviewMetrics error: ${e.toString()}');
      rethrow;
    }
  }
}
