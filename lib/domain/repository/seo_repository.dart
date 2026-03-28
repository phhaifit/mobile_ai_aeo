import '../entity/seo/seo_data.dart';

abstract class SeoRepository {
  /// Get all SEO optimization data for the dashboard
  Future<SeoData> getSeoOptimizationData();
}
