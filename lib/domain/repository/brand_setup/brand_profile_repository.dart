import 'package:boilerplate/domain/entity/brand_setup/brand_profile.dart';

abstract class BrandProfileRepository {
  Future<BrandProfile> getBrandProfile(String projectId);

  Future<BrandProfile> saveBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  );

  Future<BrandProfile> updateBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  );
}
