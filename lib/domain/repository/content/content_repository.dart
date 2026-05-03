import 'package:boilerplate/domain/entity/content/content_item.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';

abstract class ContentRepository {
  /// Fetch user's projects (used to discover the default projectId).
  Future<List<Map<String, dynamic>>> listProjects();

  /// Fetch the contents picker source for a project.
  Future<List<ContentItem>> listProjectContents(String projectId);

  /// Kick off the regenerate flow for the given content + operation.
  /// Returns the job acknowledgement; the actual regenerated body is
  /// retrieved later via [pollByJob].
  Future<ContentResult> startProcess(ContentRequest request);

  /// Poll the regenerate job. Returns null while the worker is still
  /// running, a populated result when finished.
  Future<ContentResult?> pollByJob(String jobId);
}
