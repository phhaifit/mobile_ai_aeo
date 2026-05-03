// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_posts_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AllPostsStore on _AllPostsStore, Store {
  Computed<List<PostItem>>? _$visiblePostsComputed;

  @override
  List<PostItem> get visiblePosts => (_$visiblePostsComputed ??=
          Computed<List<PostItem>>(() => super.visiblePosts,
              name: '_AllPostsStore.visiblePosts'))
      .value;
  Computed<bool>? _$hasSelectionComputed;

  @override
  bool get hasSelection =>
      (_$hasSelectionComputed ??= Computed<bool>(() => super.hasSelection,
              name: '_AllPostsStore.hasSelection'))
          .value;
  Computed<bool>? _$isAllVisibleSelectedComputed;

  @override
  bool get isAllVisibleSelected => (_$isAllVisibleSelectedComputed ??=
          Computed<bool>(() => super.isAllVisibleSelected,
              name: '_AllPostsStore.isAllVisibleSelected'))
      .value;
  Computed<int>? _$totalPagesComputed;

  @override
  int get totalPages =>
      (_$totalPagesComputed ??= Computed<int>(() => super.totalPages,
              name: '_AllPostsStore.totalPages'))
          .value;

  late final _$loadingAtom =
      Atom(name: '_AllPostsStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$postsAtom = Atom(name: '_AllPostsStore.posts', context: context);

  @override
  ObservableList<PostItem> get posts {
    _$postsAtom.reportRead();
    return super.posts;
  }

  @override
  set posts(ObservableList<PostItem> value) {
    _$postsAtom.reportWrite(value, super.posts, () {
      super.posts = value;
    });
  }

  late final _$selectedItemIdsAtom =
      Atom(name: '_AllPostsStore.selectedItemIds', context: context);

  @override
  ObservableSet<String> get selectedItemIds {
    _$selectedItemIdsAtom.reportRead();
    return super.selectedItemIds;
  }

  @override
  set selectedItemIds(ObservableSet<String> value) {
    _$selectedItemIdsAtom.reportWrite(value, super.selectedItemIds, () {
      super.selectedItemIds = value;
    });
  }

  late final _$totalItemsAtom =
      Atom(name: '_AllPostsStore.totalItems', context: context);

  @override
  int get totalItems {
    _$totalItemsAtom.reportRead();
    return super.totalItems;
  }

  @override
  set totalItems(int value) {
    _$totalItemsAtom.reportWrite(value, super.totalItems, () {
      super.totalItems = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_AllPostsStore.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_AllPostsStore.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$selectedStatusAtom =
      Atom(name: '_AllPostsStore.selectedStatus', context: context);

  @override
  String get selectedStatus {
    _$selectedStatusAtom.reportRead();
    return super.selectedStatus;
  }

  @override
  set selectedStatus(String value) {
    _$selectedStatusAtom.reportWrite(value, super.selectedStatus, () {
      super.selectedStatus = value;
    });
  }

  late final _$selectedContentTypeAtom =
      Atom(name: '_AllPostsStore.selectedContentType', context: context);

  @override
  String get selectedContentType {
    _$selectedContentTypeAtom.reportRead();
    return super.selectedContentType;
  }

  @override
  set selectedContentType(String value) {
    _$selectedContentTypeAtom.reportWrite(value, super.selectedContentType, () {
      super.selectedContentType = value;
    });
  }

  late final _$selectedTopicAtom =
      Atom(name: '_AllPostsStore.selectedTopic', context: context);

  @override
  String get selectedTopic {
    _$selectedTopicAtom.reportRead();
    return super.selectedTopic;
  }

  @override
  set selectedTopic(String value) {
    _$selectedTopicAtom.reportWrite(value, super.selectedTopic, () {
      super.selectedTopic = value;
    });
  }

  late final _$startDateAtom =
      Atom(name: '_AllPostsStore.startDate', context: context);

  @override
  DateTime? get startDate {
    _$startDateAtom.reportRead();
    return super.startDate;
  }

  @override
  set startDate(DateTime? value) {
    _$startDateAtom.reportWrite(value, super.startDate, () {
      super.startDate = value;
    });
  }

  late final _$endDateAtom =
      Atom(name: '_AllPostsStore.endDate', context: context);

  @override
  DateTime? get endDate {
    _$endDateAtom.reportRead();
    return super.endDate;
  }

  @override
  set endDate(DateTime? value) {
    _$endDateAtom.reportWrite(value, super.endDate, () {
      super.endDate = value;
    });
  }

  late final _$selectedFilterAtom =
      Atom(name: '_AllPostsStore.selectedFilter', context: context);

  @override
  String get selectedFilter {
    _$selectedFilterAtom.reportRead();
    return super.selectedFilter;
  }

  @override
  set selectedFilter(String value) {
    _$selectedFilterAtom.reportWrite(value, super.selectedFilter, () {
      super.selectedFilter = value;
    });
  }

  late final _$projectIdAtom =
      Atom(name: '_AllPostsStore.projectId', context: context);

  @override
  String get projectId {
    _$projectIdAtom.reportRead();
    return super.projectId;
  }

  @override
  set projectId(String value) {
    _$projectIdAtom.reportWrite(value, super.projectId, () {
      super.projectId = value;
    });
  }

  late final _$itemsPerPageAtom =
      Atom(name: '_AllPostsStore.itemsPerPage', context: context);

  @override
  int get itemsPerPage {
    _$itemsPerPageAtom.reportRead();
    return super.itemsPerPage;
  }

  @override
  set itemsPerPage(int value) {
    _$itemsPerPageAtom.reportWrite(value, super.itemsPerPage, () {
      super.itemsPerPage = value;
    });
  }

  late final _$setItemsPerPageAsyncAction =
      AsyncAction('_AllPostsStore.setItemsPerPage', context: context);

  @override
  Future<void> setItemsPerPage(int value) {
    return _$setItemsPerPageAsyncAction.run(() => super.setItemsPerPage(value));
  }

  late final _$changePageAsyncAction =
      AsyncAction('_AllPostsStore.changePage', context: context);

  @override
  Future<void> changePage(int value) {
    return _$changePageAsyncAction.run(() => super.changePage(value));
  }

  late final _$applySearchAsyncAction =
      AsyncAction('_AllPostsStore.applySearch', context: context);

  @override
  Future<void> applySearch([String? value]) {
    return _$applySearchAsyncAction.run(() => super.applySearch(value));
  }

  late final _$applyFiltersAsyncAction =
      AsyncAction('_AllPostsStore.applyFilters', context: context);

  @override
  Future<void> applyFilters() {
    return _$applyFiltersAsyncAction.run(() => super.applyFilters());
  }

  late final _$loadPostsAsyncAction =
      AsyncAction('_AllPostsStore.loadPosts', context: context);

  @override
  Future<void> loadPosts() {
    return _$loadPostsAsyncAction.run(() => super.loadPosts());
  }

  late final _$deleteSelectedPostsAsyncAction =
      AsyncAction('_AllPostsStore.deleteSelectedPosts', context: context);

  @override
  Future<bool> deleteSelectedPosts() {
    return _$deleteSelectedPostsAsyncAction
        .run(() => super.deleteSelectedPosts());
  }

  late final _$_AllPostsStoreActionController =
      ActionController(name: '_AllPostsStore', context: context);

  @override
  void setSearchQuery(String value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setSearchQuery');
    try {
      return super.setSearchQuery(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSearch() {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.clearSearch');
    try {
      return super.clearSearch();
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedFilter(String value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setSelectedFilter');
    try {
      return super.setSelectedFilter(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedStatus(String value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setSelectedStatus');
    try {
      return super.setSelectedStatus(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedContentType(String value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setSelectedContentType');
    try {
      return super.setSelectedContentType(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedTopic(String value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setSelectedTopic');
    try {
      return super.setSelectedTopic(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStartDate(DateTime? value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setStartDate');
    try {
      return super.setStartDate(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEndDate(DateTime? value) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.setEndDate');
    try {
      return super.setEndDate(value);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearFilters() {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.clearFilters');
    try {
      return super.clearFilters();
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSelection(PostItem post) {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.toggleSelection');
    try {
      return super.toggleSelection(post);
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSelectAll() {
    final _$actionInfo = _$_AllPostsStoreActionController.startAction(
        name: '_AllPostsStore.toggleSelectAll');
    try {
      return super.toggleSelectAll();
    } finally {
      _$_AllPostsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
posts: ${posts},
selectedItemIds: ${selectedItemIds},
totalItems: ${totalItems},
currentPage: ${currentPage},
searchQuery: ${searchQuery},
selectedStatus: ${selectedStatus},
selectedContentType: ${selectedContentType},
selectedTopic: ${selectedTopic},
startDate: ${startDate},
endDate: ${endDate},
selectedFilter: ${selectedFilter},
projectId: ${projectId},
itemsPerPage: ${itemsPerPage},
visiblePosts: ${visiblePosts},
hasSelection: ${hasSelection},
isAllVisibleSelected: ${isAllVisibleSelected},
totalPages: ${totalPages}
    ''';
  }
}
