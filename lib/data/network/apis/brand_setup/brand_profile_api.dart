import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_profile.dart';

class BrandProfileApi {
  final DioClient _dioClient;

  BrandProfileApi(this._dioClient);

  /// Get brand profile for a project
  Future<BrandProfile> getBrandProfile(String projectId) async {
    try {
      final res =
          await _dioClient.dio.get(Endpoints.getBrandProfile(projectId));
      return BrandProfile.fromJson(res.data);
    } catch (e) {
      print('BrandProfileApi.getBrandProfile error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create or update brand profile
  Future<BrandProfile> saveBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.updateBrandProfile(projectId),
        data: profileData,
      );
      return BrandProfile.fromJson(res.data);
    } catch (e) {
      print('BrandProfileApi.saveBrandProfile error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update brand profile
  Future<BrandProfile> updateBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.updateBrandProfile(projectId),
        data: profileData,
      );
      return BrandProfile.fromJson(res.data);
    } catch (e) {
      print('BrandProfileApi.updateBrandProfile error: ${e.toString()}');
      rethrow;
    }
  }
}
