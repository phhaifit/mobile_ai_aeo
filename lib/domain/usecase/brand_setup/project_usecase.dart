import 'package:boilerplate/domain/entity/brand_setup/project.dart';
import 'package:boilerplate/domain/repository/brand_setup/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository _repository;

  GetProjectsUseCase(this._repository);

  Future<List<Project>> call() async {
    try {
      return await _repository.getProjects();
    } catch (e) {
      print('GetProjectsUseCase error: $e');
      rethrow;
    }
  }
}

class GetProjectUseCase {
  final ProjectRepository _repository;

  GetProjectUseCase(this._repository);

  Future<Project> call(String projectId) async {
    try {
      return await _repository.getProject(projectId);
    } catch (e) {
      print('GetProjectUseCase error: $e');
      rethrow;
    }
  }
}

class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Project> call(Map<String, dynamic> projectData) async {
    try {
      return await _repository.createProject(projectData);
    } catch (e) {
      print('CreateProjectUseCase error: $e');
      rethrow;
    }
  }
}

class SwitchProjectUseCase {
  final ProjectRepository _repository;

  SwitchProjectUseCase(this._repository);

  Future<Project> call(String projectId) async {
    try {
      return await _repository.switchProject(projectId);
    } catch (e) {
      print('SwitchProjectUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateProjectUseCase {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  Future<Project> call(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    try {
      return await _repository.updateProject(projectId, projectData);
    } catch (e) {
      print('UpdateProjectUseCase error: $e');
      rethrow;
    }
  }
}

class DeleteProjectUseCase {
  final ProjectRepository _repository;

  DeleteProjectUseCase(this._repository);

  Future<void> call(String projectId) async {
    try {
      return await _repository.deleteProject(projectId);
    } catch (e) {
      print('DeleteProjectUseCase error: $e');
      rethrow;
    }
  }
}
