import '../../entity/seo/seo_data.dart';
import '../../repository/seo_repository.dart';

class GetSeoDataUseCase {
  final SeoRepository repository;

  GetSeoDataUseCase({required this.repository});

  Future<SeoData> call() async {
    return await repository.getSeoOptimizationData();
  }
}
