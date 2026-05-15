import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';

abstract class BrandPositioningRepository {
  Future<BrandPositioning> getBrandPositioning(String projectId);

  Future<BrandPositioning> saveBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  );

  Future<BrandPositioning> updateBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  );
}
