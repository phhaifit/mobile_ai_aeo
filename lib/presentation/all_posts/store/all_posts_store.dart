import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/network/apis/content_management/content_management_api.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'all_posts_store.g.dart';

class PostItem {
  final String id;
  final String contentId;
  final String projectId;
  final String title;
  final String description;
  final String date;
  final String? publishedDate;
  final String? imageUrl;
  final List<String> tags;
  final String type;

  const PostItem({
    required this.id,
    required this.contentId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.date,
    this.publishedDate,
    this.imageUrl,
    required this.tags,
    required this.type,
  });
}

class AllPostsStore = _AllPostsStore with _$AllPostsStore;

abstract class _AllPostsStore with Store {
  _AllPostsStore(this._contentApi, this.errorStore);

  final ContentManagementApi _contentApi;
  final ErrorStore errorStore;

  @observable
  bool loading = false;

  @observable
  ObservableList<PostItem> posts = ObservableList<PostItem>();

  @observable
  ObservableSet<String> selectedItemIds = ObservableSet<String>();

  @observable
  int totalItems = 0;

  @observable
  int currentPage = 1;

  @observable
  String searchQuery = '';

  @observable
  String selectedStatus = '';

  @observable
  String selectedContentType = '';

  @observable
  String selectedTopic = '';

  @observable
  DateTime? startDate;

  @observable
  DateTime? endDate;

  @observable
  String selectedFilter = 'All Content';

  @observable
  String projectId = 'ca6a7019-5e93-431f-b2d8-8deabc82a8af';

  final List<int> itemsPerPageOptions = [10, 25, 50, 100];

  @observable
  int itemsPerPage = 10;

  @computed
  List<PostItem> get visiblePosts {
    final filteredPosts = selectedFilter == 'All Content'
        ? posts.toList()
        : posts
            .where(
              (post) => post.type.toUpperCase() == selectedFilter.toUpperCase(),
            )
            .toList();

    return filteredPosts.take(itemsPerPage).toList();
  }

  @computed
  bool get hasSelection => selectedItemIds.isNotEmpty;

  @computed
  bool get isAllVisibleSelected =>
      visiblePosts.isNotEmpty &&
      visiblePosts.every((post) => selectedItemIds.contains(post.id));

  @computed
  int get totalPages {
    final pages = (totalItems / itemsPerPage).ceil();
    return pages == 0 ? 1 : pages;
  }

  @action
  void setSearchQuery(String value) {
    searchQuery = value;
  }

  @action
  void clearSearch() {
    searchQuery = '';
  }

  @action
  void setSelectedFilter(String value) {
    selectedFilter = value;
  }

  @action
  void setSelectedStatus(String value) {
    selectedStatus = value;
  }

  @action
  void setSelectedContentType(String value) {
    selectedContentType = value;
  }

  @action
  void setSelectedTopic(String value) {
    selectedTopic = value;
  }

  @action
  void setStartDate(DateTime? value) {
    startDate = value;
  }

  @action
  void setEndDate(DateTime? value) {
    endDate = value;
  }

  @action
  void clearFilters() {
    selectedStatus = '';
    selectedContentType = '';
    selectedTopic = '';
    startDate = null;
    endDate = null;
  }

  @action
  Future<void> setItemsPerPage(int value) async {
    itemsPerPage = value;
    currentPage = 1;
    await loadPosts();
  }

  @action
  Future<void> changePage(int value) async {
    currentPage = value;
    await loadPosts();
  }

  @action
  void toggleSelection(PostItem post) {
    if (selectedItemIds.contains(post.id)) {
      selectedItemIds.remove(post.id);
    } else {
      selectedItemIds.add(post.id);
    }
  }

  @action
  void toggleSelectAll() {
    if (isAllVisibleSelected) {
      for (final post in visiblePosts) {
        selectedItemIds.remove(post.id);
      }
      return;
    }

    selectedItemIds.addAll(visiblePosts.map((post) => post.id));
  }

  @action
  Future<void> applySearch([String? value]) async {
    if (value != null) {
      searchQuery = value;
    }
    currentPage = 1;
    await loadPosts();
  }

