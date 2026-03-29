import 'package:boilerplate/domain/entity/trend/weekly_report.dart';
import 'package:boilerplate/domain/entity/trend/trend_data_point.dart';
import 'package:boilerplate/domain/entity/trend/trend_period.dart';
import 'package:boilerplate/domain/entity/trend/performance_comparison.dart';
import 'package:boilerplate/domain/entity/trend/improvement_suggestion.dart';
import 'package:boilerplate/domain/repository/trend/trend_repository.dart';
import 'package:boilerplate/data/service/trend_seed_data.dart';

class TrendRepositoryImpl implements TrendRepository {
  @override
  Future<WeeklyReport> getWeeklyReport() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return TrendSeedData.getWeeklyReport();
  }

  @override
  Future<List<TrendDataPoint>> getTrendData(TrendPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TrendSeedData.getTrendDataForPeriod(period);
  }

  @override
  Future<List<PerformanceComparison>> getPerformanceComparisons() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return TrendSeedData.getPerformanceComparisons();
  }

  @override
  Future<List<ImprovementSuggestion>> getImprovementSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return TrendSeedData.getImprovementSuggestions();
  }
}
