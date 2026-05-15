import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/knowledge_base_entry.dart';

class KnowledgeBaseApi {
  final DioClient _dioClient;

  KnowledgeBaseApi(this._dioClient);

  /// Get all knowledge base entries for a project
  Future<List<KnowledgeBaseEntry>> getEntries(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.knowledgeBaseEntries(projectId),
      );
      final list = res.data as List<dynamic>;
      return list
          .map((json) =>
              KnowledgeBaseEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('KnowledgeBaseApi.getEntries error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get a specific knowledge base entry
  Future<KnowledgeBaseEntry> getEntry(String projectId, String entryId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.knowledgeBaseEntry(projectId, entryId),
      );
      return KnowledgeBaseEntry.fromJson(res.data);
    } catch (e) {
      print('KnowledgeBaseApi.getEntry error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a knowledge base entry
  Future<KnowledgeBaseEntry> addEntry(
    String projectId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.knowledgeBaseEntries(projectId),
        data: entryData,
      );
      return KnowledgeBaseEntry.fromJson(res.data);
    } catch (e) {
      print('KnowledgeBaseApi.addEntry error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update a knowledge base entry
  Future<KnowledgeBaseEntry> updateEntry(
    String projectId,
    String entryId,
    Map<String, dynamic> entryData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.knowledgeBaseEntry(projectId, entryId),
        data: entryData,
      );
      return KnowledgeBaseEntry.fromJson(res.data);
    } catch (e) {
      print('KnowledgeBaseApi.updateEntry error: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a knowledge base entry
  Future<void> deleteEntry(String projectId, String entryId) async {
    try {
      await _dioClient.dio.delete(
        Endpoints.knowledgeBaseEntry(projectId, entryId),
      );
    } catch (e) {
      print('KnowledgeBaseApi.deleteEntry error: ${e.toString()}');
      rethrow;
    }
  }
}
