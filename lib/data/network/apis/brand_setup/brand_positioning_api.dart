import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';

class BrandPositioningApi {
  final DioClient _dioClient;

  BrandPositioningApi(this._dioClient);

  /// Get brand positioning data
  Future<BrandPositioning> getBrandPositioning(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.brandPositioning(projectId),
      );
      return BrandPositioning.fromJson(res.data);
    } catch (e) {
      print('BrandPositioningApi.getBrandPositioning error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create or update brand positioning
  Future<BrandPositioning> saveBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.brandPositioning(projectId),
        data: positioningData,
      );
      return BrandPositioning.fromJson(res.data);
    } catch (e) {
      print('BrandPositioningApi.saveBrandPositioning error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update brand positioning
  Future<BrandPositioning> updateBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.brandPositioning(projectId),
        data: positioningData,
      );
      return BrandPositioning.fromJson(res.data);
    } catch (e) {
      print(
          'BrandPositioningApi.updateBrandPositioning error: ${e.toString()}');
      rethrow;
    }
  }
}
