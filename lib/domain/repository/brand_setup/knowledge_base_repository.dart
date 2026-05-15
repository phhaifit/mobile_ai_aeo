import 'package:boilerplate/domain/entity/brand_setup/knowledge_base_entry.dart';

abstract class KnowledgeBaseRepository {
  Future<List<KnowledgeBaseEntry>> getEntries(String projectId);

  Future<KnowledgeBaseEntry> getEntry(String projectId, String entryId);

  Future<KnowledgeBaseEntry> addEntry(
    String projectId,
    Map<String, dynamic> entryData,
  );

  Future<KnowledgeBaseEntry> updateEntry(
    String projectId,
    String entryId,
    Map<String, dynamic> entryData,
  );

  Future<void> deleteEntry(String projectId, String entryId);
}
