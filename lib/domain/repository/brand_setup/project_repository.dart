import 'package:boilerplate/domain/entity/brand_setup/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project> getProject(String projectId);

  Future<Project> createProject(Map<String, dynamic> projectData);

  Future<Project> switchProject(String projectId);

  Future<Project> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  );

  Future<void> deleteProject(String projectId);
}
