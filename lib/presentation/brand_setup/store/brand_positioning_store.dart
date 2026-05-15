import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_positioning_usecase.dart';

part 'brand_positioning_store.g.dart';

class BrandPositioningStore = _BrandPositioningStore
    with _$BrandPositioningStore;

abstract class _BrandPositioningStore with Store {
  final GetBrandPositioningUseCase _getPositioningUseCase;
  final SaveBrandPositioningUseCase _savePositioningUseCase;
  final UpdateBrandPositioningUseCase _updatePositioningUseCase;

  _BrandPositioningStore(
    this._getPositioningUseCase,
    this._savePositioningUseCase,
    this._updatePositioningUseCase,
  );

  @observable
  BrandPositioning? brandPositioning;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isSaving = false;

  @action
  Future<void> getBrandPositioning(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      brandPositioning = await _getPositioningUseCase(projectId);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandPositioningStore.getBrandPositioning error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> saveBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      isSaving = true;
      errorMessage = null;
      brandPositioning =
          await _savePositioningUseCase(projectId, positioningData);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandPositioningStore.saveBrandPositioning error: $e');
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<void> updateBrandPositioning(
    String projectId,
    Map<String, dynamic> positioningData,
  ) async {
    try {
      isSaving = true;
      errorMessage = null;
      brandPositioning =
          await _updatePositioningUseCase(projectId, positioningData);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandPositioningStore.updateBrandPositioning error: $e');
    } finally {
      isSaving = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    brandPositioning = null;
    isLoading = false;
    errorMessage = null;
    isSaving = false;
  }
}
