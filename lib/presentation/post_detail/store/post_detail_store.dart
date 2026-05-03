import 'dart:async';

import 'package:boilerplate/data/network/apis/content_management/content_management_api.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'post_detail_store.g.dart';

class PostDetailStore = _PostDetailStore with _$PostDetailStore;

abstract class _PostDetailStore with Store {
  _PostDetailStore(this._contentApi) {
    _titleController.addListener(_syncDraftFromControllers);
    _slugController.addListener(_syncDraftFromControllers);
    _bodyController.addListener(_syncDraftFromControllers);
  }

  final ContentManagementApi _contentApi;

  ContentManagementApi get contentApi => _contentApi;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @observable
  Map<String, dynamic>? postData;

  @observable
  bool isLoading = true;

  @observable
  bool isActionLoading = false;

  @observable
  bool isEditing = false;

  @observable
  bool isContentProfileExpanded = false;

  @observable
  bool isTopicExpanded = false;

  @observable
  bool isPromptExpanded = false;

  @observable
  String titleText = '';

  @observable
  String slugText = '';

  @observable
  String bodyText = '';

  @observable
  String? errorMessage;

  String? _loadedPostId;

  TextEditingController get titleController => _titleController;
  TextEditingController get slugController => _slugController;
  TextEditingController get bodyController => _bodyController;

  @computed
  bool get hasPost => postData != null;

  @computed
  int get wordCount {
    final text = bodyText.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  @computed
  String get contentTypeLabel {
    final raw = postData?['contentType']?.toString().toUpperCase() ?? 'UNKNOWN';
    if (raw == 'BLOG_POST') return 'BLOG';
    if (raw == 'SOCIAL_MEDIA_POST') return 'SOCIAL';
    return raw;
  }

  @computed
  bool get isPublished => postData?['completionStatus'] == 'PUBLISHED';

  @computed
  String get displayStatus => isPublished ? 'PUBLISHED' : 'UNPUBLISHED';

  @computed
  String get statusColorName => isPublished ? 'green' : 'orange';

  @action
  Future<void> loadPostDetail(String id) async {
    if (_loadedPostId == id && postData != null && !isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final data = await _contentApi.getContentDetail(id);
      _loadedPostId = id;
      postData = data;
      _syncFieldsFromPostData();
      isEditing = false;
    } catch (e) {
      postData = null;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void toggleEditing() {
    if (isEditing) {
      _syncFieldsFromPostData();
    }
    isEditing = !isEditing;
  }

  @action
  void setContentProfileExpanded(bool value) {
    isContentProfileExpanded = value;
  }

  @action
  void setTopicExpanded(bool value) {
    isTopicExpanded = value;
  }

  @action
  void setPromptExpanded(bool value) {
    isPromptExpanded = value;
  }

  @action
  void setActionLoading(bool value) {
    isActionLoading = value;
  }

  Future<void> updateStatus(String action) async {
    final id = postData?['id']?.toString();
    if (id == null || id.isEmpty) return;

    final endpoint = action == 'UNPUBLISHED'
        ? 'unpublish'
        : action == 'PUBLISHED'
            ? 'publish'
            : 'republish';

    isActionLoading = true;
    try {
      await _contentApi.changeContentStatus(id, endpoint);
      await loadPostDetail(id);
    } finally {
      isActionLoading = false;
    }
  }

  Future<bool> saveContent() async {
    final id = postData?['id']?.toString();
    if (id == null || id.isEmpty) return false;

    isActionLoading = true;
    try {
      String? thumbnailKey;
      final thumbnail = postData?['thumbnail'];
      if (thumbnail is Map<String, dynamic> && thumbnail['key'] != null) {
        thumbnailKey = thumbnail['key']?.toString();
      }

      final payload = <String, dynamic>{
        'body': bodyController.text,
        'title': titleController.text,
        'slug': slugController.text,
        'completionStatus': postData?['completionStatus'] == 'PUBLISHED'
            ? 'COMPLETE'
            : (postData?['completionStatus'] ?? 'COMPLETE'),
        if (thumbnailKey != null) 'thumbnailKey': thumbnailKey,
      };

      await _contentApi.updateContent(id, payload);
      await loadPostDetail(id);
      return true;
    } catch (_) {
      return false;
    } finally {
      isActionLoading = false;
    }
  }

  Future<String?> regenerateContent() async {
    final id = postData?['id']?.toString();
    if (id == null || id.isEmpty) return null;

    isActionLoading = true;
    try {
      final data = await _contentApi.regenerateContent(id);
      return data['jobId']?.toString();
    } catch (_) {
      isActionLoading = false;
      return null;
    }
  }

  Future<StreamSubscription<String>> listenToJobStream({
    required String jobId,
    required void Function(String line) onLine,
    void Function(Object error)? onError,
    void Function()? onDone,
  }) {
    return _contentApi.listenToJobStream(
      jobId: jobId,
      onLine: onLine,
      onError: onError,
      onDone: onDone,
    );
  }

  Map<String, dynamic> decodeEvent(String jsonString) {
    return _contentApi.decodeEvent(jsonString);
  }

  void _syncDraftFromControllers() {
    titleText = _titleController.text;
    slugText = _slugController.text;
    bodyText = _bodyController.text;
  }

  void _syncFieldsFromPostData() {
    final data = postData ?? const <String, dynamic>{};
    _titleController.text = data['title']?.toString() ?? '';
    _slugController.text = data['slug']?.toString() ?? '';
    _bodyController.text = data['body']?.toString() ?? '';
    _syncDraftFromControllers();
  }

  void dispose() {
    _titleController.removeListener(_syncDraftFromControllers);
    _slugController.removeListener(_syncDraftFromControllers);
    _bodyController.removeListener(_syncDraftFromControllers);
    _titleController.dispose();
    _slugController.dispose();
    _bodyController.dispose();
  }
}
