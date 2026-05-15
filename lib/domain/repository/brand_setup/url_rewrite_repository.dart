import 'package:boilerplate/domain/entity/brand_setup/url_rewrite.dart';

abstract class UrlRewriteRepository {
  Future<List<UrlRewrite>> getRewrites(String projectId);

  Future<UrlRewrite> getRewrite(String projectId, String rewriteId);

  Future<UrlRewrite> addRewrite(
    String projectId,
    Map<String, dynamic> rewriteData,
  );

  Future<UrlRewrite> updateRewrite(
    String projectId,
    String rewriteId,
    Map<String, dynamic> rewriteData,
  );

  Future<void> deleteRewrite(String projectId, String rewriteId);
}
