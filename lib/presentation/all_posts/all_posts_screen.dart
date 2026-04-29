import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boilerplate/domain/entity/seo/seo_route_args.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/di/service_locator.dart';

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

  PostItem({
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

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  final Set<PostItem> _selectedItems = {};

  bool _isLoading = false;
  List<PostItem> _posts = [];
  int _totalItems = 0;
  int _currentPage = 1;

  String _searchQuery = '';
  String _selectedStatus = '';
  String _selectedContentType = '';
  String _selectedTopic = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  String _projectId =
      "ca6a7019-5e93-431f-b2d8-8deabc82a8af"; // Same mock ID as ai_writer

  Future<String?> _getToken() async {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzOWY3YTBkZi1iZGFkLTQ0ZWYtYTU4NC01Y2IxZmRlZTQyNjciLCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwiaWF0IjoxNzc3MTIyNTgxLCJleHAiOjE3Nzk3MTQ1ODF9._y_3WDNiqsdRjunEzR0IJkA1rR8tv6YGnylsuG2V3PU';                 }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = getIt<DioClient>().dio;
      final projRes = await dio.get('/api/projects');
      final dynamic projData = projRes.data['data'] ?? projRes.data;

      if (projData is List && projData.isNotEmpty) {
        _projectId = projData.first['id'].toString();
      }

      final headers = await _getHeaders();

      // Build query parameters
      Map<String, String> queryParams = {
        'page': _currentPage.toString(),
        'limit': _itemsPerPage.toString(),
      };

      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
      if (_selectedStatus.isNotEmpty) queryParams['status'] = _selectedStatus;        
      if (_selectedContentType.isNotEmpty)
        queryParams['contentType'] = _selectedContentType;
      if (_selectedTopic.isNotEmpty) queryParams['topicName'] = _selectedTopic;       
      if (_startDate != null)
        queryParams['startDate'] = _startDate!.toIso8601String();
      if (_endDate != null)
        queryParams['endDate'] = _endDate!.toIso8601String();

      final uri =
          Uri.parse('https://api.aeo.how/api/projects/$_projectId/contents')
              .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> bodyDecoded = jsonDecode(response.body);
        final List<dynamic> data = bodyDecoded['data'] ?? [];

        // Handle meta data if available (total count, etc.)
        final Map<String, dynamic>? meta = bodyDecoded['meta'];
        if (meta != null && meta['total'] != null) {
          _totalItems = meta['total'];
        } else {
          _totalItems = data.length; // Fallback
        }

        setState(() {
          _posts = data.map((json) {
            // Format dates simply for display
            String createdAt = json['createdAt'] ?? '';
            String formattedDate = '';
            if (createdAt.isNotEmpty) {
              try {
                final dt = DateTime.parse(createdAt);
                formattedDate = '${dt.month}/${dt.day}/${dt.year}';
              } catch (e) {}
            }

            String publishedAtStr = json['publishedAt']?.toString() ?? '';
            String? formattedPublishDate;
            if (publishedAtStr.isNotEmpty && publishedAtStr != 'null') {
              try {
                final dt2 = DateTime.parse(publishedAtStr);
                formattedPublishDate = '${dt2.month}/${dt2.day}/${dt2.year}';
              } catch (e) {}
            }

            String type =
                json['contentType']?.toString().toUpperCase() ?? 'UNKNOWN';
            if (type == 'BLOG_POST') type = 'BLOG';
            if (type == 'SOCIAL_MEDIA_POST') type = 'SOCIAL';

            String? imgUrl;
            if (json['thumbnail'] != null && json['thumbnail']['url'] != null) {      
              imgUrl = json['thumbnail']['url']?.toString();
            } else if (json['featuredImageUrl'] != null) {
              imgUrl = json['featuredImageUrl']?.toString();
            }

            return PostItem(
              id: json['id'] ?? '',
              contentId: json['id']?.toString() ?? '',
              projectId: _projectId,
              title: json['title'] ?? 'Untitled',
              description: json['body'] ?? 'No content',
              date: formattedDate,
              publishedDate: formattedPublishDate,
              imageUrl: imgUrl,
              tags: (json['targetKeywords'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              type: type,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSelectedPosts() async {
    if (_selectedItems.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final headers = await _getHeaders();
      final idsToDelete = _selectedItems.map((post) => post.id).toList();

      final response = await http.delete(
        Uri.parse('https://api.aeo.how/api/contents/delete-many'),
        headers: headers,
        body: jsonEncode({"ids": idsToDelete}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _posts.removeWhere((post) => idsToDelete.contains(post.id));
          _selectedItems.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully deleted selected items')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting items: $e')),

        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _selectedFilter = 'All Content';
  List<int> _itemsPerPageOptions = [10, 25, 50, 100];
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  List<PostItem> get _filteredPosts {
    List<PostItem> filtered = [];
    if (_selectedFilter == 'All Content') {
      filtered = _posts;
    } else {
      String filterMatcher = _selectedFilter.toUpperCase();
      filtered = _posts
          .where((post) => post.type.toUpperCase() == filterMatcher)
          .toList();
    }

    // Simple pagination simulation: show only up to _itemsPerPage
    // In a real app, this would fetch from backend or slice the list properly for the current page
    return filtered.take(_itemsPerPage).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  void _toggleSelection(PostItem post) {
    setState(() {
      if (_selectedItems.contains(post)) {
        _selectedItems.remove(post);
      } else {
        _selectedItems.add(post);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedItems.length == _filteredPosts.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.addAll(_filteredPosts);
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'All Posts',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildTabs(),
        if (_selectedItems.isNotEmpty) _buildSelectionBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildActionRow(),
        ),
        Expanded(
          child: _buildGridView(),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'All Content';
                });
              },
              child: _buildTabItem(
                  icon: Icons.layers,
                  label: 'All Content',
                  isSelected: _selectedFilter == 'All Content'),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Blog';
                });
              },
              child: _buildTabItem(
                  icon: Icons.article,
                  label: 'Blog',
                  isSelected: _selectedFilter == 'Blog'),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Social';
                });
              },
              child: _buildTabItem(
                  icon: Icons.share,
                  label: 'Social',
                  isSelected: _selectedFilter == 'Social'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      {required IconData icon,
      required String label,
      required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal:
              4), // Reduce horizontal padding if necessary, or just rely on Flexible
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]), // Reduced size
          SizedBox(width: 4), // Reduced spacing
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12, // Reduced font size to prevent overflow
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1;
          });
          _fetchPosts();
        },
        decoration: InputDecoration(
          hintText: 'Search prompts...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _currentPage = 1;
                    });
                    _fetchPosts();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: _showFilters,
          icon: Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
          label: Text('Filters',
              style: TextStyle(
                  color: Colors.grey[700], fontSize: 13)), // Adjusted font size
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            padding: EdgeInsets.symmetric(
                horizontal: 12, vertical: 12), // Reduced horizontal padding
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            minimumSize:
                Size(0, 40), // Ensure minimum width isn't forcing overflow
          ),
        ),
        SizedBox(width: 8), // Added spacing between left and right actions
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/ai-writer');
                  },
                  icon: Icon(Icons.add,
                      size: 16, color: Colors.white), // Adjusted size
                  label: Text('Add Content',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12)), // Adjusted font size
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6600), // Orange color
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12), // Reduced padding
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    minimumSize: Size(
                        0, 40), // Ensure minimum width isn't forcing overflow
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildFilterHeader(setModalState),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Status'),
                      _buildRadioOption('Status', '', 'All', setModalState),
                      _buildRadioOption(
                          'Status', 'PUBLISHED', 'Published', setModalState),
                      _buildRadioOption('Status', 'UNPUBLISHED', 'Unpublished',
                          setModalState),
                      Divider(height: 32),
                      _buildDateFilterSection(setModalState),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  )
                ]),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentPage = 1;
                      });
                      _fetchPosts();
                    },
                    child: Text('Apply Filters',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6600),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterHeader(StateSetter setModalState) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextButton(
            onPressed: () {
              setModalState(() {
                _selectedStatus = '';
                _selectedContentType = '';
                _selectedTopic = '';
                _startDate = null;
                _endDate = null;
              });
            },
            child: Text('Clear all', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildRadioOption(
      String type, String value, String label, StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Radio<String>(
              value: value,
              groupValue:
                  type == 'Status' ? _selectedStatus : _selectedContentType,
              onChanged: (v) {
                setModalState(() {
                  if (type == 'Status') _selectedStatus = v!;
                  if (type == 'ContentType') _selectedContentType = v!;
                });
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setModalState(() {
                      _startDate = DateTime(
                          picked.year, picked.month, picked.day, 0, 0, 0);
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                        : 'Start Date',
                    style: TextStyle(
                        color: _startDate != null ? Colors.black : Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setModalState(() {
                      _endDate = DateTime(
                          picked.year, picked.month, picked.day, 23, 59, 59);
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                        : 'End Date',
                    style: TextStyle(
                        color: _endDate != null ? Colors.black : Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      width: double.infinity,
      color: Colors.orange[50], // Light orange background as requested
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        // Use Column for mobile responsiveness
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(width: 16),
              GestureDetector(
                onTap: _toggleSelectAll, // Use the method here
                child: Row(
                  children: [
                    Icon(
                        _selectedItems.length == _filteredPosts.length
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: Colors.black87),
                    SizedBox(width: 4),
                    Text('Select All',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            // Horizontal scroll for action buttons on mobile
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteSelectedPosts,
                  icon:
                      Icon(Icons.delete_outline, size: 18, color: Colors.white),
                  label: Text('Delete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPostCard(_filteredPosts[index]);
      },
    );
  }

  Widget _buildPostCard(PostItem post) {
    bool isSelected = _selectedItems.contains(post);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/post-detail', arguments: post.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: post.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(post.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage(
                              'assets/images/img_login.jpg'), // Placeholder
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.1),
                              BlendMode.darken))),

            ),
            SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => _toggleSelection(post),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('#1',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[100]!),
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Icon(Icons.description, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(post.type,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 8),

            Text(
              post.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              post.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: post.tags
                  .map((tag) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(color: Colors.blue[100]!),
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(tag,
                            style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Created: ${post.date}',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Published: ${post.publishedDate}',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    int totalPages = (_totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _fetchPosts();
                      }
                    : null,
              ),
              Text('Page $_currentPage of $totalPages'),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _fetchPosts();
                      }
                    : null,
              ),
            ],
          ),
          Row(
            children: [
              Text('Show:', style: TextStyle(color: Colors.grey[600])),
              SizedBox(width: 8),
              PopupMenuButton<int>(
                initialValue: _itemsPerPage,
                onSelected: (int value) {
                  setState(() {
                    _itemsPerPage = value;
                    _currentPage = 1;
                  });
                  _fetchPosts();
                },
                itemBuilder: (BuildContext context) {
                  return _itemsPerPageOptions.map((int value) {
                    return PopupMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList();
                },
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        Text(_itemsPerPage.toString(),
                            style: TextStyle(color: Colors.grey[800])),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600])
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSeoOptimization(PostItem post) {
    Navigator.of(context).pushNamed(
      Routes.seoOptimization,
      arguments: SeoRouteArgs(
        contentId: post.contentId,
        projectId: post.projectId,
        contentTitle: post.title,
      ),
    );
  }
}
