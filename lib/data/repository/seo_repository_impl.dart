import '../../domain/entity/seo/seo_data.dart';
import '../../domain/repository/seo_repository.dart';
import '../service/seo_seed_data.dart';

class SeoRepositoryImpl implements SeoRepository {
  @override
  Future<SeoData> getSeoOptimizationData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));
    return SeoSeedData.getSampleSeoData();
  }
}
