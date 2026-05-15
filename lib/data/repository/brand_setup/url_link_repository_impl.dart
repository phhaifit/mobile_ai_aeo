import 'package:boilerplate/data/network/apis/brand_setup/url_link_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_link.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_link_repository.dart';

class UrlLinkRepositoryImpl extends UrlLinkRepository {
  final UrlLinkApi _api;

  UrlLinkRepositoryImpl(this._api);

  @override
  Future<List<UrlLink>> getLinks(String projectId) async {
    try {
      return await _api.getLinks(projectId);
    } catch (e) {
      print('UrlLinkRepositoryImpl.getLinks error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlLink> getLink(String projectId, String linkId) async {
    try {
      return await _api.getLink(projectId, linkId);
    } catch (e) {
      print('UrlLinkRepositoryImpl.getLink error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlLink> addLink(
      String projectId, Map<String, dynamic> linkData) async {
    try {
      return await _api.addLink(projectId, linkData);
    } catch (e) {
      print('UrlLinkRepositoryImpl.addLink error: $e');
      rethrow;
    }
  }

  @override
  Future<UrlLink> updateLink(
    String projectId,
    String linkId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      return await _api.updateLink(projectId, linkId, linkData);
    } catch (e) {
      print('UrlLinkRepositoryImpl.updateLink error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLink(String projectId, String linkId) async {
    try {
      return await _api.deleteLink(projectId, linkId);
    } catch (e) {
      print('UrlLinkRepositoryImpl.deleteLink error: $e');
      rethrow;
    }
  }
}
