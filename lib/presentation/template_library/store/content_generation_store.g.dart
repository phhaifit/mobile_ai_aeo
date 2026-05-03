// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_generation_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ContentGenerationStore on _ContentGenerationStore, Store {
  late final _$isLoadingListsAtom =
      Atom(name: '_ContentGenerationStore.isLoadingLists', context: context);

  @override
  bool get isLoadingLists {
    _$isLoadingListsAtom.reportRead();
    return super.isLoadingLists;
  }

  @override
  set isLoadingLists(bool value) {
    _$isLoadingListsAtom.reportWrite(value, super.isLoadingLists, () {
      super.isLoadingLists = value;
    });
  }

  late final _$isGeneratingAtom =
      Atom(name: '_ContentGenerationStore.isGenerating', context: context);

  @override
  bool get isGenerating {
    _$isGeneratingAtom.reportRead();
    return super.isGenerating;
  }

  @override
  set isGenerating(bool value) {
    _$isGeneratingAtom.reportWrite(value, super.isGenerating, () {
      super.isGenerating = value;
    });
  }

  late final _$contentProfilesAtom =
      Atom(name: '_ContentGenerationStore.contentProfiles', context: context);

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

  late final _$promptsAtom =
      Atom(name: '_ContentGenerationStore.prompts', context: context);

  @override
  List<PromptSummary> get prompts {
    _$promptsAtom.reportRead();
    return super.prompts;
  }

  @override
  set prompts(List<PromptSummary> value) {
    _$promptsAtom.reportWrite(value, super.prompts, () {
      super.prompts = value;
    });
  }

  late final _$lastResultAtom =
      Atom(name: '_ContentGenerationStore.lastResult', context: context);

  @override
  ContentGenerationResult? get lastResult {
    _$lastResultAtom.reportRead();
    return super.lastResult;
  }

  @override
  set lastResult(ContentGenerationResult? value) {
    _$lastResultAtom.reportWrite(value, super.lastResult, () {
      super.lastResult = value;
    });
  }

  late final _$loadListsAsyncAction =
      AsyncAction('_ContentGenerationStore.loadLists', context: context);

  @override
  Future<void> loadLists() {
    return _$loadListsAsyncAction.run(() => super.loadLists());
  }

  late final _$generateContentAsyncAction =
      AsyncAction('_ContentGenerationStore.generateContent', context: context);

  @override
  Future<ContentGenerationResult?> generateContent(
      {required String promptId,
      required String contentProfileId,
      required String contentType,
      required List<String> keywords,
      required String referencePageUrl,
      required String platform,
      required String improvement,
      required String referenceType,
      String? customerPersonaId}) {
    return _$generateContentAsyncAction.run(() => super.generateContent(
        promptId: promptId,
        contentProfileId: contentProfileId,
        contentType: contentType,
        keywords: keywords,
        referencePageUrl: referencePageUrl,
        platform: platform,
        improvement: improvement,
        referenceType: referenceType,
        customerPersonaId: customerPersonaId));
  }

  late final _$_ContentGenerationStoreActionController =
      ActionController(name: '_ContentGenerationStore', context: context);

  @override
  void clearLastResult() {
    final _$actionInfo = _$_ContentGenerationStoreActionController.startAction(
        name: '_ContentGenerationStore.clearLastResult');
    try {
      return super.clearLastResult();
    } finally {
      _$_ContentGenerationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoadingLists: ${isLoadingLists},
isGenerating: ${isGenerating},
contentProfiles: ${contentProfiles},
prompts: ${prompts},
lastResult: ${lastResult}
    ''';
  }
}
