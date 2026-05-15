// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectStore on _ProjectStore, Store {
  late final _$projectsAtom =
      Atom(name: '_ProjectStore.projects', context: context);

  @override
  ObservableList<Project> get projects {
    _$projectsAtom.reportRead();
    return super.projects;
  }

  @override
  set projects(ObservableList<Project> value) {
    _$projectsAtom.reportWrite(value, super.projects, () {
      super.projects = value;
    });
  }

  late final _$currentProjectAtom =
      Atom(name: '_ProjectStore.currentProject', context: context);

  @override
  Project? get currentProject {
    _$currentProjectAtom.reportRead();
    return super.currentProject;
  }

  @override
  set currentProject(Project? value) {
    _$currentProjectAtom.reportWrite(value, super.currentProject, () {
      super.currentProject = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProjectStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ProjectStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isProcessingAtom =
      Atom(name: '_ProjectStore.isProcessing', context: context);

  @override
  bool get isProcessing {
    _$isProcessingAtom.reportRead();
    return super.isProcessing;
  }

  @override
  set isProcessing(bool value) {
    _$isProcessingAtom.reportWrite(value, super.isProcessing, () {
      super.isProcessing = value;
    });
  }

  late final _$getProjectsAsyncAction =
      AsyncAction('_ProjectStore.getProjects', context: context);

  @override
  Future<void> getProjects() {
    return _$getProjectsAsyncAction.run(() => super.getProjects());
  }

  late final _$createProjectAsyncAction =
      AsyncAction('_ProjectStore.createProject', context: context);

  @override
  Future<void> createProject(Map<String, dynamic> projectData) {
    return _$createProjectAsyncAction
        .run(() => super.createProject(projectData));
  }

  late final _$switchProjectAsyncAction =
      AsyncAction('_ProjectStore.switchProject', context: context);

  @override
  Future<void> switchProject(String projectId) {
    return _$switchProjectAsyncAction.run(() => super.switchProject(projectId));
  }

  late final _$updateProjectAsyncAction =
      AsyncAction('_ProjectStore.updateProject', context: context);

  @override
  Future<void> updateProject(
      String projectId, Map<String, dynamic> projectData) {
    return _$updateProjectAsyncAction
        .run(() => super.updateProject(projectId, projectData));
  }

  late final _$deleteProjectAsyncAction =
      AsyncAction('_ProjectStore.deleteProject', context: context);

  @override
  Future<void> deleteProject(String projectId) {
    return _$deleteProjectAsyncAction.run(() => super.deleteProject(projectId));
  }

  late final _$_ProjectStoreActionController =
      ActionController(name: '_ProjectStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_ProjectStoreActionController.startAction(
        name: '_ProjectStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_ProjectStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_ProjectStoreActionController.startAction(
        name: '_ProjectStore.reset');
    try {
      return super.reset();
    } finally {
      _$_ProjectStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
projects: ${projects},
currentProject: ${currentProject},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isProcessing: ${isProcessing}
    ''';
  }
}
