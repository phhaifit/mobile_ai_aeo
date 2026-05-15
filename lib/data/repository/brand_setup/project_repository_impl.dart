import 'package:boilerplate/data/network/apis/brand_setup/project_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/project.dart';
import 'package:boilerplate/domain/repository/brand_setup/project_repository.dart';

class ProjectRepositoryImpl extends ProjectRepository {
  final ProjectApi _api;

  ProjectRepositoryImpl(this._api);

  @override
  Future<List<Project>> getProjects() async {
    try {
      return await _api.getProjects();
    } catch (e) {
      print('ProjectRepositoryImpl.getProjects error: $e');
      rethrow;
    }
  }

  @override
  Future<Project> getProject(String projectId) async {
    try {
      return await _api.getProject(projectId);
    } catch (e) {
      print('ProjectRepositoryImpl.getProject error: $e');
      rethrow;
    }
  }

  @override
  Future<Project> createProject(Map<String, dynamic> projectData) async {
    try {
      return await _api.createProject(projectData);
    } catch (e) {
      print('ProjectRepositoryImpl.createProject error: $e');
      rethrow;
    }
  }

  @override
  Future<Project> switchProject(String projectId) async {
    try {
      return await _api.switchProject(projectId);
    } catch (e) {
      print('ProjectRepositoryImpl.switchProject error: $e');
      rethrow;
    }
  }

  @override
  Future<Project> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    try {
      return await _api.updateProject(projectId, projectData);
    } catch (e) {
      print('ProjectRepositoryImpl.updateProject error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      return await _api.deleteProject(projectId);
    } catch (e) {
      print('ProjectRepositoryImpl.deleteProject error: $e');
      rethrow;
    }
  }
}
