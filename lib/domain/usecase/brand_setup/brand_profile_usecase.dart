import 'package:boilerplate/domain/entity/brand_setup/brand_profile.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_profile_repository.dart';

class GetBrandProfileUseCase {
  final BrandProfileRepository _repository;

  GetBrandProfileUseCase(this._repository);

  Future<BrandProfile> call(String projectId) async {
    try {
      return await _repository.getBrandProfile(projectId);
    } catch (e) {
      print('GetBrandProfileUseCase error: $e');
      rethrow;
    }
  }
}

class SaveBrandProfileUseCase {
  final BrandProfileRepository _repository;

  SaveBrandProfileUseCase(this._repository);

  Future<BrandProfile> call(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      return await _repository.saveBrandProfile(projectId, profileData);
    } catch (e) {
      print('SaveBrandProfileUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateBrandProfileUseCase {
  final BrandProfileRepository _repository;

  UpdateBrandProfileUseCase(this._repository);

  Future<BrandProfile> call(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      return await _repository.updateBrandProfile(projectId, profileData);
    } catch (e) {
      print('UpdateBrandProfileUseCase error: $e');
      rethrow;
    }
  }
}
