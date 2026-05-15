import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_link.dart';

class UrlLinkApi {
  final DioClient _dioClient;

  UrlLinkApi(this._dioClient);

  /// Get all URL links for a project
  Future<List<UrlLink>> getLinks(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.urlLinks(projectId),
      );
      final list = res.data as List<dynamic>;
      return list
          .map((json) => UrlLink.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('UrlLinkApi.getLinks error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get a specific URL link
  Future<UrlLink> getLink(String projectId, String linkId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.urlLink(projectId, linkId),
      );
      return UrlLink.fromJson(res.data);
    } catch (e) {
      print('UrlLinkApi.getLink error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a URL link
  Future<UrlLink> addLink(
    String projectId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.urlLinks(projectId),
        data: linkData,
      );
      return UrlLink.fromJson(res.data);
    } catch (e) {
      print('UrlLinkApi.addLink error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update a URL link
  Future<UrlLink> updateLink(
    String projectId,
    String linkId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.urlLink(projectId, linkId),
        data: linkData,
      );
      return UrlLink.fromJson(res.data);
    } catch (e) {
      print('UrlLinkApi.updateLink error: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a URL link
  Future<void> deleteLink(String projectId, String linkId) async {
    try {
      await _dioClient.dio.delete(
        Endpoints.urlLink(projectId, linkId),
      );
    } catch (e) {
      print('UrlLinkApi.deleteLink error: ${e.toString()}');
      rethrow;
    }
  }
}
