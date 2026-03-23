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

  late final _$industryTemplatesAtom =
      Atom(name: '_TemplateLibraryStore.industryTemplates', context: context);

  @override
  List<WritingStyleModel> get industryTemplates {
    _$industryTemplatesAtom.reportRead();
    return super.industryTemplates;
  }

  @override
  set industryTemplates(List<WritingStyleModel> value) {
    _$industryTemplatesAtom.reportWrite(value, super.industryTemplates, () {
      super.industryTemplates = value;
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

  late final _$selectedTemplateAtom =
      Atom(name: '_TemplateLibraryStore.selectedTemplate', context: context);

  @override
  WritingStyleModel? get selectedTemplate {
    _$selectedTemplateAtom.reportRead();
    return super.selectedTemplate;
  }

  @override
  set selectedTemplate(WritingStyleModel? value) {
    _$selectedTemplateAtom.reportWrite(value, super.selectedTemplate, () {
      super.selectedTemplate = value;
    });
  }

  late final _$fetchIndustryTemplatesAsyncAction = AsyncAction(
      '_TemplateLibraryStore.fetchIndustryTemplates',
      context: context);

  @override
  Future<void> fetchIndustryTemplates() {
    return _$fetchIndustryTemplatesAsyncAction
        .run(() => super.fetchIndustryTemplates());
  }

  late final _$generateFromWebsiteAsyncAction = AsyncAction(
      '_TemplateLibraryStore.generateFromWebsite',
      context: context);

  @override
  Future<void> generateFromWebsite(String url) {
    return _$generateFromWebsiteAsyncAction
        .run(() => super.generateFromWebsite(url));
  }

  late final _$_TemplateLibraryStoreActionController =
      ActionController(name: '_TemplateLibraryStore', context: context);

  @override
  void selectTemplate(WritingStyleModel template) {
    final _$actionInfo = _$_TemplateLibraryStoreActionController.startAction(
        name: '_TemplateLibraryStore.selectTemplate');
    try {
      return super.selectTemplate(template);
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
industryTemplates: ${industryTemplates},
analysisResult: ${analysisResult},
isAnalyzing: ${isAnalyzing},
selectedTemplate: ${selectedTemplate}
    ''';
  }
}
