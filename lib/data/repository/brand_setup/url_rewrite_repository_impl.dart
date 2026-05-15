import 'package:boilerplate/data/network/apis/brand_setup/url_rewrite_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_rewrite.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_rewrite_repository.dart';

class UrlRewriteRepositoryImpl extends UrlRewriteRepository {
  final UrlRewriteApi _api;

  UrlRewriteRepositoryImpl(this._api);

  @override
  Future<List<UrlRewrite>> getRewrites(String projectId) async {
    try {
      return await _api.getRewrites(projectId);
    } catch (e) {
      print('UrlRewriteRepositoryImpl.getRewrites error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlRewrite> getRewrite(String projectId, String rewriteId) async {
    try {
      return await _api.getRewrite(projectId, rewriteId);
    } catch (e) {
      print('UrlRewriteRepositoryImpl.getRewrite error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlRewrite> addRewrite(
    String projectId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      return await _api.addRewrite(projectId, rewriteData);
    } catch (e) {
      print('UrlRewriteRepositoryImpl.addRewrite error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlRewrite> updateRewrite(
    String projectId,
    String rewriteId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      return await _api.updateRewrite(projectId, rewriteId, rewriteData);
    } catch (e) {
      print('UrlRewriteRepositoryImpl.updateRewrite error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteRewrite(String projectId, String rewriteId) async {
    try {
      return await _api.deleteRewrite(projectId, rewriteId);
    } catch (e) {
      print('UrlRewriteRepositoryImpl.deleteRewrite error: $e');
      rethrow;
    }
  }
}
