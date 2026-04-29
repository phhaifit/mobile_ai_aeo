// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostDetailStore on _PostDetailStore, Store {
  Computed<bool>? _$hasPostComputed;

  @override
  bool get hasPost => (_$hasPostComputed ??=
          Computed<bool>(() => super.hasPost, name: '_PostDetailStore.hasPost'))
      .value;
  Computed<int>? _$wordCountComputed;

  @override
  int get wordCount =>
      (_$wordCountComputed ??= Computed<int>(() => super.wordCount,
              name: '_PostDetailStore.wordCount'))
          .value;
  Computed<String>? _$contentTypeLabelComputed;

  @override
  String get contentTypeLabel => (_$contentTypeLabelComputed ??=
          Computed<String>(() => super.contentTypeLabel,
              name: '_PostDetailStore.contentTypeLabel'))
      .value;
  Computed<bool>? _$isPublishedComputed;

  @override
  bool get isPublished =>
      (_$isPublishedComputed ??= Computed<bool>(() => super.isPublished,
              name: '_PostDetailStore.isPublished'))
          .value;
  Computed<String>? _$displayStatusComputed;

  @override
  String get displayStatus =>
      (_$displayStatusComputed ??= Computed<String>(() => super.displayStatus,
              name: '_PostDetailStore.displayStatus'))
          .value;
  Computed<String>? _$statusColorNameComputed;

  @override
  String get statusColorName => (_$statusColorNameComputed ??= Computed<String>(
          () => super.statusColorName,
          name: '_PostDetailStore.statusColorName'))
      .value;

  late final _$postDataAtom =
      Atom(name: '_PostDetailStore.postData', context: context);

  @override
  Map<String, dynamic>? get postData {
    _$postDataAtom.reportRead();
    return super.postData;
  }

  @override
  set postData(Map<String, dynamic>? value) {
    _$postDataAtom.reportWrite(value, super.postData, () {
      super.postData = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PostDetailStore.isLoading', context: context);

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

  late final _$isActionLoadingAtom =
      Atom(name: '_PostDetailStore.isActionLoading', context: context);

  @override
  bool get isActionLoading {
    _$isActionLoadingAtom.reportRead();
    return super.isActionLoading;
  }

  @override
  set isActionLoading(bool value) {
    _$isActionLoadingAtom.reportWrite(value, super.isActionLoading, () {
      super.isActionLoading = value;
    });
  }

  late final _$isEditingAtom =
      Atom(name: '_PostDetailStore.isEditing', context: context);

  @override
  bool get isEditing {
    _$isEditingAtom.reportRead();
    return super.isEditing;
  }

  @override
  set isEditing(bool value) {
    _$isEditingAtom.reportWrite(value, super.isEditing, () {
      super.isEditing = value;
    });
  }

  late final _$isContentProfileExpandedAtom =
      Atom(name: '_PostDetailStore.isContentProfileExpanded', context: context);

  @override
  bool get isContentProfileExpanded {
    _$isContentProfileExpandedAtom.reportRead();
    return super.isContentProfileExpanded;
  }

  @override
  set isContentProfileExpanded(bool value) {
    _$isContentProfileExpandedAtom
        .reportWrite(value, super.isContentProfileExpanded, () {
      super.isContentProfileExpanded = value;
    });
  }

  late final _$isTopicExpandedAtom =
      Atom(name: '_PostDetailStore.isTopicExpanded', context: context);

  @override
  bool get isTopicExpanded {
    _$isTopicExpandedAtom.reportRead();
    return super.isTopicExpanded;
  }

  @override
  set isTopicExpanded(bool value) {
    _$isTopicExpandedAtom.reportWrite(value, super.isTopicExpanded, () {
      super.isTopicExpanded = value;
    });
  }

  late final _$isPromptExpandedAtom =
      Atom(name: '_PostDetailStore.isPromptExpanded', context: context);

  @override
  bool get isPromptExpanded {
    _$isPromptExpandedAtom.reportRead();
    return super.isPromptExpanded;
  }

  @override
  set isPromptExpanded(bool value) {
    _$isPromptExpandedAtom.reportWrite(value, super.isPromptExpanded, () {
      super.isPromptExpanded = value;
    });
  }

  late final _$titleTextAtom =
      Atom(name: '_PostDetailStore.titleText', context: context);

  @override
  String get titleText {
    _$titleTextAtom.reportRead();
    return super.titleText;
  }

  @override
  set titleText(String value) {
    _$titleTextAtom.reportWrite(value, super.titleText, () {
      super.titleText = value;
    });
  }

  late final _$slugTextAtom =
      Atom(name: '_PostDetailStore.slugText', context: context);

  @override
  String get slugText {
    _$slugTextAtom.reportRead();
    return super.slugText;
  }

  @override
  set slugText(String value) {
    _$slugTextAtom.reportWrite(value, super.slugText, () {
      super.slugText = value;
    });
  }

  late final _$bodyTextAtom =
      Atom(name: '_PostDetailStore.bodyText', context: context);

  @override
  String get bodyText {
    _$bodyTextAtom.reportRead();
    return super.bodyText;
  }

  @override
  set bodyText(String value) {
    _$bodyTextAtom.reportWrite(value, super.bodyText, () {
      super.bodyText = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_PostDetailStore.errorMessage', context: context);

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

  late final _$loadPostDetailAsyncAction =
      AsyncAction('_PostDetailStore.loadPostDetail', context: context);

  @override
  Future<void> loadPostDetail(String id) {
    return _$loadPostDetailAsyncAction.run(() => super.loadPostDetail(id));
  }

  late final _$_PostDetailStoreActionController =
      ActionController(name: '_PostDetailStore', context: context);

  @override
  void toggleEditing() {
    final _$actionInfo = _$_PostDetailStoreActionController.startAction(
        name: '_PostDetailStore.toggleEditing');
    try {
      return super.toggleEditing();
    } finally {
      _$_PostDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setContentProfileExpanded(bool value) {
    final _$actionInfo = _$_PostDetailStoreActionController.startAction(
        name: '_PostDetailStore.setContentProfileExpanded');
    try {
      return super.setContentProfileExpanded(value);
    } finally {
      _$_PostDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTopicExpanded(bool value) {
    final _$actionInfo = _$_PostDetailStoreActionController.startAction(
        name: '_PostDetailStore.setTopicExpanded');
    try {
      return super.setTopicExpanded(value);
    } finally {
      _$_PostDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPromptExpanded(bool value) {
    final _$actionInfo = _$_PostDetailStoreActionController.startAction(
        name: '_PostDetailStore.setPromptExpanded');
    try {
      return super.setPromptExpanded(value);
    } finally {
      _$_PostDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setActionLoading(bool value) {
    final _$actionInfo = _$_PostDetailStoreActionController.startAction(
        name: '_PostDetailStore.setActionLoading');
    try {
      return super.setActionLoading(value);
    } finally {
      _$_PostDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
postData: ${postData},
isLoading: ${isLoading},
isActionLoading: ${isActionLoading},
isEditing: ${isEditing},
isContentProfileExpanded: ${isContentProfileExpanded},
isTopicExpanded: ${isTopicExpanded},
isPromptExpanded: ${isPromptExpanded},
titleText: ${titleText},
slugText: ${slugText},
bodyText: ${bodyText},
errorMessage: ${errorMessage},
hasPost: ${hasPost},
wordCount: ${wordCount},
contentTypeLabel: ${contentTypeLabel},
isPublished: ${isPublished},
displayStatus: ${displayStatus},
statusColorName: ${statusColorName}
    ''';
  }
}
