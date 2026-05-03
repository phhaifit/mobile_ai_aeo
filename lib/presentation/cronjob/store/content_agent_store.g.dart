// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_agent_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ContentAgentStore on _ContentAgentStore, Store {
  Computed<double>? _$successRateComputed;

  @override
  double get successRate =>
      (_$successRateComputed ??= Computed<double>(() => super.successRate,
              name: '_ContentAgentStore.successRate'))
          .value;
  Computed<int>? _$successCountComputed;

  @override
  int get successCount =>
      (_$successCountComputed ??= Computed<int>(() => super.successCount,
              name: '_ContentAgentStore.successCount'))
          .value;
  Computed<int>? _$failCountComputed;

  @override
  int get failCount =>
      (_$failCountComputed ??= Computed<int>(() => super.failCount,
              name: '_ContentAgentStore.failCount'))
          .value;
  Computed<int>? _$activeAgentCountComputed;

  @override
  int get activeAgentCount => (_$activeAgentCountComputed ??= Computed<int>(
          () => super.activeAgentCount,
          name: '_ContentAgentStore.activeAgentCount'))
      .value;

  late final _$agentsAtom =
      Atom(name: '_ContentAgentStore.agents', context: context);

  @override
  ObservableList<Map<String, dynamic>> get agents {
    _$agentsAtom.reportRead();
    return super.agents;
  }

  @override
  set agents(ObservableList<Map<String, dynamic>> value) {
    _$agentsAtom.reportWrite(value, super.agents, () {
      super.agents = value;
    });
  }

  late final _$statsAtom =
      Atom(name: '_ContentAgentStore.stats', context: context);

  @override
  Map<String, dynamic>? get stats {
    _$statsAtom.reportRead();
    return super.stats;
  }

  @override
  set stats(Map<String, dynamic>? value) {
    _$statsAtom.reportWrite(value, super.stats, () {
      super.stats = value;
    });
  }

  late final _$availableBlogPromptCountAtom = Atom(
      name: '_ContentAgentStore.availableBlogPromptCount', context: context);

  @override
  int get availableBlogPromptCount {
    _$availableBlogPromptCountAtom.reportRead();
    return super.availableBlogPromptCount;
  }

  @override
  set availableBlogPromptCount(int value) {
    _$availableBlogPromptCountAtom
        .reportWrite(value, super.availableBlogPromptCount, () {
      super.availableBlogPromptCount = value;
    });
  }

  late final _$isLoadingAgentsAtom =
      Atom(name: '_ContentAgentStore.isLoadingAgents', context: context);

  @override
  bool get isLoadingAgents {
    _$isLoadingAgentsAtom.reportRead();
    return super.isLoadingAgents;
  }

  @override
  set isLoadingAgents(bool value) {
    _$isLoadingAgentsAtom.reportWrite(value, super.isLoadingAgents, () {
      super.isLoadingAgents = value;
    });
  }

  late final _$agentsErrorAtom =
      Atom(name: '_ContentAgentStore.agentsError', context: context);

  @override
  String? get agentsError {
    _$agentsErrorAtom.reportRead();
    return super.agentsError;
  }

  @override
  set agentsError(String? value) {
    _$agentsErrorAtom.reportWrite(value, super.agentsError, () {
      super.agentsError = value;
    });
  }

  late final _$togglingAgentIdAtom =
      Atom(name: '_ContentAgentStore.togglingAgentId', context: context);

  @override
  String? get togglingAgentId {
    _$togglingAgentIdAtom.reportRead();
    return super.togglingAgentId;
  }

  @override
  set togglingAgentId(String? value) {
    _$togglingAgentIdAtom.reportWrite(value, super.togglingAgentId, () {
      super.togglingAgentId = value;
    });
  }

  late final _$contentProfilesAtom =
      Atom(name: '_ContentAgentStore.contentProfiles', context: context);

  @override
  ObservableList<Map<String, dynamic>> get contentProfiles {
    _$contentProfilesAtom.reportRead();
    return super.contentProfiles;
  }

  @override
  set contentProfiles(ObservableList<Map<String, dynamic>> value) {
    _$contentProfilesAtom.reportWrite(value, super.contentProfiles, () {
      super.contentProfiles = value;
    });
  }

  late final _$isLoadingProfilesAtom =
      Atom(name: '_ContentAgentStore.isLoadingProfiles', context: context);

  @override
  bool get isLoadingProfiles {
    _$isLoadingProfilesAtom.reportRead();
    return super.isLoadingProfiles;
  }

  @override
  set isLoadingProfiles(bool value) {
    _$isLoadingProfilesAtom.reportWrite(value, super.isLoadingProfiles, () {
      super.isLoadingProfiles = value;
    });
  }

  late final _$executionsAtom =
      Atom(name: '_ContentAgentStore.executions', context: context);

  @override
  ObservableList<Map<String, dynamic>> get executions {
    _$executionsAtom.reportRead();
    return super.executions;
  }

  @override
  set executions(ObservableList<Map<String, dynamic>> value) {
    _$executionsAtom.reportWrite(value, super.executions, () {
      super.executions = value;
    });
  }

  late final _$totalExecutionsAtom =
      Atom(name: '_ContentAgentStore.totalExecutions', context: context);

  @override
  int get totalExecutions {
    _$totalExecutionsAtom.reportRead();
    return super.totalExecutions;
  }

  @override
  set totalExecutions(int value) {
    _$totalExecutionsAtom.reportWrite(value, super.totalExecutions, () {
      super.totalExecutions = value;
    });
  }

  late final _$isLoadingExecutionsAtom =
      Atom(name: '_ContentAgentStore.isLoadingExecutions', context: context);

  @override
  bool get isLoadingExecutions {
    _$isLoadingExecutionsAtom.reportRead();
    return super.isLoadingExecutions;
  }

  @override
  set isLoadingExecutions(bool value) {
    _$isLoadingExecutionsAtom.reportWrite(value, super.isLoadingExecutions, () {
      super.isLoadingExecutions = value;
    });
  }

  late final _$executionsErrorAtom =
      Atom(name: '_ContentAgentStore.executionsError', context: context);

  @override
  String? get executionsError {
    _$executionsErrorAtom.reportRead();
    return super.executionsError;
  }

  @override
  set executionsError(String? value) {
    _$executionsErrorAtom.reportWrite(value, super.executionsError, () {
      super.executionsError = value;
    });
  }

  late final _$loadContentProfilesAsyncAction =
      AsyncAction('_ContentAgentStore.loadContentProfiles', context: context);

  @override
  Future<void> loadContentProfiles() {
    return _$loadContentProfilesAsyncAction
        .run(() => super.loadContentProfiles());
  }

  late final _$loadAgentsAsyncAction =
      AsyncAction('_ContentAgentStore.loadAgents', context: context);

  @override
  Future<void> loadAgents() {
    return _$loadAgentsAsyncAction.run(() => super.loadAgents());
  }

  late final _$loadExecutionsAsyncAction =
      AsyncAction('_ContentAgentStore.loadExecutions', context: context);

  @override
  Future<void> loadExecutions(String projectId,
      {int page = 1,
      int limit = 10,
      List<String>? statuses,
      List<String>? agentTypes,
      DateTime? startDate,
      DateTime? endDate}) {
    return _$loadExecutionsAsyncAction.run(() => super.loadExecutions(projectId,
        page: page,
        limit: limit,
        statuses: statuses,
        agentTypes: agentTypes,
        startDate: startDate,
        endDate: endDate));
  }

  late final _$configureAgentAsyncAction =
      AsyncAction('_ContentAgentStore.configureAgent', context: context);

  @override
  Future<bool> configureAgent(String agentId,
      {String? contentProfileId, int? postsPerDay}) {
    return _$configureAgentAsyncAction.run(() => super.configureAgent(agentId,
        contentProfileId: contentProfileId, postsPerDay: postsPerDay));
  }

  late final _$toggleAgentAsyncAction =
      AsyncAction('_ContentAgentStore.toggleAgent', context: context);

  @override
  Future<bool> toggleAgent(String agentId, bool isActive) {
    return _$toggleAgentAsyncAction
        .run(() => super.toggleAgent(agentId, isActive));
  }

  late final _$_ContentAgentStoreActionController =
      ActionController(name: '_ContentAgentStore', context: context);

  @override
  void clearAgentsError() {
    final _$actionInfo = _$_ContentAgentStoreActionController.startAction(
        name: '_ContentAgentStore.clearAgentsError');
    try {
      return super.clearAgentsError();
    } finally {
      _$_ContentAgentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearExecutionsError() {
    final _$actionInfo = _$_ContentAgentStoreActionController.startAction(
        name: '_ContentAgentStore.clearExecutionsError');
    try {
      return super.clearExecutionsError();
    } finally {
      _$_ContentAgentStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
agents: ${agents},
stats: ${stats},
availableBlogPromptCount: ${availableBlogPromptCount},
isLoadingAgents: ${isLoadingAgents},
agentsError: ${agentsError},
togglingAgentId: ${togglingAgentId},
contentProfiles: ${contentProfiles},
isLoadingProfiles: ${isLoadingProfiles},
executions: ${executions},
totalExecutions: ${totalExecutions},
isLoadingExecutions: ${isLoadingExecutions},
executionsError: ${executionsError},
successRate: ${successRate},
successCount: ${successCount},
failCount: ${failCount},
activeAgentCount: ${activeAgentCount}
    ''';
  }
}
