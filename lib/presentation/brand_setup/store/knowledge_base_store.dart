import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/knowledge_base_entry.dart';
import 'package:boilerplate/domain/usecase/brand_setup/knowledge_base_usecase.dart';

part 'knowledge_base_store.g.dart';

class KnowledgeBaseStore = _KnowledgeBaseStore with _$KnowledgeBaseStore;

abstract class _KnowledgeBaseStore with Store {
  final GetKnowledgeBaseEntriesUseCase _getEntriesUseCase;
  final AddKnowledgeBaseEntryUseCase _addEntryUseCase;
  final UpdateKnowledgeBaseEntryUseCase _updateEntryUseCase;
  final DeleteKnowledgeBaseEntryUseCase _deleteEntryUseCase;

  _KnowledgeBaseStore(
    this._getEntriesUseCase,
    this._addEntryUseCase,
    this._updateEntryUseCase,
    this._deleteEntryUseCase,
  );

  @observable
  ObservableList<KnowledgeBaseEntry> entries =
      ObservableList<KnowledgeBaseEntry>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isProcessing = false;

  @action
  Future<void> getEntries(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      final result = await _getEntriesUseCase(projectId);
      entries = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      print('KnowledgeBaseStore.getEntries error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addEntry(
    String projectId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final newEntry = await _addEntryUseCase(projectId, entryData);
      entries.add(newEntry);
    } catch (e) {
      errorMessage = e.toString();
      print('KnowledgeBaseStore.addEntry error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> updateEntry(
    String projectId,
    String entryId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final updatedEntry =
          await _updateEntryUseCase(projectId, entryId, entryData);
      final index = entries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        entries[index] = updatedEntry;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('KnowledgeBaseStore.updateEntry error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> deleteEntry(String projectId, String entryId) async {
    try {
      isProcessing = true;
      errorMessage = null;
      await _deleteEntryUseCase(projectId, entryId);
      entries.removeWhere((e) => e.id == entryId);
    } catch (e) {
      errorMessage = e.toString();
      print('KnowledgeBaseStore.deleteEntry error: $e');
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
    entries.clear();
    isLoading = false;
    errorMessage = null;
    isProcessing = false;
  }
}
