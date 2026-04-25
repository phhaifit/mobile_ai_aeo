import '../../entity/trend/weekly_report.dart';
import '../../repository/trend/trend_repository.dart';

class GetWeeklyReportUseCase {
  final TrendRepository repository;

  GetWeeklyReportUseCase({required this.repository});

  Future<WeeklyReport> call(String projectId) async {
    return await repository.getWeeklyReport(projectId);
  }
}
