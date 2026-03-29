// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_setup_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BrandSetupStore on _BrandSetupStore, Store {
  Computed<int>? _$enabledLlmCountComputed;

  @override
  int get enabledLlmCount =>
      (_$enabledLlmCountComputed ??= Computed<int>(() => super.enabledLlmCount,
              name: '_BrandSetupStore.enabledLlmCount'))
          .value;
  Computed<int>? _$activeRulesComputed;

  @override
  int get activeRules =>
      (_$activeRulesComputed ??= Computed<int>(() => super.activeRules,
              name: '_BrandSetupStore.activeRules'))
          .value;

  late final _$profileAtom =
      Atom(name: '_BrandSetupStore.profile', context: context);

  @override
  BrandProfile? get profile {
    _$profileAtom.reportRead();
    return super.profile;
  }

  @override
  set profile(BrandProfile? value) {
    _$profileAtom.reportWrite(value, super.profile, () {
      super.profile = value;
    });
  }

  late final _$knowledgeBaseAtom =
      Atom(name: '_BrandSetupStore.knowledgeBase', context: context);

  @override
  ObservableList<KnowledgeBaseEntry> get knowledgeBase {
    _$knowledgeBaseAtom.reportRead();
    return super.knowledgeBase;
  }

  @override
  set knowledgeBase(ObservableList<KnowledgeBaseEntry> value) {
    _$knowledgeBaseAtom.reportWrite(value, super.knowledgeBase, () {
      super.knowledgeBase = value;
    });
  }

  late final _$linksAtom =
      Atom(name: '_BrandSetupStore.links', context: context);

  @override
  ObservableList<LinkItem> get links {
    _$linksAtom.reportRead();
    return super.links;
  }

  @override
  set links(ObservableList<LinkItem> value) {
    _$linksAtom.reportWrite(value, super.links, () {
      super.links = value;
    });
  }

  late final _$rewriteRulesAtom =
      Atom(name: '_BrandSetupStore.rewriteRules', context: context);

  @override
  ObservableList<RewriteRule> get rewriteRules {
    _$rewriteRulesAtom.reportRead();
    return super.rewriteRules;
  }

  @override
  set rewriteRules(ObservableList<RewriteRule> value) {
    _$rewriteRulesAtom.reportWrite(value, super.rewriteRules, () {
      super.rewriteRules = value;
    });
  }

  late final _$llmConfigsAtom =
      Atom(name: '_BrandSetupStore.llmConfigs', context: context);

  @override
  ObservableList<LlmConfig> get llmConfigs {
    _$llmConfigsAtom.reportRead();
    return super.llmConfigs;
  }

  @override
  set llmConfigs(ObservableList<LlmConfig> value) {
    _$llmConfigsAtom.reportWrite(value, super.llmConfigs, () {
      super.llmConfigs = value;
    });
  }

  late final _$projectsAtom =
      Atom(name: '_BrandSetupStore.projects', context: context);

  @override
  ObservableList<ProjectCardModel> get projects {
    _$projectsAtom.reportRead();
    return super.projects;
  }

  @override
  set projects(ObservableList<ProjectCardModel> value) {
    _$projectsAtom.reportWrite(value, super.projects, () {
      super.projects = value;
    });
  }

  late final _$defaultPollingMinutesAtom =
      Atom(name: '_BrandSetupStore.defaultPollingMinutes', context: context);

  @override
  int get defaultPollingMinutes {
    _$defaultPollingMinutesAtom.reportRead();
    return super.defaultPollingMinutes;
  }

  @override
  set defaultPollingMinutes(int value) {
    _$defaultPollingMinutesAtom.reportWrite(value, super.defaultPollingMinutes,
        () {
      super.defaultPollingMinutes = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_BrandSetupStore.isLoading', context: context);

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

  late final _$loadMockDataAsyncAction =
      AsyncAction('_BrandSetupStore.loadMockData', context: context);

  @override
  Future<void> loadMockData() {
    return _$loadMockDataAsyncAction.run(() => super.loadMockData());
  }

  @override
  String toString() {
    return '''
profile: ${profile},
knowledgeBase: ${knowledgeBase},
links: ${links},
rewriteRules: ${rewriteRules},
llmConfigs: ${llmConfigs},
projects: ${projects},
defaultPollingMinutes: ${defaultPollingMinutes},
isLoading: ${isLoading},
enabledLlmCount: ${enabledLlmCount},
activeRules: ${activeRules}
    ''';
  }
}
