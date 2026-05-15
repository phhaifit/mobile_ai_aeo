import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';
import 'package:boilerplate/domain/repository/brand_setup/brand_positioning_repository.dart';

class GetBrandPositioningUseCase {
  final BrandPositioningRepository _repository;

  GetBrandPositioningUseCase(this._repository);

  Future<BrandPositioning> call(String projectId) async {
    try {
      return await _repository.getBrandPositioning(projectId);
    } catch (e) {
      print('GetBrandPositioningUseCase error: $e');
      rethrow;
    }
  }
}

class SaveBrandPositioningUseCase {
  final BrandPositioningRepository _repository;

  SaveBrandPositioningUseCase(this._repository);

  Future<BrandPositioning> call(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      return await _repository.saveBrandPositioning(projectId, positioningData);
    } catch (e) {
      print('SaveBrandPositioningUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateBrandPositioningUseCase {
  final BrandPositioningRepository _repository;

  UpdateBrandPositioningUseCase(this._repository);

  Future<BrandPositioning> call(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      return await _repository.updateBrandPositioning(
        projectId,
        positioningData,
      );
    } catch (e) {
      print('UpdateBrandPositioningUseCase error: $e');
      rethrow;
    }
  }
}
