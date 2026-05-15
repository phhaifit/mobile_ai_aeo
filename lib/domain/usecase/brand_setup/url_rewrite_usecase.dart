import 'package:boilerplate/domain/entity/brand_setup/url_rewrite.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_rewrite_repository.dart';

class GetUrlRewritesUseCase {
  final UrlRewriteRepository _repository;

  GetUrlRewritesUseCase(this._repository);

  Future<List<UrlRewrite>> call(String projectId) async {
    try {
      return await _repository.getRewrites(projectId);
    } catch (e) {
      print('GetUrlRewritesUseCase error: $e');
      rethrow;
    }
  }
}

class AddUrlRewriteUseCase {
  final UrlRewriteRepository _repository;

  AddUrlRewriteUseCase(this._repository);

  Future<UrlRewrite> call(
    String projectId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      return await _repository.addRewrite(projectId, rewriteData);
    } catch (e) {
      print('AddUrlRewriteUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateUrlRewriteUseCase {
  final UrlRewriteRepository _repository;

  UpdateUrlRewriteUseCase(this._repository);

  Future<UrlRewrite> call(
    String projectId,
    String rewriteId,
    Map<String, dynamic> rewriteData,
  ) async {
    try {
      return await _repository.updateRewrite(projectId, rewriteId, rewriteData);
    } catch (e) {
      print('UpdateUrlRewriteUseCase error: $e');
      rethrow;
    }
  }
}

class DeleteUrlRewriteUseCase {
  final UrlRewriteRepository _repository;

  DeleteUrlRewriteUseCase(this._repository);

  Future<void> call(String projectId, String rewriteId) async {
    try {
      return await _repository.deleteRewrite(projectId, rewriteId);
    } catch (e) {
      print('DeleteUrlRewriteUseCase error: $e');
      rethrow;
    }
  }
}
