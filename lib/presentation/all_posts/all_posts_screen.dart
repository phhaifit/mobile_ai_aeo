import 'package:boilerplate/domain/entity/seo/seo_route_args.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/all_posts/store/all_posts_store.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  late final AllPostsStore _store;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _store = getIt<AllPostsStore>();
    _searchController = TextEditingController(text: _store.searchQuery);
    _store.loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
  }

  Future<void> _deleteSelectedPosts() async {
    final success = await _store.deleteSelectedPosts();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Successfully deleted selected items'
              : (_store.errorStore.errorMessage.isNotEmpty
                  ? 'Error deleting items: ${_store.errorStore.errorMessage}'
                  : 'Error deleting items'),
        ),
      ),
    );
  }

  Future<void> _applySearch(String value) async {
    _searchController.text = value;
    await _store.applySearch(value);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.black),
        onPressed: _handleBackNavigation,
      ),
      title: const Text(
        'All Posts',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Observer(
          builder: (_) {
            if (_store.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildTabs(),
                if (_store.hasSelection) _buildSelectionBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildSearchBar(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildActionRow(),
                ),
                Expanded(child: _buildGridView()),
                _buildPagination(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _store.setSelectedFilter('All Content');
              }),
              child: _buildTabItem(
                icon: Icons.layers,
                label: 'All Content',
                isSelected: _store.selectedFilter == 'All Content',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _store.setSelectedFilter('Blog');
              }),
              child: _buildTabItem(
                icon: Icons.article,
                label: 'Blog',
                isSelected: _store.selectedFilter == 'Blog',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _store.setSelectedFilter('Social');
              }),
              child: _buildTabItem(
                icon: Icons.share,
                label: 'Social',
                isSelected: _store.selectedFilter == 'Social',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
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
        onChanged: _store.setSearchQuery,
        onSubmitted: _applySearch,
        decoration: InputDecoration(
          hintText: 'Search prompts...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _store.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    _searchController.clear();
                    _store.clearSearch();
                    await _store.applySearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          label: Text(
            'Filters',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            minimumSize: const Size(0, 40),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/ai-writer');
                  },
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    'Add Content',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6600),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Observer(
        builder: (_) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                _buildFilterHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Status'),
                        _buildRadioOption('Status', '', 'All'),
                        _buildRadioOption(
                          'Status',
                          'PUBLISHED',
                          'Published',
                        ),
                        _buildRadioOption(
                          'Status',
                          'UNPUBLISHED',
                          'Unpublished',
                        ),
                        const Divider(height: 32),
                        _buildDateFilterSection(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _store.applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6600),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          TextButton(
            onPressed: () {
              _store.clearFilters();
            },
            child: Text(
              'Clear all',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildRadioOption(String type, String value, String label) {
    final groupValue =
        type == 'Status' ? _store.selectedStatus : _store.selectedContentType;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RadioGroup<String>(
        groupValue: groupValue,
        onChanged: (v) {
          if (type == 'Status') {
            _store.setSelectedStatus(v ?? '');
          } else {
            _store.setSelectedContentType(v ?? '');
          }
        },
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<String>(value: value),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _store.startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    _store.setStartDate(
                      DateTime(picked.year, picked.month, picked.day, 0, 0, 0),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _store.startDate != null
                        ? '${_store.startDate!.year}-${_store.startDate!.month.toString().padLeft(2, '0')}-${_store.startDate!.day.toString().padLeft(2, '0')}'
                        : 'Start Date',
                    style: TextStyle(
                      color:
                          _store.startDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _store.endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    _store.setEndDate(
                      DateTime(
                          picked.year, picked.month, picked.day, 23, 59, 59),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _store.endDate != null
                        ? '${_store.endDate!.year}-${_store.endDate!.month.toString().padLeft(2, '0')}-${_store.endDate!.day.toString().padLeft(2, '0')}'
                        : 'End Date',
                    style: TextStyle(
                      color:
                          _store.endDate != null ? Colors.black : Colors.grey,
                    ),
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
      color: Colors.orange[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_store.selectedItemIds.length} item${_store.selectedItemIds.length > 1 ? 's' : ''} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _store.toggleSelectAll,
                child: Row(
                  children: [
                    Icon(
                      _store.isAllVisibleSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Select All',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteSelectedPosts,
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.white),
                  label: const Text('Delete',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
      padding: const EdgeInsets.all(16),
      itemCount: _store.visiblePosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPostCard(_store.visiblePosts[index]);
      },
    );
  }

  Widget _buildPostCard(PostItem post) {
    final isSelected = _store.selectedItemIds.contains(post.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/post-detail', arguments: post.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[200]!,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        image: const AssetImage('assets/images/img_login.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.1),
                          BlendMode.darken,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _store.toggleSelection(post),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#1',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[100]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description,
                          size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        post.type,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              post.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: post.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${post.date}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Published: ${post.publishedDate}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.edit, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openSeoOptimization(post),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 18,
                    color: Colors.blueGrey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.visibility_off, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Icon(Icons.open_in_new, size: 18, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _store.currentPage > 1
                    ? () => _store.changePage(_store.currentPage - 1)
                    : null,
              ),
              Text('Page ${_store.currentPage} of ${_store.totalPages}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _store.currentPage < _store.totalPages
                    ? () => _store.changePage(_store.currentPage + 1)
                    : null,
              ),
            ],
          ),
          Row(
            children: [
              Text('Show:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 8),
              PopupMenuButton<int>(
                initialValue: _store.itemsPerPage,
                onSelected: (int value) {
                  _store.setItemsPerPage(value);
                },
                itemBuilder: (BuildContext context) {
                  return _store.itemsPerPageOptions.map((int value) {
                    return PopupMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _store.itemsPerPage.toString(),
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
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
