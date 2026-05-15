import 'package:boilerplate/data/network/apis/brand_setup/brand_profile_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_profile.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_profile_repository.dart';

class BrandProfileRepositoryImpl extends BrandProfileRepository {
  final BrandProfileApi _api;

  BrandProfileRepositoryImpl(this._api);

  @override
  Future<BrandProfile> getBrandProfile(String projectId) async {
    try {
      return await _api.getBrandProfile(projectId);
    } catch (e) {
      print('BrandProfileRepositoryImpl.getBrandProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<BrandProfile> saveBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      return await _api.saveBrandProfile(projectId, profileData);
    } catch (e) {
      print('BrandProfileRepositoryImpl.saveBrandProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<BrandProfile> updateBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      return await _api.updateBrandProfile(projectId, profileData);
    } catch (e) {
      print('BrandProfileRepositoryImpl.updateBrandProfile error: $e');
      rethrow;
    }
  }
}
