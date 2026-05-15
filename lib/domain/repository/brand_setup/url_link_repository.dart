import 'package:boilerplate/domain/entity/brand_setup/url_link.dart';

abstract class UrlLinkRepository {
  Future<List<UrlLink>> getLinks(String projectId);

  Future<UrlLink> getLink(String projectId, String linkId);

  Future<UrlLink> addLink(String projectId, Map<String, dynamic> linkData);

  Future<UrlLink> updateLink(
    String projectId,
    String linkId,
    Map<String, dynamic> linkData,
  );

  Future<void> deleteLink(String projectId, String linkId);
}
