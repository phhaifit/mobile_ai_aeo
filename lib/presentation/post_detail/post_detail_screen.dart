import 'dart:async';

import 'package:boilerplate/data/network/apis/content_management/content_management_api.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/post_detail/store/post_detail_store.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

// ignore_for_file: unused_element

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostDetailStore _store;
  StreamSubscription<String>? _jobStreamSubscription;

  bool get _isLoading => _store.isLoading;
  set _isLoading(bool value) => _store.isLoading = value;

  Map<String, dynamic>? get _postData => _store.postData;
  set _postData(Map<String, dynamic>? value) => _store.postData = value;

  TextEditingController get _titleController => _store.titleController;
  TextEditingController get _slugController => _store.slugController;
  TextEditingController get _bodyController => _store.bodyController;

  bool get _isEditing => _store.isEditing;
  set _isEditing(bool value) => _store.isEditing = value;

  bool get _isContentProfileExpanded => _store.isContentProfileExpanded;
  set _isContentProfileExpanded(bool value) =>
      _store.isContentProfileExpanded = value;

  bool get _isTopicExpanded => _store.isTopicExpanded;
  set _isTopicExpanded(bool value) => _store.isTopicExpanded = value;

  bool get _isPromptExpanded => _store.isPromptExpanded;
  set _isPromptExpanded(bool value) => _store.isPromptExpanded = value;

  @override
  void initState() {
    super.initState();
    _store = getIt.isRegistered<PostDetailStore>()
        ? getIt<PostDetailStore>()
        : PostDetailStore(
            ContentManagementApi(getIt(), getIt()),
          );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _store.loadPostDetail(args);
    } else {
      _store.isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_isLoading && _postData == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: const BackButton(color: Colors.black),
              title: const Text(
                'Loading...',
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_postData == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: const BackButton(color: Colors.black),
              title: const Text('Error', style: TextStyle(color: Colors.black)),
            ),
            body: Center(
              child: Text(
                _store.errorMessage ?? 'Could not load post details',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.allPosts,
                  (Route<dynamic> route) => false,
                );
              },
            ),
            title: const Text(
              'Content Details',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.black54),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey[300], height: 1.0),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildRegenerateSection(),
                const SizedBox(height: 16),
                _buildContentEditor(),
                const SizedBox(height: 16),
                _buildGeneralInsights(),
                const SizedBox(height: 16),
                _buildThumbnailSection(),
                const SizedBox(height: 16),
                _buildGenerationInput(),
                const SizedBox(height: 16),
                if (_postData!['targetKeywords'] != null) ...[
                  _buildTargetKeywords(),
                  const SizedBox(height: 16),
                ],
                if (_postData!['retrievedPages'] != null) ...[
                  _buildRetrievedPages(),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _jobStreamSubscription?.cancel();
    _store.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    String contentType =
        _postData!['contentType']?.toString().toUpperCase() ?? 'UNKNOWN';
    if (contentType == 'BLOG_POST') contentType = 'BLOG';
    if (contentType == 'SOCIAL_MEDIA_POST') contentType = 'SOCIAL';

    return Row(
      children: [
        const Text(
          'Content Detail',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.article, size: 14, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                contentType,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isPublished = _postData!['completionStatus'] == 'PUBLISHED';
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPublished)
          OutlinedButton.icon(
            onPressed: () => _updateStatus('UNPUBLISHED'),
            icon: const Icon(
              Icons.visibility_off,
              color: Colors.orange,
              size: 18,
            ),
            label: const Text(
              'Unpublish',
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => _updateStatus('PUBLISHED'),
            icon: const Icon(Icons.visibility, color: Colors.green, size: 18),
            label: const Text('Publish', style: TextStyle(color: Colors.green)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: isPublished ? () => _updateStatus('REPUBLISH') : null,
          icon: Icon(
            Icons.autorenew,
            color: isPublished ? Colors.black87 : Colors.grey,
            size: 18,
          ),
          label: Text(
            'Republish',
            style: TextStyle(color: isPublished ? Colors.black87 : Colors.grey),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isPublished ? Colors.grey[400]! : Colors.grey[200]!,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildRegenerateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Not satisfied with this content? Let AI rewrite it for you keeping the original configuration.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _regenerateContent(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Regenerate Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String action) async {
    try {
      await _store.updateStatus(action);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully $action content.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _regenerateContent() async {
    try {
      final jobId = await _store.regenerateContent();
      if (jobId == null || jobId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Regenerate failed: missing jobId')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Regenerating the post. Please wait....'),
          ),
        );
      }

      _listenToJobStream(jobId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error regenerating: $e')));
      }
    }
  }

  void _listenToJobStream(String jobId) async {
    try {
      _jobStreamSubscription = await _store.listenToJobStream(
        jobId: jobId,
        onLine: (line) {
          if (line.startsWith('data: ')) {
            try {
              final jsonString = line.substring(6); // remove 'data: '
              if (jsonString.trim().isNotEmpty) {
                final payload = _store.decodeEvent(jsonString);

                // Check if event is 'result' which contains the final generated post
                if (payload['event'] == 'result' || payload['id'] != null) {
                  _jobStreamSubscription?.cancel();
                  final newId = payload['data'] != null
                      ? payload['data']['id']
                      : payload['id'];

                  if (newId != null && newId != _postData!['id']) {
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        Routes.postDetail,
                        arguments: newId,
                      );
                    }
                  } else {
                    // Same ID (e.g. was Drafting/Failed before rerun)
                    _store.loadPostDetail(_postData!['id'].toString());
                  }
                } else if (payload['event'] == 'failed' ||
                    payload['error'] != null) {
                  _jobStreamSubscription?.cancel();
                  if (mounted) {
                    _store.setActionLoading(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Regeneration job failed on server.',
                        ),
                      ),
                    );
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing SSE data: $e');
            }
          }
        },
        onError: (err) {
          if (mounted) _store.setActionLoading(false);
        },
      );
    } catch (e) {
      if (mounted) _store.setActionLoading(false);
    }
  }

  Widget _buildContentEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                      )
                    : Text(
                        _titleController.text.isNotEmpty
                            ? _titleController.text
                            : 'Untitled',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 20),
                onPressed: () {
                  setState(() {
                    _store.toggleEditing();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Slug: ', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _isEditing
                      ? TextField(
                          controller: _slugController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(
                          _slugController.text.isNotEmpty
                              ? '/blog/${_slugController.text}'
                              : 'N/A',
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 18, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 16),
          if (_isEditing)
            TextField(
              controller: _bodyController,
              maxLines: null,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your content here...',
              ),
              onChanged: (_) {
                setState(() {}); // Trigger rebuild for word count
              },
            )
          else
            Text(
              _bodyController.text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isEditing)
                ElevatedButton.icon(
                  onPressed: _saveContent,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '${_bodyController.text.trim().isEmpty ? 0 : _bodyController.text.trim().split(RegExp(r'\s+')).length} words | ${_bodyController.text.length} characters',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveContent() async {
    try {
      final success = await _store.saveContent();
      if (success) {
        _isEditing = false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  Widget _buildGeneralInsights() {
    final body = _postData!['body']?.toString() ?? '';
    final wordCount = body.isEmpty ? 0 : body.split(RegExp(r'\s+')).length;

    // Status can be PUBLISHED or UNPUBLISHED (display COMPLETE as UNPUBLISHED)
    String rawStatus = _postData!['completionStatus']?.toString() ?? 'UNKNOWN';
    final isPublished = rawStatus == 'PUBLISHED';
    final displayStatus = isPublished ? 'PUBLISHED' : 'UNPUBLISHED';

    final dateStr = _postData!['publishedAt']?.toString() ?? '';
    String formattedDate = '';
    if (isPublished && dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        formattedDate = '${dt.month}/${dt.day}/${dt.year}';
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Word Count',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$wordCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Status', style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 8),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPublished ? Colors.green : Colors.orange,
                      ),
                    ),
                    if (isPublished && formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    String? thumbnailUrl;
    if (_postData!['thumbnail'] != null &&
        _postData!['thumbnail']['url'] != null) {
      thumbnailUrl = _postData!['thumbnail']['url'];
    } else if (_postData!['featuredImageUrl'] != null &&
        _postData!['featuredImageUrl'] is String) {
      thumbnailUrl = _postData!['featuredImageUrl'];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thumbnail Image',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: thumbnailUrl != null
                    ? NetworkImage(thumbnailUrl) as ImageProvider
                    : const AssetImage('assets/images/img_login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationInput() {
    final profile = _postData!['profile'] as Map<String, dynamic>?;
    final topic = _postData!['topic'] as Map<String, dynamic>?;
    final prompt = _postData!['prompt'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generation Input',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Content Profile Section
          InkWell(
            onTap: () {
              setState(() {
                _store.setContentProfileExpanded(!_isContentProfileExpanded);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Content Profile',
                    style: TextStyle(
                      color: Color(0xFF3F4E66),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    _isContentProfileExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (_isContentProfileExpanded && profile != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1C2B41),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile['name']?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Color(0xFF3F4E66),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1C2B41),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Assuming description could be a string or map. Safely toString.
                  Text(
                    profile['description']?.toString() ?? '...',
                    style: const TextStyle(
                      color: Color(0xFF3F4E66),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Voice & Tone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1C2B41),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile['voiceAndTone']?.toString() ?? '...',
                    style: const TextStyle(
                      color: Color(0xFF3F4E66),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Target Audience',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1C2B41),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile['audience']?.toString() ?? '...',
                    style: const TextStyle(
                      color: Color(0xFF3F4E66),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Divider(color: Colors.grey[200]),

          // Topic Section
          InkWell(
            onTap: () {
              setState(() {
                _store.setTopicExpanded(!_isTopicExpanded);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Topic',
                    style: TextStyle(
                      color: Color(0xFF3F4E66),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    _isTopicExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (_isTopicExpanded && topic != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                topic['name']?.toString() ?? 'N/A',
                style: const TextStyle(color: Color(0xFF3F4E66), fontSize: 14),
              ),
            ),
          ],
          Divider(color: Colors.grey[200]),

          // Prompt Used Section
          InkWell(
            onTap: () {
              setState(() {
                _store.setPromptExpanded(!_isPromptExpanded);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  const Text(
                    'Prompt Used',
                    style: TextStyle(
                      color: Color(0xFF3F4E66),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (prompt != null && prompt['type'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        prompt['type'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    _isPromptExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (_isPromptExpanded && prompt != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prompt['content']?.toString() ?? 'N/A',
                style: const TextStyle(color: Color(0xFF3F4E66), fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetKeywords() {
    final keywords = _postData!['targetKeywords'] as List<dynamic>? ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Keywords',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((k) => _buildChip(k.toString())).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.blue[700], fontSize: 13),
      ),
    );
  }

  Widget _buildRetrievedPages() {
    final pages = _postData!['retrievedPages'] as List<dynamic>? ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retrieved Pages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...pages.map((page) {
            final title = page['title']?.toString() ?? 'Untitled';
            final url = page['url']?.toString() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50], // light orange background tint
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          url,
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.blue[600],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
