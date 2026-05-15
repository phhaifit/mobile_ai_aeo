import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/url_link.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_link_usecase.dart';

part 'url_link_store.g.dart';

class UrlLinkStore = _UrlLinkStore with _$UrlLinkStore;

abstract class _UrlLinkStore with Store {
  final GetUrlLinksUseCase _getLinksUseCase;
  final AddUrlLinkUseCase _addLinkUseCase;
  final UpdateUrlLinkUseCase _updateLinkUseCase;
  final DeleteUrlLinkUseCase _deleteLinkUseCase;

  _UrlLinkStore(
    this._getLinksUseCase,
    this._addLinkUseCase,
    this._updateLinkUseCase,
    this._deleteLinkUseCase,
  );

  @observable
  ObservableList<UrlLink> links = ObservableList<UrlLink>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isProcessing = false;

  @action
  Future<void> getLinks(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      final result = await _getLinksUseCase(projectId);
      links = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlLinkStore.getLinks error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addLink(
    String projectId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final newLink = await _addLinkUseCase(projectId, linkData);
      links.add(newLink);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlLinkStore.addLink error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> updateLink(
    String projectId,
    String linkId,
    Map<String, dynamic> linkData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final updatedLink = await _updateLinkUseCase(projectId, linkId, linkData);
      final index = links.indexWhere((l) => l.id == linkId);
      if (index != -1) {
        links[index] = updatedLink;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('UrlLinkStore.updateLink error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> deleteLink(String projectId, String linkId) async {
    try {
      isProcessing = true;
      errorMessage = null;
      await _deleteLinkUseCase(projectId, linkId);
      links.removeWhere((l) => l.id == linkId);
    } catch (e) {
      errorMessage = e.toString();
      print('UrlLinkStore.deleteLink error: $e');
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
    links.clear();
    isLoading = false;
    errorMessage = null;
    isProcessing = false;
  }
}