  @action
  Future<void> applyFilters() async {
    currentPage = 1;
    await loadPosts();
  }

  @action
  Future<void> loadPosts() async {
    loading = true;
    errorStore.errorMessage = '';

    try {
      try {
        final projData = await _contentApi.getProjects();
        if (projData.isNotEmpty) {
          projectId = projData.first['id'].toString();
        }
      } catch (e) {
        debugPrint('Could not fetch projects dynamically: $e');
      }

      final queryParams = <String, String>{
        'page': currentPage.toString(),
        'limit': itemsPerPage.toString(),
      };

      if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
      if (selectedStatus.isNotEmpty) {
        queryParams['status'] =
            selectedStatus == 'UNPUBLISHED' ? 'COMPLETE' : selectedStatus;
      }
      if (selectedContentType.isNotEmpty) {
        queryParams['contentType'] = selectedContentType;
      }
      if (selectedTopic.isNotEmpty) queryParams['topicName'] = selectedTopic;
      if (startDate != null) {
        queryParams['startDate'] = startDate!.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate!.toIso8601String();
      }

      final bodyDecoded = await _contentApi.listProjectContents(
        projectId,
        queryParameters: queryParams,
      );

      final List<dynamic> data = bodyDecoded['data'] ?? [];
      final Map<String, dynamic>? meta = bodyDecoded['meta'];
      totalItems = meta != null && meta['total'] != null
          ? meta['total'] as int
          : data.length;

      posts = ObservableList<PostItem>.of(data.map(_mapPostItem));
      selectedItemIds.removeWhere(
        (id) => posts.every((post) => post.id != id),
      );
    } catch (e) {
      if (e is DioException) {
        errorStore.errorMessage = DioExceptionUtil.handleError(e);
      } else {
        errorStore.errorMessage = e.toString();
      }
    } finally {
      loading = false;
    }
  }

  @action
  Future<bool> deleteSelectedPosts() async {
    if (selectedItemIds.isEmpty) return false;

    loading = true;
    errorStore.errorMessage = '';

    try {
      final idsToDelete = selectedItemIds.toList();
      await _contentApi.deleteManyContents(idsToDelete);
      posts.removeWhere((post) => idsToDelete.contains(post.id));
      selectedItemIds.clear();
      totalItems = (totalItems - idsToDelete.length).clamp(0, totalItems);
      return true;
    } catch (e) {
      if (e is DioException) {
        errorStore.errorMessage = DioExceptionUtil.handleError(e);
      } else {
        errorStore.errorMessage = e.toString();
      }
      return false;
    } finally {
      loading = false;
    }
  }

  PostItem _mapPostItem(dynamic json) {
    final createdAt = json['createdAt']?.toString() ?? '';
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(createdAt);
        formattedDate = '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      } catch (_) {}
    }

    final publishedAt = json['publishedAt']?.toString() ?? '';
    String? formattedPublishedDate;
    if (publishedAt.isNotEmpty && publishedAt != 'null') {
      try {
        final dateTime = DateTime.parse(publishedAt);
        formattedPublishedDate =
            '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      } catch (_) {}
    }

    var type = json['contentType']?.toString().toUpperCase() ?? 'UNKNOWN';
    if (type == 'BLOG_POST') type = 'BLOG';
    if (type == 'SOCIAL_MEDIA_POST') type = 'SOCIAL';

    String? imageUrl;
    final thumbnail = json['thumbnail'];
    if (thumbnail is Map && thumbnail['url'] != null) {
      imageUrl = thumbnail['url']?.toString();
    } else if (json['featuredImageUrl'] != null) {
      imageUrl = json['featuredImageUrl']?.toString();
    }

    return PostItem(
      id: json['id']?.toString() ?? '',
      contentId: json['id']?.toString() ?? '',
      projectId: projectId,
      title: json['title']?.toString() ?? 'Untitled',
      description: json['body']?.toString() ?? 'No content',
      date: formattedDate,
      publishedDate: formattedPublishedDate,
      imageUrl: imageUrl,
      tags: (json['targetKeywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      type: type,
    );
  }

  void dispose() {}
}
