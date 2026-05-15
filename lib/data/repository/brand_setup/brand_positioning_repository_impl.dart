import 'package:boilerplate/data/network/apis/brand_setup/brand_positioning_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_positioning_repository.dart';

class BrandPositioningRepositoryImpl extends BrandPositioningRepository {
  final BrandPositioningApi _api;

  BrandPositioningRepositoryImpl(this._api);

  @override
  Future<BrandPositioning> getBrandPositioning(String projectId) async {
    try {
      return await _api.getBrandPositioning(projectId);
    } catch (e) {
      print('BrandPositioningRepositoryImpl.getBrandPositioning error: $e');
      rethrow;
    }
  }

  @override
  Future<BrandPositioning> saveBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      return await _api.saveBrandPositioning(projectId, positioningData);
    } catch (e) {
      print('BrandPositioningRepositoryImpl.saveBrandPositioning error: $e');
      rethrow;
    }
  }

  @override
  Future<BrandPositioning> updateBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      return await _api.updateBrandPositioning(projectId, positioningData);
    } catch (e) {
      print('BrandPositioningRepositoryImpl.updateBrandPositioning error: $e');
      rethrow;
    }
  }
}
