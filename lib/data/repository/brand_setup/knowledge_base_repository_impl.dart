import 'package:boilerplate/data/network/apis/brand_setup/knowledge_base_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/knowledge_base_entry.dart';
import 'package:boilerplate/domain/repository/brand_setup/knowledge_base_repository.dart';

class KnowledgeBaseRepositoryImpl extends KnowledgeBaseRepository {
  final KnowledgeBaseApi _api;

  KnowledgeBaseRepositoryImpl(this._api);

  @override
  Future<List<KnowledgeBaseEntry>> getEntries(String projectId) async {
    try {
      return await _api.getEntries(projectId);
    } catch (e) {
      print('KnowledgeBaseRepositoryImpl.getEntries error: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeBaseEntry> getEntry(String projectId, String entryId) async {
    try {
      return await _api.getEntry(projectId, entryId);
    } catch (e) {
      print('KnowledgeBaseRepositoryImpl.getEntry error: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeBaseEntry> addEntry(
    String projectId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      return await _api.addEntry(projectId, entryData);
    } catch (e) {
      print('KnowledgeBaseRepositoryImpl.addEntry error: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeBaseEntry> updateEntry(
    String projectId,
    String entryId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      return await _api.updateEntry(projectId, entryId, entryData);
    } catch (e) {
      print('KnowledgeBaseRepositoryImpl.updateEntry error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEntry(String projectId, String entryId) async {
    try {
      return await _api.deleteEntry(projectId, entryId);
    } catch (e) {
      print('KnowledgeBaseRepositoryImpl.deleteEntry error: $e');
      rethrow;
    }
  }
}
