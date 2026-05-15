import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_profile.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_profile_usecase.dart';

part 'brand_profile_store.g.dart';

class BrandProfileStore = _BrandProfileStore with _$BrandProfileStore;

abstract class _BrandProfileStore with Store {
  final GetBrandProfileUseCase _getBrandProfileUseCase;
  final SaveBrandProfileUseCase _saveBrandProfileUseCase;
  final UpdateBrandProfileUseCase _updateBrandProfileUseCase;

  _BrandProfileStore(
    this._getBrandProfileUseCase,
    this._saveBrandProfileUseCase,
    this._updateBrandProfileUseCase,
  );

  @observable
  BrandProfile? brandProfile;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isSaving = false;

  @action
  Future<void> getBrandProfile(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      brandProfile = await _getBrandProfileUseCase(projectId);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandProfileStore.getBrandProfile error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> saveBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      isSaving = true;
      errorMessage = null;
      brandProfile = await _saveBrandProfileUseCase(projectId, profileData);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandProfileStore.saveBrandProfile error: $e');
    } finally {
      isSaving = false;
    }
  }

  @action
  Future<void> updateBrandProfile(
    String projectId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      isSaving = true;
      errorMessage = null;
      brandProfile = await _updateBrandProfileUseCase(projectId, profileData);
    } catch (e) {
      errorMessage = e.toString();
      print('BrandProfileStore.updateBrandProfile error: $e');
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
    brandProfile = null;
    isLoading = false;
    errorMessage = null;
    isSaving = false;
  }
}
