import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_rewrite.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_rewrite_usecase.dart';

part 'url_rewrite_store.g.dart';

class UrlRewriteStore = _UrlRewriteStore with _$UrlRewriteStore;

abstract class _UrlRewriteStore with Store {
  final GetUrlRewritesUseCase _getRewritesUseCase;
  final AddUrlRewriteUseCase _addRewriteUseCase;
  final UpdateUrlRewriteUseCase _updateRewriteUseCase;
  final DeleteUrlRewriteUseCase _deleteRewriteUseCase;

  _UrlRewriteStore(
    this._getRewritesUseCase,
    this._addRewriteUseCase,
    this._updateRewriteUseCase,
    this._deleteRewriteUseCase,
  );

  @observable
  ObservableList<UrlRewrite> rewrites = ObservableList<UrlRewrite>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isProcessing = false;

  @action
  Future<void> getRewrites(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      final result = await _getRewritesUseCase(projectId);
      rewrites = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlRewriteStore.getRewrites error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addRewrite(
    String projectId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final newRewrite = await _addRewriteUseCase(projectId, rewriteData);
      rewrites.add(newRewrite);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlRewriteStore.addRewrite error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> updateRewrite(
    String projectId,
    String rewriteId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final updatedRewrite =
          await _updateRewriteUseCase(projectId, rewriteId, rewriteData);
      final index = rewrites.indexWhere((r) => r.id == rewriteId);
      if (index != -1) {
        rewrites[index] = updatedRewrite;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('UrlRewriteStore.updateRewrite error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> deleteRewrite(String projectId, String rewriteId) async {
    try {
      isProcessing = true;
      errorMessage = null;
      await _deleteRewriteUseCase(projectId, rewriteId);
      rewrites.removeWhere((r) => r.id == rewriteId);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlRewriteStore.deleteRewrite error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    rewrites.clear();
    isLoading = false;
    errorMessage = null;
    isProcessing = false;
  }
}
