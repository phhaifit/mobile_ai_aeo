// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_library_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TemplateLibraryStore on _TemplateLibraryStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_TemplateLibraryStore.isLoading', context: context);

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

  late final _$inputUrlAtom =
      Atom(name: '_TemplateLibraryStore.inputUrl', context: context);

  @override
  String get inputUrl {
    _$inputUrlAtom.reportRead();
    return super.inputUrl;
  }

  @override
  set inputUrl(String value) {
    _$inputUrlAtom.reportWrite(value, super.inputUrl, () {
      super.inputUrl = value;
    });
  }

  late final _$contentProfilesAtom =
      Atom(name: '_TemplateLibraryStore.contentProfiles', context: context);

  @override
  List<ContentProfile> get contentProfiles {
    _$contentProfilesAtom.reportRead();
    return super.contentProfiles;
  }

  @override
  set contentProfiles(List<ContentProfile> value) {
    _$contentProfilesAtom.reportWrite(value, super.contentProfiles, () {
      super.contentProfiles = value;
    });
  }

  late final _$analysisResultAtom =
      Atom(name: '_TemplateLibraryStore.analysisResult', context: context);

  @override
  WebsiteAnalysisResult? get analysisResult {
    _$analysisResultAtom.reportRead();
    return super.analysisResult;
  }

  @override
  set analysisResult(WebsiteAnalysisResult? value) {
    _$analysisResultAtom.reportWrite(value, super.analysisResult, () {
      super.analysisResult = value;
    });
  }

  late final _$isAnalyzingAtom =
      Atom(name: '_TemplateLibraryStore.isAnalyzing', context: context);

  @override
  bool get isAnalyzing {
    _$isAnalyzingAtom.reportRead();
    return super.isAnalyzing;
  }

  @override
  set isAnalyzing(bool value) {
    _$isAnalyzingAtom.reportWrite(value, super.isAnalyzing, () {
      super.isAnalyzing = value;
    });
  }

  late final _$selectedContentProfileAtom = Atom(
      name: '_TemplateLibraryStore.selectedContentProfile', context: context);

  @override
  ContentProfile? get selectedContentProfile {
    _$selectedContentProfileAtom.reportRead();
    return super.selectedContentProfile;
  }

  @override
  set selectedContentProfile(ContentProfile? value) {
    _$selectedContentProfileAtom
        .reportWrite(value, super.selectedContentProfile, () {
      super.selectedContentProfile = value;
    });
  }

  late final _$isSavingProfileAtom =
      Atom(name: '_TemplateLibraryStore.isSavingProfile', context: context);

  @override
  bool get isSavingProfile {
    _$isSavingProfileAtom.reportRead();
    return super.isSavingProfile;
  }

  @override
  set isSavingProfile(bool value) {
    _$isSavingProfileAtom.reportWrite(value, super.isSavingProfile, () {
      super.isSavingProfile = value;
    });
  }

  late final _$isDeletingProfileAtom =
      Atom(name: '_TemplateLibraryStore.isDeletingProfile', context: context);

  @override
  bool get isDeletingProfile {
    _$isDeletingProfileAtom.reportRead();
    return super.isDeletingProfile;
  }

  @override
  set isDeletingProfile(bool value) {
    _$isDeletingProfileAtom.reportWrite(value, super.isDeletingProfile, () {
      super.isDeletingProfile = value;
    });
  }

  late final _$fetchIndustryTemplatesAsyncAction = AsyncAction(
      '_TemplateLibraryStore.fetchIndustryTemplates',
      context: context);

  @override
  Future<void> fetchIndustryTemplates({String? projectId}) {
    return _$fetchIndustryTemplatesAsyncAction
        .run(() => super.fetchIndustryTemplates(projectId: projectId));
  }

  late final _$generateFromWebsiteAsyncAction = AsyncAction(
      '_TemplateLibraryStore.generateFromWebsite',
      context: context);

  @override
  Future<void> generateFromWebsite(String url) {
    return _$generateFromWebsiteAsyncAction
        .run(() => super.generateFromWebsite(url));
  }

  late final _$createContentProfileAsyncAction = AsyncAction(
      '_TemplateLibraryStore.createContentProfile',
      context: context);

  @override
  Future<void> createContentProfile(
      {required String projectId,
      required String name,
      required String description,
      required String voiceAndTone,
      required String audience}) {
    return _$createContentProfileAsyncAction.run(() => super
        .createContentProfile(
            projectId: projectId,
            name: name,
            description: description,
            voiceAndTone: voiceAndTone,
            audience: audience));
  }

  late final _$updateContentProfileAsyncAction = AsyncAction(
      '_TemplateLibraryStore.updateContentProfile',
      context: context);

  @override
  Future<void> updateContentProfile(
      {required String projectId,
      required String contentProfileId,
      required String name,
      required String description,
      required String voiceAndTone,
      required String audience}) {
    return _$updateContentProfileAsyncAction.run(() => super
        .updateContentProfile(
            projectId: projectId,
            contentProfileId: contentProfileId,
            name: name,
            description: description,
            voiceAndTone: voiceAndTone,
            audience: audience));
  }

  late final _$deleteContentProfileAsyncAction = AsyncAction(
      '_TemplateLibraryStore.deleteContentProfile',
      context: context);

  @override
  Future<void> deleteContentProfile(
      {required String projectId, required String contentProfileId}) {
    return _$deleteContentProfileAsyncAction.run(() => super
        .deleteContentProfile(
            projectId: projectId, contentProfileId: contentProfileId));
  }

  late final _$_TemplateLibraryStoreActionController =
      ActionController(name: '_TemplateLibraryStore', context: context);

  @override
  void selectContentProfile(ContentProfile profile) {
    final _$actionInfo = _$_TemplateLibraryStoreActionController.startAction(
        name: '_TemplateLibraryStore.selectContentProfile');
    try {
      return super.selectContentProfile(profile);
    } finally {
      _$_TemplateLibraryStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAnalysisResult() {
    final _$actionInfo = _$_TemplateLibraryStoreActionController.startAction(
        name: '_TemplateLibraryStore.clearAnalysisResult');
    try {
      return super.clearAnalysisResult();
    } finally {
      _$_TemplateLibraryStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_TemplateLibraryStoreActionController.startAction(
        name: '_TemplateLibraryStore.dispose');
    try {
      return super.dispose();
    } finally {
      _$_TemplateLibraryStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
inputUrl: ${inputUrl},
contentProfiles: ${contentProfiles},
analysisResult: ${analysisResult},
isAnalyzing: ${isAnalyzing},
selectedContentProfile: ${selectedContentProfile},
isSavingProfile: ${isSavingProfile},
isDeletingProfile: ${isDeletingProfile}
    ''';
  }
}
