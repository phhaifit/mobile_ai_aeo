import 'package:boilerplate/domain/entity/brand_setup/url_link.dart';
import 'package:boilerplate/domain/repository/brand_setup/url_link_repository.dart';

class GetUrlLinksUseCase {
  final UrlLinkRepository _repository;

  GetUrlLinksUseCase(this._repository);

  Future<List<UrlLink>> call(String projectId) async {
    try {
      return await _repository.getLinks(projectId);
    } catch (e) {
      print('GetUrlLinksUseCase error: $e');
      rethrow;
    }
  }
}

class AddUrlLinkUseCase {
  final UrlLinkRepository _repository;

  AddUrlLinkUseCase(this._repository);

  Future<UrlLink> call(
    String projectId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      return await _repository.addLink(projectId, linkData);
    } catch (e) {
      print('AddUrlLinkUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateUrlLinkUseCase {
  final UrlLinkRepository _repository;

  UpdateUrlLinkUseCase(this._repository);

  Future<UrlLink> call(
    String projectId,
    String linkId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      return await _repository.updateLink(projectId, linkId, linkData);
    } catch (e) {
      print('UpdateUrlLinkUseCase error: $e');
      rethrow;
    }
  }
}

class DeleteUrlLinkUseCase {
  final UrlLinkRepository _repository;

  DeleteUrlLinkUseCase(this._repository);

  Future<void> call(String projectId, String linkId) async {
    try {
      return await _repository.deleteLink(projectId, linkId);
    } catch (e) {
      print('DeleteUrlLinkUseCase error: $e');
      rethrow;
    }
  }
}
