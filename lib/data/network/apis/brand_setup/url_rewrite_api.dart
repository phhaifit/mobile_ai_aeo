import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_rewrite.dart';

class UrlRewriteApi {
  final DioClient _dioClient;

  UrlRewriteApi(this._dioClient);

  /// Get all URL rewrites for a project
  Future<List<UrlRewrite>> getRewrites(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.urlRewrites(projectId),
      );
      final list = res.data as List<dynamic>;
      return list
          .map((json) => UrlRewrite.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('UrlRewriteApi.getRewrites error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get a specific URL rewrite
  Future<UrlRewrite> getRewrite(String projectId, String rewriteId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.urlRewrite(projectId, rewriteId),
      );
      return UrlRewrite.fromJson(res.data);
    } catch (e) {
      print('UrlRewriteApi.getRewrite error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a URL rewrite
  Future<UrlRewrite> addRewrite(
    String projectId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.urlRewrites(projectId),
        data: rewriteData,
      );
      return UrlRewrite.fromJson(res.data);
    } catch (e) {
      print('UrlRewriteApi.addRewrite error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update a URL rewrite
  Future<UrlRewrite> updateRewrite(
    String projectId,
    String rewriteId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.urlRewrite(projectId, rewriteId),
        data: rewriteData,
      );
      return UrlRewrite.fromJson(res.data);
    } catch (e) {
      print('UrlRewriteApi.updateRewrite error: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a URL rewrite
  Future<void> deleteRewrite(String projectId, String rewriteId) async {
    try {
      await _dioClient.dio.delete(
        Endpoints.urlRewrite(projectId, rewriteId),
      );
    } catch (e) {
      print('UrlRewriteApi.deleteRewrite error: ${e.toString()}');
      rethrow;
    }
  }
}
