import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/project.dart';

class ProjectApi {
  final DioClient _dioClient;

  ProjectApi(this._dioClient);

  /// Get all projects for the current user
  Future<List<Project>> getProjects() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.projects);
      final list = res.data as List<dynamic>;
      return list
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('ProjectApi.getProjects error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get a specific project
  Future<Project> getProject(String projectId) async {
    try {
      final res = await _dioClient.dio.get(Endpoints.project(projectId));
      return Project.fromJson(res.data);
    } catch (e) {
      print('ProjectApi.getProject error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a new project
  Future<Project> createProject(Map<String, dynamic> projectData) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.projects,
        data: projectData,
      );
      return Project.fromJson(res.data);
    } catch (e) {
      print('ProjectApi.createProject error: ${e.toString()}');
      rethrow;
    }
  }

  /// Switch to a different project
  Future<Project> switchProject(String projectId) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.switchProject(projectId),
      );
      return Project.fromJson(res.data);
    } catch (e) {
      print('ProjectApi.switchProject error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update a project
  Future<Project> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.project(projectId),
        data: projectData,
      );
      return Project.fromJson(res.data);
    } catch (e) {
      print('ProjectApi.updateProject error: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      await _dioClient.dio.delete(Endpoints.deleteProject(projectId));
    } catch (e) {
      print('ProjectApi.deleteProject error: ${e.toString()}');
      rethrow;
    }
  }
}
