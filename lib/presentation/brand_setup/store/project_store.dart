import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/project.dart';
import 'package:boilerplate/domain/usecase/brand_setup/project_usecase.dart';

part 'project_store.g.dart';

class ProjectStore = _ProjectStore with _$ProjectStore;

abstract class _ProjectStore with Store {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectUseCase _getProjectUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final SwitchProjectUseCase _switchProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  _ProjectStore(
    this._getProjectsUseCase,
    this._getProjectUseCase,
    this._createProjectUseCase,
    this._switchProjectUseCase,
    this._updateProjectUseCase,
    this._deleteProjectUseCase,
  );

  @observable
  ObservableList<Project> projects = ObservableList<Project>();

  @observable
  Project? currentProject;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isProcessing = false;

  @action
  Future<void> getProjects() async {
    try {
      isLoading = true;
      errorMessage = null;
      final result = await _getProjectsUseCase();
      projects = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      print('ProjectStore.getProjects error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> createProject(Map<String, dynamic> projectData) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final newProject = await _createProjectUseCase(projectData);
      projects.add(newProject);
      currentProject = newProject;
    } catch (e) {
      errorMessage = e.toString();
      print('ProjectStore.createProject error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> switchProject(String projectId) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final project = await _switchProjectUseCase(projectId);
      currentProject = project;
    } catch (e) {
      errorMessage = e.toString();
      print('ProjectStore.switchProject error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> projectData,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final updatedProject =
          await _updateProjectUseCase(projectId, projectData);
      final index = projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        projects[index] = updatedProject;
      }
      if (currentProject?.id == projectId) {
        currentProject = updatedProject;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('ProjectStore.updateProject error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  Future<void> deleteProject(String projectId) async {
    try {
      isProcessing = true;
      errorMessage = null;
      await _deleteProjectUseCase(projectId);
      projects.removeWhere((p) => p.id == projectId);
      if (currentProject?.id == projectId) {
        currentProject = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('ProjectStore.deleteProject error: $e');
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
    projects.clear();
    currentProject = null;
    isLoading = false;
    errorMessage = null;
    isProcessing = false;
  }
}
