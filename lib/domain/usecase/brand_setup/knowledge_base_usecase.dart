import 'package:boilerplate/domain/entity/brand_setup/knowledge_base_entry.dart';
import 'package:boilerplate/domain/repository/brand_setup/knowledge_base_repository.dart';

class GetKnowledgeBaseEntriesUseCase {
  final KnowledgeBaseRepository _repository;

  GetKnowledgeBaseEntriesUseCase(this._repository);

  Future<List<KnowledgeBaseEntry>> call(String projectId) async {
    try {
      return await _repository.getEntries(projectId);
    } catch (e) {
      print('GetKnowledgeBaseEntriesUseCase error: $e');
      rethrow;
    }
  }
}

class AddKnowledgeBaseEntryUseCase {
  final KnowledgeBaseRepository _repository;

  AddKnowledgeBaseEntryUseCase(this._repository);

  Future<KnowledgeBaseEntry> call(
    String projectId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      return await _repository.addEntry(projectId, entryData);
    } catch (e) {
      print('AddKnowledgeBaseEntryUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateKnowledgeBaseEntryUseCase {
  final KnowledgeBaseRepository _repository;

  UpdateKnowledgeBaseEntryUseCase(this._repository);

  Future<KnowledgeBaseEntry> call(
    String projectId,
    String entryId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      return await _repository.updateEntry(projectId, entryId, entryData);
    } catch (e) {
      print('UpdateKnowledgeBaseEntryUseCase error: $e');
      rethrow;
    }
  }
}

class DeleteKnowledgeBaseEntryUseCase {
  final KnowledgeBaseRepository _repository;

  DeleteKnowledgeBaseEntryUseCase(this._repository);

  Future<void> call(String projectId, String entryId) async {
    try {
      return await _repository.deleteEntry(projectId, entryId);
    } catch (e) {
      print('DeleteKnowledgeBaseEntryUseCase error: $e');
      rethrow;
    }
  }
}
